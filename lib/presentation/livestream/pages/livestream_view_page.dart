
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vwave/presentation/livestream/models/comment.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../utils/exceptions.dart';
import '../../../utils/storage.dart';
import '../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../widgets/multiple_options_bottom_sheet.dart';
import '../../../widgets/report_dialog.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/providers/auth_state.dart';
import '../../auth/providers/auth_state_notifier.dart';
import '../../club/models/club.dart';
import '../models/livestream.dart';
import '../providers/livestream_notifier_provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LivestreamViewPage extends ConsumerStatefulWidget {
  final Livestream livestream;
  const LivestreamViewPage(this.livestream, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LivestreamViewPageState();
}

class _LivestreamViewPageState extends ConsumerState<LivestreamViewPage> {

  StorageSystem ss = StorageSystem();
  Map<String, dynamic> userData = {};

  String appId = dotenv.env['AGORA_APP_ID'] ?? "";
  String token = "";
  String channel = "";

  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  int numericUid = 0;
  int totalViews = 0;

  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> livestreamAsync;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> livestreamCommentsAsync;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> livestreamJoinedUsersAsync;
  final TextEditingController _commentBodyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Comment> comments = [];
  List<Map<String, dynamic>> joinedUsers = [];

  bool micMuted = false;
  String cameraType = "front";

  final startTime = DateTime.now();

  bool canSetBackgroundImage = false;
  bool isBackgroundImageSet = false;

  @override
  void initState() {
    super.initState();
    channel = widget.livestream.channelName;
    Future.delayed(Duration.zero, () async {
      KeepScreenOn.turnOn();
      String getUser = (await ss.getItem('user'))!;
      setState(() {
        userData = jsonDecode(getUser);
        totalViews = widget.livestream.liveViews ?? 0;
      });
      token = await fetchToken();
      // await fetchStreamKey(0);
      String _numericUid = await ss.getItem("numeric_uid") ?? "0";
      numericUid = int.parse(_numericUid);
      if(widget.livestream.userUid != GeneralUtils().userUid) {
        ref.read(livestreamNotifierProvider.notifier).setStateLoading(true);
        bool? hasLivestreamEnded = await ref.read(livestreamNotifierProvider.notifier).hasLivestreamEnded(widget.livestream);
        hasLivestreamEnded ??= false;
        if(hasLivestreamEnded) {
          Navigator.of(context).pushReplacementNamed('/home');
          GeneralUtils.showToast("Livestream has ended");
          return;
        }
      }
      initAgora();
      livestreamFirebaseListener();
      livestreamCommentsFirebaseListener();
      livestreamJoinedUsersFirebaseListener();
    });
  }

  void livestreamFirebaseListener() {
    livestreamAsync = FirebaseFirestore.instance.collection("livestreams").doc(widget.livestream.id).snapshots().listen((event) async {
      final livestream = Livestream.fromDocument(event);
      if(!mounted) return;
      setState(() {
        totalViews = livestream.liveViews ?? 0;
      });
      if(livestream.hasEnded) {
        if(GeneralUtils().userUid != widget.livestream.userUid) {
          await _dispose();
          GeneralUtils.showToast("Livestream has ended");
        }
      }
    });
  }

  void livestreamCommentsFirebaseListener() {
    livestreamCommentsAsync = FirebaseFirestore.instance.collection("livestream_comments").where("livestream_id", isEqualTo: widget.livestream.id).orderBy("timestamp", descending: false).snapshots().listen((event) {
      comments.clear();
      if(!mounted) return;
      setState(() {
        comments = event.docs.map((e) => Comment.fromDocument(e)).toList();
        if (_scrollController.hasClients) {
          if(!_scrollController.position.outOfRange) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(seconds: 1), curve: Curves.decelerate);
          }
          // if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
          //
          // }
        }
      });
    });
  }

  void livestreamJoinedUsersFirebaseListener() {
    livestreamJoinedUsersAsync = FirebaseFirestore.instance.collection("livestreams").doc(widget.livestream.id).collection("joined-users").where("allow_search_visibility", isEqualTo: true).orderBy("timestamp", descending: true).snapshots().listen((event) {
      joinedUsers.clear();
      if(!mounted) return;
      setState(() {
        joinedUsers = event.docs.map((e) => e.data()).toList();
      });
    });
  }

  @override
  void dispose() {
    _commentBodyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    try {
      // Future.delayed(Duration.zero, () {
      //   ref.read(livestreamNotifierProvider.notifier).setStateHasEnded(true);
      // });
      if(GeneralUtils().userUid == widget.livestream.userUid) {
        final endTime = DateTime.now();
        int duration = endTime.difference(startTime).inSeconds;
        await updateLivestream({"has_ended": true, "duration": duration});
        // String path = await FlutterScreenRecording.stopRecordScreen;
        // // upload file to storage
        // final data = {
        //   "path": path,
        //   "livestream_id": widget.livestream.id!,
        //   "livestream_channel_name": widget.livestream.channelName,
        //   "user_uid": widget.livestream.userUid
        // };
        // compute(uploadLivestreamToCloud, data);
      }
      await _engine.leaveChannel();
      await _engine.release();
      // if(GeneralUtils().userUid == widget.livestream.userUid) {
      //   await _engine.release();
      // }
      await livestreamAsync.cancel();
      await livestreamCommentsAsync.cancel();
      await livestreamJoinedUsersAsync.cancel();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch(e) {
      print("livestream error ==================== $e");
    }
  }

  Future<void> initAgora() async {
    try {
      // retrieve permissions
      await [Permission.microphone, Permission.camera].request();
      
      // if(GeneralUtils().userUid == widget.livestream.userUid) {
      //   await [Permission.storage].request();
      // }

      //create the engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      // _engine.startR;

      // await _engine
      //     .getMediaEngine()
      //     .setExternalVideoSource(enabled: true, useTexture: false, sourceType: ExternalVideoSourceType.videoFrame);

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user ${connection.localUid} joined");
            setState(() {
              _localUserJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined");
            setState(() {
              _remoteUid = remoteUid;
            });
            updateLivestream({"views": FieldValue.increment(1), "live_views": FieldValue.increment(1)}, createUserDocument: true);
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            // print("I just left the channel jhooor");
            if(GeneralUtils().userUid != widget.livestream.userUid) {
              if(totalViews <= 0) {
                return;
              }
              updateLivestream({"live_views": FieldValue.increment(-1)});
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            // debugPrint("remote user $remoteUid left channel");
            // print("I just left the channel jhooor 222222222222");
            // updateLivestream({"views": FieldValue.increment(-1), "live_views": FieldValue.increment(-1)});
            setState(() {
              _remoteUid = null;
            });
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            // debugPrint(
            //     '[onTokenPrivilegeWillExpire] connection: ${connection
            //         .toJson()}, token: $token');
          },
        ),
      );

      await _engine.setClientRole(
          role: GeneralUtils().userUid == widget.livestream.userUid
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience);
      await _engine.enableVideo();
      await _engine.startPreview();
      _engine.createMediaRecorder(RecorderStreamInfo(channelId: channel, uid: 0));

      // print("token ================== $token");

      await _engine.joinChannel(
        token: token, //"007eJxTYLjT/+pTdsazGaol1Uv67iYtPerq5vV9Q9/8Qzkbn1q6PfJTYLA0t7RMM0i1tDQ0tDQxNU5KMk42SDFLSbYwNzKzSDI31l1wJrUhkJFh/9mtzIwMEAjiizB4plT6J5a45Ce5FFRkmGWHpaSGZDIwAAC1Dyie",
        channelId: channel,
        uid: 0, //numericUid,
        options: const ChannelMediaOptions(),
      );

      bool featureAvail = await _engine.isFeatureAvailableOnDevice(FeatureType.videoVirtualBackground);
      setState(() {
        canSetBackgroundImage = featureAvail;
      });

      if(GeneralUtils().userUid == widget.livestream.userUid) {
        // await FlutterScreenRecording.startRecordScreenAndAudio(widget.livestream.channelName);
      }
    }catch(e){
      print("errrrorrr=====================================");
      print(e);
      print("errrrorrr=====================================");
    }
  }

  Future<String> fetchToken() async {
    await ss.deletePref("user_agora_token");
    // fetch user numeric uid;

    String numericUid = await ss.getItem("numeric_uid") ?? "";
    if(numericUid.isEmpty) {
      numericUid = (DateTime.now().millisecondsSinceEpoch.toDouble() + Random().nextInt(99999999)).ceil().toString();
      await ss.setPrefItem("numeric_uid", numericUid, isStoreOnline: true, isUserData: true);
    }

    int uid = int.parse(numericUid);
    int role = GeneralUtils().userUid == widget.livestream.userUid ? 0 : 1;

    String userAgoraToken = await ss.getItem("user_agora_token") ?? "";
    if(userAgoraToken.isNotEmpty) {
      Map<String, dynamic> tokenData = jsonDecode(userAgoraToken);
      DateTime tokenExpire = DateTime.fromMillisecondsSinceEpoch(tokenData["expire"]);
      DateTime now = DateTime.now();
      if(tokenExpire.difference(now).inMilliseconds < 0) {
        final token = await fetchTokenOnline(0, role);
        return token;
      }
      return tokenData["token"];
    }

    final token = await fetchTokenOnline(0, role);
    // print("token ================== $token");
    return token;
  }

  Future<String> fetchTokenOnline(int uid, int role) async {
    final res = await GeneralUtils().makeRequest("fetchagoratoken?uid=$uid&channel=$channel&role=$role", {}, method: "get");
    // print(res.body);
    if(res.statusCode != 200) {
      return "";
    }

    final resp = jsonDecode(res.body);
    Map<String, dynamic> tokenData = {
      "token": resp["token"],
      "expire": DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch
    };
    await ss.setPrefItem("user_agora_token", jsonEncode(tokenData), isStoreOnline: true);
    return resp["token"];
  }

  Future<String> fetchStreamKey(int uid) async {
    final res = await GeneralUtils().makeRequest("fetchagorastreamkey?uid=$uid&channel=$channel", {}, method: "get");
    // print(res.body);
    if(res.statusCode != 200) {
      return "";
    }

    final resp = jsonDecode(res.body);
    Map<String, dynamic> tokenData = {
      "token": resp["streamkey"],
      "expire": DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch
    };
    await ss.setPrefItem("user_agora_streamkey", jsonEncode(tokenData), isStoreOnline: true);
    return resp["streamkey"];
  }


  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
            (AuthState? previousState, AuthState newState) {
          if (newState is UnauthenticatedState) {
            Navigator.of(context).pushReplacementNamed('/login');
          } else if (newState is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 4,
                backgroundColor: Colors.red,
                content: Text(
                  newState.message,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }
        });
    final state = ref.watch(livestreamNotifierProvider);
    return Scaffold(
        body: PopScope(canPop: false, onPopInvoked: (pop){
          // onLeavingPage();
        }, child: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(0),
              child: state.loading ? isLoadingView() : state.hasEnded ? endedLivestream() : Stack(
                children: [
                  displayVideoView(),
                  headerLayout(),
                  bottomLayerLayout(),
                  livestreamButtons()
                ],
              ),
            ),
          )
        ))
    );
  }

  Widget headerLayout() {
    if(GeneralUtils().userUid == widget.livestream.userUid) {
      if(!_localUserJoined) {
        return const SizedBox();
      }
    }
    if(GeneralUtils().userUid != widget.livestream.userUid) {
      if(_remoteUid == null) {
        return const SizedBox();
      }
    }
    return Padding(padding: const EdgeInsets.all(24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
      SizedBox(
        width: (MediaQuery.of(context).size.width - 48) / 2.2,
        child: Text(
          widget.livestream.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: titleStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 16
          ),
        ),
      ),
        Wrap(
          runSpacing: 0,
          spacing: 10,
          children: [
            Chip(
              label: Text("LIVE", maxLines: 1, overflow: TextOverflow.ellipsis,
                style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              backgroundColor: AppColors.secondaryBase,
              side: BorderSide.none,
            ),
            GestureDetector(
                onTap: displayViewers,
                child: Chip(
              label: Row(
                children: [
                  SvgPicture.asset("assets/svg/eye_on.svg", height: 12, color: Colors.white,),
                  const SizedBox(width: 5,),
                  Text(GeneralUtils().shortenLargeNumber(num: totalViews.toDouble()), maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: AppColors.grayColor,
              side: BorderSide.none,
            ))
          ],
        ),
        GestureDetector(
          onTap: () async {
            final res = await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (BuildContext context) {
                return MultipleOptionsBottomSheet("livestream", isHost: GeneralUtils().userUid == widget.livestream.userUid,);
              },
            );
            if(res == "Club Details") {
              final getClub = await FirebaseFirestore.instance.collection("clubs").doc(widget.livestream.userUid).get();
              if(!getClub.exists) {
                return;
              }
              final club = Club.fromDocument(getClub);
              Navigator.of(context).pushNamed("/club_details", arguments: club);
              return;
            }
            if(res == "Copy Link") {
              await Clipboard.setData(ClipboardData(text: widget.livestream.link));
              GeneralUtils.showToast("Copied!");
              return;
            }
            if(res == "Share Livestream") {
              String body = "Club ${widget.livestream.clubName} is live now. Join with this link.\n\n${widget.livestream.link}";
              Share.share(body);
              return;
            }
            if(res == "Report Club") {
              final reportDialog = ReportDialog(widget.livestream.userUid, "user");
              reportDialog.displayReportDialog(context, "Attention", "Please enter details about this report");
              return;
            }
          },
          child: const Icon(Icons.more_vert, color: Colors.white, size: 24,),
        ),
        GestureDetector(
          onTap: onLeavingPage,
          child: const Icon(Icons.clear, color: Colors.white, size: 24,),
        )
      ],
    ),);
  }

  Widget bottomLayerLayout() {
    if(GeneralUtils().userUid == widget.livestream.userUid) {
      if(!_localUserJoined) {
        return const SizedBox();
      }
    }
    if(GeneralUtils().userUid != widget.livestream.userUid) {
      if(_remoteUid == null) {
        return const SizedBox();
      }
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        // color: Colors.redAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.8,
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if(GeneralUtils().userUid == widget.livestream.userUid) {
                        return;
                      }
                      Map<String, dynamic> user = {
                        "uid": comment.userUid,
                        "first_name": comment.firstName,
                        "last_name": comment.lastName,
                        "picture": comment.picture,
                        "allow_conversations": comment.allowConversations,
                      };
                      Navigator.of(context).pushNamed("/user_profile", arguments: user);
                    },
                    child: GeneralUserAvatar(38, userUid: comment.userUid, clickable: false, avatarData: comment.picture),
                  ),
                  title: Text("${comment.firstName} ${comment.lastName}", style: bodyStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700),),
                  subtitle: Text(comment.commentBody, style: bodyStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w400),),
                );
              }, itemCount: comments.length, scrollDirection: Axis.vertical, controller: _scrollController,),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                title: Container(
                  height: 50.0,
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _commentBodyController,
                    // focusNode: focusNode,
                    maxLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: titleStyle.copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Comment",
                        hintStyle: titleStyle.copyWith(color: Colors.white),
                        labelStyle: titleStyle.copyWith(
                          color: Colors.white,
                        ),
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: submitComment,
                  child: SvgPicture.asset("assets/svg/share.svg", color: Colors.white,),
                ),
                // trailing: Container(
                //     margin: const EdgeInsets.only(top: 15.0),
                //     child: )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayVideoView() {
    if(GeneralUtils().userUid == widget.livestream.userUid) {
      return Center(
        child: _localUserJoined
            ? AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        )
            : isLoadingView(),
      );
    }
    return _remoteVideo();
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channel),
        ),
      );
    } else {
      return isLoadingView();
    }
  }

  Widget isLoadingView() {
    return Align(
      alignment: Alignment.center,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(
          //   'Please wait for the club host to \nstart streaming',
          //   textAlign: TextAlign.center,
          //   style: bodyStyle.copyWith(color: AppColors.grey900),
          // ),),
          const CircularProgressIndicator(),
          const SizedBox(height: 5,),
          TextButton(
              onPressed: () async {
                try {
                  if(GeneralUtils().userUid == widget.livestream.userUid) {
                    await updateLivestream({"has_ended": true});
                  }
                  await _engine.leaveChannel();
                  await _engine.release();
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch(e) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
              child: Text(
                'Close',
                textAlign: TextAlign.center,
                style: bodyStyle.copyWith(color: AppColors.alertDangerTextColor),
              ))
        ],
      ),
    );
  }

  Widget livestreamButtons() {
    if(GeneralUtils().userUid != widget.livestream.userUid) {
      return const SizedBox();
    }
    return Positioned(
      top: MediaQuery.of(context).size.height / 3.5,
      right: 5,
      child: Column(
        children: [
          GestureDetector(
              onTap: () async {
                try {
                  await _engine.muteLocalAudioStream(!micMuted);
                  setState(() {
                    micMuted = !micMuted;
                  });
                } catch(e) {
                  debugPrint("$e");
                }
              },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.primaryBase.withOpacity(0.4)
                ),
                child: Center(
                  child: (micMuted) ? const Icon(Icons.mic_off_outlined, color: Colors.white,) : const Icon(Icons.mic_none_outlined, color: Colors.white,),
                ),
              )
          ),
          GestureDetector(
            onTap: () async {
              try {
                await _engine.switchCamera();
              } catch(e) {
                debugPrint("$e");
              }
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(top: 15, right: 24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.primaryBase.withOpacity(0.4)
              ),
              child: const Center(
                child: Icon(Icons.cameraswitch_outlined, color: Colors.white,),
              ),
            ),
          ),
          if(canSetBackgroundImage)
            GestureDetector(
              onTap: () async {
                try {
                  if(isBackgroundImageSet) {
                    await _engine.enableVirtualBackground(enabled: false,
                      backgroundSource: const VirtualBackgroundSource(),
                      segproperty: const SegmentationProperty(),
                    );
                    setState(() {
                      isBackgroundImageSet = false;
                    });
                    return;
                  }
                  final ImagePicker picker = ImagePicker();
                  final result = await picker.pickImage(source: ImageSource.gallery);
                  if(result == null) {
                    return;
                  }

                  final virtualBackgroundSource = VirtualBackgroundSource(
                    backgroundSourceType: BackgroundSourceType.backgroundImg,
                    source: result.path,
                  );

                  const segmentationProperty = SegmentationProperty(
                    modelType: SegModelType.segModelAi,
                    greenCapacity: 0.5,
                  );

                  setState(() {
                    // Enable or disable virtual background
                    _engine.enableVirtualBackground(
                        enabled: true,
                        backgroundSource: virtualBackgroundSource,
                        segproperty: segmentationProperty);
                    isBackgroundImageSet = true;
                  });
                } catch(e) {
                  debugPrint("$e");
                }
              },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(top: 15, right: 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.primaryBase.withOpacity(0.4)
                ),
                child: Center(
                  child: isBackgroundImageSet ? const Icon(Icons.hide_image_outlined, color: Colors.red,) : const Icon(Icons.image_outlined, color: Colors.white,),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget endedLivestream() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60,),
          Image.asset("assets/images/empty_livestream.png", height: MediaQuery.of(context).size.height / 2.5,),
          Text("Livestream has ended!", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          TextButton(onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          }, child: Text("Go to home to view other livestreams", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),)
          // const SizedBox(height: 10,),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("Tap on the ", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
          //     SvgPicture.asset("assets/svg/add.svg"),
          //     Text(" icon to start a livestream", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
          //   ],
          // )
        ],
      ),
    );
  }

  Future<void> onLeavingPage() async {
    if(GeneralUtils().userUid == widget.livestream.userUid) {
      await showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomSheetMultipleResponses(
                imageName: "",
                title: "Attention",
                subtitle: "Are you sure you want to end this livestream?",
                buttonTitle: "Yes, End it",
                cancelTitle: "Cancel",
                onPress: () {
                  Navigator.of(context).pop();
                  _dispose();
                },
                titleStyle: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
          },
          isDismissible: false,
          showDragHandle: true,
          enableDrag: false);
      return;
    }
    _dispose();
  }

  Future<void> updateLivestream(Map<String, dynamic> livestreamData, {bool createUserDocument = false}) async {
    try {
      await FirebaseFirestore.instance
          .collection('livestreams')
          .doc(widget.livestream.id).update(livestreamData);

      if(createUserDocument) {
        await FirebaseFirestore.instance
            .collection('livestreams')
            .doc(widget.livestream.id).collection("joined-users").doc(GeneralUtils().userUid).set({
          "id": GeneralUtils().userUid,
          "first_name": userData["first_name"],
          "last_name": userData["last_name"],
          "allow_search_visibility": userData["allow_search_visibility"] ?? true,
          "allow_conversations": userData["allow_conversations"] ?? "allow",
          "picture": userData["picture"],
          "timestamp": FieldValue.serverTimestamp(),
          "created_date": DateTime.now().toString(),
          "modified_date": DateTime.now().toString(),
        });
      }
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Future<void> submitComment() async {
    if(_commentBodyController.text.trim().isEmpty) {
      return;
    }
    final key = FirebaseFirestore.instance.collection('livestream_comments').doc().id;
    final comment = Comment(id: key, livestreamId: widget.livestream.id!, userUid: GeneralUtils().userUid ?? "", firstName: userData["first_name"], lastName: userData["last_name"], allowConversations: userData["allow_conversations"] ?? "allow", commentBody: _commentBodyController.text.trim(), picture: userData["picture"], timestamp: FieldValue.serverTimestamp(), createdDate: DateTime.now().toString(), modifiedDate: DateTime.now().toString());
    await FirebaseFirestore.instance.collection('livestream_comments').doc(key).set(comment.toJson());
    setState(() {
      _commentBodyController.clear();
    });
  }
  
  Future<void> uploadLivestreamToCloud(Map<String, dynamic> data) async {
    final file = File(data["path"]);
    final reference = FirebaseStorage.instance.ref().child("livestream-videos").child(file.path.split("/").last);
    final UploadTask uploadTask = reference.putFile(file);
    final String downloadUrl = await uploadTask.then(
          (snapShot) => snapShot.ref.getDownloadURL(),
    );
    // save to firestore
    String key = FirebaseFirestore.instance.collection("livestream_videos").doc().id;
    await FirebaseFirestore.instance.collection("livestream_videos").doc(key).set({
      "id": key,
      "livestream_id": data["livestream_id"],
      "livestream_channel_name": data["livestream_channel_name"],
      "user_uid": data["user_uid"],
      "assets": [
        {
          "url": downloadUrl,
          "thumbnailUrl": "",
          "fileType": "video"
        }
      ],
      "created_date": DateTime.now().toString(),
      "modified_date": DateTime.now().toString(),
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> displayViewers() async {
    if(joinedUsers.isEmpty) {
      return;
    }
    // DraggableScrollableSheet(
    //   builder: (c,s) {
    //     return Container(
    //       clipBehavior: Clip.hardEdge,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).canvasColor,
    //         borderRadius: const BorderRadius.only(
    //           topLeft: Radius.circular(25),
    //           topRight: Radius.circular(25),
    //         ),
    //       ),
    //     );
    //   },
    // );
    showModalBottomSheet(context: context, builder: (c) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        color: Colors.white,
        child: ListView.builder(
            itemBuilder: (c,i) {
              final joinedUser = joinedUsers[i];
          return ListTile(
            leading: GestureDetector(
              onTap: () {
                if(GeneralUtils().userUid == widget.livestream.userUid) {
                  return;
                }
                Map<String, dynamic> user = {
                  "uid": joinedUser["id"],
                  "first_name": joinedUser["first_name"],
                  "last_name": joinedUser["last_name"],
                  "picture": joinedUser["picture"],
                  "allow_conversations": joinedUser["allow_conversations"],
                };
                Navigator.of(context).pushNamed("/user_profile", arguments: user);
              },
              child: GeneralUserAvatar(38, userUid: joinedUser["id"], clickable: false, avatarData: joinedUser["picture"]),
            ),
            title: Text("${joinedUser["first_name"]} ${joinedUser["last_name"]}", style: bodyStyle.copyWith(color: AppColors.titleTextColor, fontWeight: FontWeight.w700),),
            // subtitle: Text(comment.commentBody, style: bodyStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w400),),
          );
        },
          scrollDirection: Axis.vertical,
          itemCount: joinedUsers.length,
          clipBehavior: Clip.hardEdge,
        ),
      );
    },
      barrierLabel: "Dismiss",
      isDismissible: true,
      showDragHandle: true,
      enableDrag: true,
      isScrollControlled: true,
    );
    // final res = await showModalBottomSheet(
    //   context: context,
    //   backgroundColor: Colors.white,
    //   builder: (BuildContext context) {
    //     return MultipleOptionsBottomSheet("livestream");
    //   },
    // );
  }
}