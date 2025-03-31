import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:vwave_new/presentation/stories/providers/story_notifier_provider.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';

import '../../../constants.dart';
import '../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/user_avatar.dart';
import '../models/story.dart';
import 'dart:math' as math;

import '../widgets/linear_progress_indicator.dart';

class ViewStoryPage extends ConsumerStatefulWidget {
  final StoryFeed storyFeed;
  final int initPage;
  final Function() onStoryViewEnded;
  final Function(VideoPlayerController videoController) onVideoInitialized;
  const ViewStoryPage(this.storyFeed,
      {super.key,
      required this.onStoryViewEnded,
      required this.onVideoInitialized,
      this.initPage = 0});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends ConsumerState<ViewStoryPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  late StoryFeed storyFeed;
  int currentStoryDisplayed = 0;

  bool showOtherWidgets = true;
  Map<String, dynamic> userData = {};

  // final PageController _pageController = PageController(initialPage: 0);
  // CachedVideoPlayerPlusController? _videoController;
  
  VideoPlayerController? _videoController;
  StorageSystem ss = StorageSystem();

  Timer? timer;
  int currentTimerDuration = 1;

  int maxStoryViewDuration = 5; // for general

  int maxStoryViewDurationForImages = 5; // for images

  late SharedPreferences prefs;

  List<Map<String, dynamic>> mediaViewedUsers = [];

  // bool setVideoControllerCalled = false;
  // bool startPlaying = false;

  // List<double> linearProgressBarValues = [];
  // List<GlobalKey> linearProgressBarKeys = [];

  Future<void> remoteConfigInit() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'max_story_view_duration_inSeconds': 5,
      });
      await remoteConfig.fetchAndActivate();
      final current = remoteConfig.getInt("max_story_view_duration_inSeconds");
      setState(() {
        maxStoryViewDurationForImages = current;
      });
    } catch (e, _) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    storyFeed = widget.storyFeed;
    getUpdatedStory();
    print("story feed reset ->>>>>>> ${storyFeed.files.length}");
    // startBackgroundTask();
    // _pageController = PageController(initialPage: widget.initPage);
    WidgetsBinding.instance.addObserver(this);
    // linearProgressBarValues = List.generate(storyFeed.files.length, (index) => 0);
    // linearProgressBarKeys = List.generate(storyFeed.files.length, (index) => GlobalKey());
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      for (var file in storyFeed.files) {
        if (!mounted) return;
        setState(() {
          file["linearProgressBarValue"] = 0.0;
        });
      }
      String getUser = (await ss.getItem('user'))!;
      userData = jsonDecode(getUser);

      remoteConfigInit();
      final viewedStoriesInBoolean = storyFeed.files.map((e) => hasViewedStory(storyFeed.id!, e["id"])).toList(); // t t f
      // print("getIndexOfFalse is $viewedStoriesInBoolean");
      final getIndexOfFalse = viewedStoriesInBoolean.indexWhere((element) => !element);
      // print("getIndexOfFalse is $getIndexOfFalse");
      if(getIndexOfFalse < 0) {
        startTimer();
        return;
      }

      for(int i = 0; i < getIndexOfFalse; i++) {
        storyFeed.files[i]["linearProgressBarValue"] =
        1.0;
      }

      setState(() {
        currentStoryDisplayed = getIndexOfFalse;
      });

      startTimer();

    });
  }

  void getUpdatedStory() {
    Future.delayed(Duration.zero, () {
      final updatedStories = ref.read(storyNotifierProvider.notifier).getCurrentStoryFeeds();
      final currentSF = updatedStories.singleWhere((element) => element.id == widget.storyFeed.id); // do not update
      setState(() {
        storyFeed = storyFeed.copyWith(files: currentSF.files);
      });
    });
  }

  bool hasViewedStory(String storyId, String mediaId) {
    return prefs.getBool("$storyId/$mediaId") ?? false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (timer != null) {
      timer?.cancel();
    }
    if (_videoController != null) {
      // print("destroyed ==========================1111111111111111111111111111");
      _videoController!.dispose();
    }
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (timer != null) {
        timer?.cancel();
      }
      if (storyFeed.files[currentStoryDisplayed]["filetype"] ==
          "video") {
        if (_videoController != null) {
          _videoController?.pause();
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      if (storyFeed.files[currentStoryDisplayed]["filetype"] ==
          "video") {
        if (_videoController != null) {
          _videoController?.play();
        }
      }
      startTimer();
    }
  }
  // #enddocregion AppLifecycle

  void pauseTimer() {
    if (timer == null) {
      return;
    }
    if (_videoController != null) {
      _videoController?.pause();
    }
    timer?.cancel();
  }

  void resumeTimer() {
    if (_videoController != null) {
      _videoController?.play();
    }
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: GeneralUtils().userUid == storyFeed.userUid ? FloatingActionButton(onPressed: deleteStory, child: const Icon(Icons.delete_forever),) : null,
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: setupPageViewForStoryMedia(),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    gestureTaps("left"),
                    gestureTaps("middle"),
                    gestureTaps("right"),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  buildLinearProgress(),
                  buildUserProfile(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteStory() async {
    pauseTimer();
    bool? isDeleted = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return BottomSheetMultipleResponses(
              imageName: "",
              title: "Delete Story",
              subtitle: "Are you sure you want to delete this story?",
              buttonTitle: "Yes, Delete",
              cancelTitle: "Cancel",
              onCancelPress: () {
                Navigator.of(context).pop(false);
              },
              onPress: () async {
                Navigator.of(context).pop(true);
              },
              titleStyle: subHeadingStyle.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
        },
        isDismissible: false,
        showDragHandle: true,
        enableDrag: false);
    isDeleted ??= false;
    if(isDeleted) {
      await ref.read(storyNotifierProvider.notifier).deleteStory(widget.storyFeed, currentStoryDisplayed);
      // final newFiles = storyFeed.files.where((file) => file["id"] != storyFeed.files[currentStoryDisplayed]["id"]).toList();
      // setState(() {
      //   storyFeed = storyFeed.copyWith(files: newFiles);
      //   if(currentStoryDisplayed >= 1){
      //     currentStoryDisplayed--;
      //   }
      // });
      // GeneralUtils.showToast("Story deleted.");
      onRightSidePressed();
    } else{
      resumeTimer();
    }
  }

  Widget gestureTaps(String side) {
    final sidesWidth = {
      "left": MediaQuery.of(context).size.width / 4,
      "middle": MediaQuery.of(context).size.width / 2,
      "right": MediaQuery.of(context).size.width / 4,
    };
    return GestureDetector(
      onTap: () {
        if (side == "left") {
          onLeftSidePressed();
        }
        if (side == "right") {
          onRightSidePressed();
        }
      },
      onLongPressStart: (e) {
        if (!mounted) return;
        setState(() {
          showOtherWidgets = false;
        });
        pauseTimer();
      },
      onLongPressEnd: (e) {
        if (!mounted) return;
        setState(() {
          showOtherWidgets = true;
        });
        resumeTimer();
      },
      child: Container(
        width: sidesWidth[side],
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
      ),
    );
  }

  Future<void> onLeftSidePressed() async {
    if (currentStoryDisplayed - 1 < 0) {
      return;
    }
    if (!mounted) return;

    if (timer != null) {
      timer?.cancel();
    }
    setState(() {
      Map<String, dynamic> file =
      storyFeed.files[currentStoryDisplayed - 1];
      if (file["filetype"] == "video") {
        // maxStoryViewDuration = (maxVideoRecordingDuration.toDouble() / 1000).ceil();
        double duration = double.parse("${file["duration"]}");
        maxStoryViewDuration = (duration / 1000).ceil();
      }
      storyFeed.files[currentStoryDisplayed]["linearProgressBarValue"] =
      0.0;
      storyFeed.files[currentStoryDisplayed - 1]
      ["linearProgressBarValue"] = 0.0;
      currentTimerDuration = 1;
      currentStoryDisplayed--;
    });
    destroyVideoPlayer();
    // await setStoryMediaViewed();
    await startTimer();
  }

  Future<void> onMiddleSidePressed() async {}

  Future<void> onRightSidePressed() async {
    if (currentStoryDisplayed + 1 > (storyFeed.files.length - 1)) {
      // Navigator.of(context).pop();
      widget.onStoryViewEnded();
      return;
    }
    if (!mounted) return;
    if (timer != null) {
      timer?.cancel();
    }
    setState(() {
      Map<String, dynamic> file =
      storyFeed.files[currentStoryDisplayed + 1];
      if (file["filetype"] == "video") {
        // maxStoryViewDuration = (maxVideoRecordingDuration.toDouble() / 1000).ceil();
        double duration = double.parse("${file["duration"]}");
        maxStoryViewDuration = (duration / 1000).ceil();
      }
      storyFeed.files[currentStoryDisplayed]["linearProgressBarValue"] =
      1.0;
      currentTimerDuration = 1;
      currentStoryDisplayed++;
    });
    destroyVideoPlayer();
    // await setStoryMediaViewed();
    await startTimer();
  }

  Future<void> startTimer() async {
    // print("currentStoryDisplayed is $currentStoryDisplayed==============================================");
    // print("current files is ${storyFeed.files[currentStoryDisplayed]}==============================================");
    if (timer != null) {
      timer?.cancel();
    }
    if (storyFeed.files[currentStoryDisplayed]["filetype"] == "video") {
      double duration = double.parse("${storyFeed.files[currentStoryDisplayed]["duration"]}");
      if (!mounted) return;
      setState(() {
        maxStoryViewDuration = (duration / 1000).ceil();
      });
      // print("duration is $maxStoryViewDuration");
      if(_videoController == null) {
        initializeVideoPlayer();
        return;
      }
      // if (_videoController != null) {
      //   // print("video controller initialization is ${_videoController!.value.isInitialized} =================================");
      //   if (!_videoController!.value.isInitialized) {
      //     await Future.delayed(const Duration(seconds: 1), () {
      //       startTimer();
      //     });
      //     return;
      //   }
      //   _videoController!.play();
      //   await setStoryMediaViewed();
      // } else {
      //   await Future.delayed(const Duration(seconds: 1), () {
      //     if(!setVideoControllerCalled) {
      //       initializeVideoPlayer();
      //     }
      //     startTimer();
      //   });
      // }
    } else {
      maxStoryViewDuration = maxStoryViewDurationForImages == 0 ? 5 : maxStoryViewDurationForImages;
      setStoryMediaViewed();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // print("current timer tick is set to ${t.tick} and currentTimerDuration is $currentTimerDuration");
      // if(t.tick == maxStoryViewDuration) { // t.tick
      // print("{'tick': ${t.tick}, 'currentTimerDuration': $currentTimerDuration, 'maxStoryViewDuration': $maxStoryViewDuration, 'linearProgressBarValue': ${ storyFeed.files[currentStoryDisplayed]["linearProgressBarValue"] ?? 0}");
      // int i = t.tick;
      // print("timer tick = ${timer!.tick}");
      // print("timer tick t = ${t.tick}");
      if (currentTimerDuration > maxStoryViewDuration) {
        destroyVideoPlayer();
        t.cancel();
        // timer?.cancel();
        if (!mounted) return;
        currentTimerDuration = 1;
        // setState(() {
        //
        //   // linearProgressBarValues[currentStoryDisplayed] = 0;
        // });
        onRightSidePressed();
        // Future.delayed(Duration(milliseconds: 500), () {
        // });
        return;
      }
      if (!mounted) return;
      setState(() {
        //t.tick;
        storyFeed.files[currentStoryDisplayed]
            ["linearProgressBarValue"] = currentTimerDuration / maxStoryViewDuration;
        // linearProgressBarValues[currentStoryDisplayed] = currentTimerDuration / maxStoryViewDuration;
      }); // = currentTimerDuration + 1;
      // linearProgressIndicatorController.add({"barId": storyFeed.files[currentStoryDisplayed]["id"], "value": currentTimerDuration / maxStoryViewDuration});

      currentTimerDuration++;
      // print("current linearProgressBarValues is set to $currentTimerDuration/$maxStoryViewDuration = ${(currentTimerDuration/maxStoryViewDuration)}");
    });
  }

  void destroyVideoPlayer() {
    if(!mounted) return;
    setState(() {
      if (_videoController != null) {
        _videoController!.dispose();
        _videoController = null;
        // setVideoControllerCalled = false;
      }
    });

  }

  Future<void> uploadViewedUser() async {
    try {
      if(GeneralUtils().userUid == storyFeed.userUid) {
        return;
      }
      // final token = RootIsolateToken.instance;

      final Map<String, dynamic> storyUserData = {
        "id": GeneralUtils().userUid,
        "storyId": storyFeed.id,
        "mediaId": storyFeed.files[currentStoryDisplayed]["id"],
        "first_name": userData["first_name"],
        "last_name": userData["last_name"],
        "allow_search_visibility": userData["allow_search_visibility"] ?? true,
        "allow_conversations": userData["allow_conversations"] ?? "allow",
        "picture": userData["picture"],
        "timestamp": FieldValue.serverTimestamp(),
        "created_date": DateTime.now().toString(),
        "modified_date": DateTime.now().toString(),
      };

      // final Map<String, dynamic> computeData = {
      //   "token": token,
      //   "story": widget.storyFeed,
      //   "currentStoryDisplayed": currentStoryDisplayed,
      //   "storyUserData": storyUserData,
      // };
      //
      // await compute(uploadViewedUserBackgroundProcess, computeData);
      await ref.read(storyNotifierProvider.notifier).uploadStoryViewData(storyUserData, storyFeed.id!, storyFeed.files[currentStoryDisplayed]["id"]);
    } catch(e) {

    }
  }

  Future<void> fetchViewedUsers() async {
    if(GeneralUtils().userUid != storyFeed.userUid) {
      return;
    }
    // final token = RootIsolateToken.instance;
    // final Map<String, dynamic> computeData = {
    //   "token": token,
    //   "story": widget.storyFeed,
    //   "currentStoryDisplayed": currentStoryDisplayed,
    // };
    // List<Map<String, dynamic>> users = await compute(fetchViewedUsersBackgroundProcess, computeData);
    List<Map<String, dynamic>> users = await ref.read(storyNotifierProvider.notifier).getViewedUsersList(storyFeed.id!, storyFeed.files[currentStoryDisplayed]["id"]);
    if(!mounted) return;
    setState(() {
      mediaViewedUsers = users;
    });
  }

  // Future<void> getViewedUsersCountOld() async {
  //   if (storyFeed.files[currentStoryDisplayed]["views_count"] == null) {
  //     int viewsCount = await ref.read(storyNotifierProvider.notifier).getViewedUsersCount(storyFeed.id!, storyFeed.files[currentStoryDisplayed]["id"]);
  //     if(!mounted) return;
  //     setState(() {
  //       storyFeed.files[currentStoryDisplayed]["views_count"] = viewsCount;
  //     });
  //   }
  // }

  Future<void> setStoryMediaViewed() async {
    uploadViewedUser();
    Map<String, dynamic> file = storyFeed.files[currentStoryDisplayed];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("${storyFeed.id}/${file["id"]}", true);
    // print(storyFeed.files[currentStoryDisplayed]);
  }

  Widget setupPageViewForStoryMedia() {
    return displayStoryMedia();
    // return PageView.builder(
    //     scrollDirection: Axis.horizontal,
    //     controller: _pageController,
    //     physics: const NeverScrollableScrollPhysics(),
    //     onPageChanged: (i) {
    //       // setState(() {
    //       //   currentStoryDisplayed = i;
    //       // });
    //     },
    //     itemCount: storyFeed.files.length,
    //     itemBuilder: (context, index) {
    //       return displayStoryMedia();
    //     });
  }

  Widget displayStoryMedia() {
    Map<String, dynamic> file = storyFeed.files[currentStoryDisplayed];
    String url = file["url"];

    if (file["filetype"] == "image") {
      return CachedNetworkImage(
        fit: BoxFit.contain,
        imageUrl: url,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
          backgroundColor: AppColors.grey50,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
        )),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    return displayVideoView();
    // return VideoDisplayWidget(storyFeed.files[currentStoryDisplayed]["url"], type: "network", thumbnailUrl: storyFeed.files[currentStoryDisplayed]["thumbnailUrl"], onVideoPlayerController: (controller) {
    //   _videoController = controller;
    // },);
  }

  Widget displayVideoView() {
    Map<String, dynamic> file = storyFeed.files[currentStoryDisplayed];

    if (_videoController == null) {
      return loadingVideoView(file);
    }

    if (_videoController!.value.isInitialized) {
      return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!));
    }

    return loadingVideoView(file);
  }

  Widget loadingVideoView(Map<String, dynamic> file) {
    return Stack(
      children: [
        (file["thumbnailUrl"].isNotEmpty)
            ? CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: file["thumbnailUrl"],
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const SizedBox(),
        const Center(
            child: CircularProgressIndicator(
          backgroundColor: AppColors.grey50,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
        ))
      ],
    );
  }

  Widget buildLinearProgress() {
    return Visibility(
      visible: showOtherWidgets,
      maintainAnimation: true,
      maintainState: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
        opacity: showOtherWidgets ? 1 : 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: storyFeed.files.map((file) {
              return SizedBox(
                key: GlobalObjectKey(
                    "${file["id"]}/${math.Random().nextInt(999999999)}"),
                width: ((MediaQuery.of(context).size.width - 20) -
                        (storyFeed.files.length * 5)) /
                    storyFeed.files.length,
                height: 2,
                child: //ProgressIndicatorWidget(maxStoryViewDuration)
                // ProgressIndicatorWidget(file["id"]),
                LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value: file["linearProgressBarValue"] ?? 0.0,
                  borderRadius: BorderRadius.circular(8),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondaryBase),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildUserProfile() {
    Map<String, dynamic> file = storyFeed.files[currentStoryDisplayed];
    String? date = GeneralUtils()
        .returnFormattedDate(file["created_date"], storyFeed.timeZone);
    return Visibility(
        visible: showOtherWidgets,
        maintainAnimation: true,
        maintainState: true,
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
            opacity: showOtherWidgets ? 1 : 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                onTap: () async {
                  Map<String, dynamic> user = {
                    "uid": storyFeed.userUid,
                    "first_name": storyFeed.firstName,
                    "last_name": storyFeed.lastName,
                    "picture": storyFeed.previewImage,
                    "allow_conversations":
                        storyFeed.otherDetails["allow_conversations"],
                  };
                  pauseTimer();
                  await Navigator.of(context)
                      .pushNamed("/user_profile", arguments: user);
                  resumeTimer();
                },
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: GeneralUserAvatar(
                    40,
                    avatarData: storyFeed.previewImage,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 10,
                title: Text(
                  storyFeed.previewTitle["en"], // + "-" + "${currentStoryDisplayed+1} of ${storyFeed.files.length}"
                  textAlign: TextAlign.start,
                  style: captionStyle.copyWith(color: Colors.white),
                ),
                subtitle: Text(
                  date ?? "",
                  textAlign: TextAlign.start,
                  style: captionStyle.copyWith(color: Colors.white),
                ),
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (GeneralUtils().userUid == storyFeed.userUid) ? Wrap(
                      runSpacing: 0,
                      spacing: 10,
                      children: [
                        GestureDetector(
                            onTap: displayViewers,
                            child: Chip(
                              label: Row(
                                children: [
                                  SvgPicture.asset("assets/svg/eye_on.svg", height: 12, color: Colors.white,),
                                  const SizedBox(width: 5,),
                                  Text(GeneralUtils().shortenLargeNumber(num: getTotalViewedMediaStory()), maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.grayColor,
                              side: BorderSide.none,
                            ))
                      ],
                    ) : const SizedBox(),
                    SizedBox(width: (GeneralUtils().userUid == storyFeed.userUid) ? 10 : 0,),
                    NavBackButton(
                      color: Colors.white,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPress: () {
                        if (timer != null) {
                          timer!.cancel();
                        }
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            )));
  }

  double getTotalViewedMediaStory() {
    String mediaId = storyFeed.files[currentStoryDisplayed]["id"];
    if(storyFeed.viewsCount == null) {
      return 0.0;
    }
    if(storyFeed.viewsCount![mediaId] == null) {
      return 0.0;
    }
    return double.parse("${storyFeed.viewsCount![mediaId]}");
  }

  Future<void> displayViewers() async {
    if(getTotalViewedMediaStory() == 0) {
      return;
    }

    if(mediaViewedUsers.isEmpty) {
      await fetchViewedUsers();
    }

    pauseTimer();

    await showModalBottomSheet(context: context, builder: (c) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        color: Colors.white,
        child: ListView.builder(
          itemBuilder: (c,i) {
            final viewedUser = mediaViewedUsers[i];
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  Map<String, dynamic> user = {
                    "uid": viewedUser["id"],
                    "first_name": viewedUser["first_name"],
                    "last_name": viewedUser["last_name"],
                    "picture": viewedUser["picture"],
                    "allow_conversations": viewedUser["allow_conversations"],
                  };
                  Navigator.of(context).pushNamed("/user_profile", arguments: user);
                },
                child: GeneralUserAvatar(38, userUid: viewedUser["id"], clickable: false, avatarData: viewedUser["picture"]),
              ),
              title: Text("${viewedUser["first_name"]} ${viewedUser["last_name"]}", style: bodyStyle.copyWith(color: AppColors.titleTextColor, fontWeight: FontWeight.w700),),
              // subtitle: Text(comment.commentBody, style: bodyStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w400),),
            );
          },
          scrollDirection: Axis.vertical,
          itemCount: mediaViewedUsers.length,
          clipBehavior: Clip.hardEdge,
        ),
      );
    },
      barrierLabel: "Dismiss",
      isDismissible: true,
      showDragHandle: true,
      enableDrag: false,
      isScrollControlled: true,
    );
    resumeTimer();
  }

  Future<void> initializeVideoPlayer() async {
    // setVideoControllerCalled = true;
    // final storage = GetStorage('cached_video_player');
    // await storage.initStorage;

    Map<String, dynamic> file = storyFeed.files[currentStoryDisplayed];
    String url = file["url"];

    String fileName = url.split("?").first.split("%2F").last;

    if (_videoController != null) {
      _videoController!.dispose();
    }
    if(!mounted) return;
    // _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    var fileInfo = await FirebaseCacheManager().getSingleFile("/stories/$fileName");
    _videoController = VideoPlayerController.file(File(fileInfo.path));

    // check for compressed video file
    // final videoLocalFile = storage.read(fileName);
    //
    // if(videoLocalFile == null) {
    //   var fileInfo = await FirebaseCacheManager().getSingleFile("/stories/$fileName");
    //   _videoController = VideoPlayerController.file(File(fileInfo.path));
    //   storage.write(fileName, fileInfo.path);
    //   // if(Platform.isAndroid) {
    //   //   final mediaInfo = await VideoCompress.compressVideo(
    //   //     fileInfo.path,
    //   //     quality: VideoQuality.DefaultQuality,
    //   //     deleteOrigin: false, // It's false by default
    //   //   );
    //   //   print("compressed video path is ${mediaInfo!.path!}");
    //   //   _videoController = VideoPlayerController.file(File(mediaInfo.path!));
    //   //   storage.write(fileName, mediaInfo.path!);
    //   // } else {
    //   //   final videoFile = File.fromUri(uri);
    //   //   final value = await videoFile.readAsBytes();
    //   //   final bytes = Uint8List.fromList(value);
    //   //   String pathToFile = fileInfo.path.replaceAll(".bin", "-VIDEO_${DateTime.now().millisecondsSinceEpoch}.mp4"); ///VIDEO_${DateTime.now().millisecondsSinceEpoch}.mp4";
    //   //   var savedVideoFile = await FirebaseCacheManager().putFile(pathToFile, bytes, fileExtension: "mp4", maxAge: const Duration(days: 2));
    //   //   print("compressed video path is $pathToFile");
    //   //   _videoController = VideoPlayerController.file(savedVideoFile);
    //   //   storage.write(fileName, pathToFile);
    //   // }
    // } else {
    //   _videoController = VideoPlayerController.file(File(videoLocalFile));
    // }

    afterVideoInitialized();
  }

  void afterVideoInitialized() {
    if (_videoController == null) {
      return;
    }

    _videoController!.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _videoController!.setLooping(false);
    _videoController!.initialize().then((_) {
      _videoController!.play();
      setStoryMediaViewed();
      startTimer();
      if (!mounted) return;
      setState(() {});
    });
  }

  // not used
  Future<void> startBackgroundTask() async {
    // await FlutterIsolate.killAll();
    // return;
    // rootIsolateToken = RootIsolateToken.instance;
    print("getting firebase file ==============================================================${DateTime.now().toString()}");
    final videoFile = storyFeed.files[0];
    String url = videoFile["url"];
    String fileName = url.split("?").first.split("%2F").last;
    var file = await FirebaseCacheManager().getSingleFile("/stories/$fileName"); //gs://getvwaveapp.appspot.com
    // https://firebasestorage.googleapis.com/v0/b/getvwaveapp.appspot.com/o/stories%2F-O0THwL1ESRObMG4rEwW.mp4?alt=media&token=d8d8fa62-091c-4e9c-bf43-ef6a22a34957
    print("firebase downloading done ${file.path} ==============================================================${DateTime.now().toString()}");

    // await Future.delayed(const Duration(seconds: 1), () async {
    //   final videos = storyFeed.files.where((file) => file["filetype"] == "video").toList();
    //   if(videos.isEmpty) {
    //     return;
    //   }
    //
    //   for (var videoFile in videos) {
    //     final fileInfo = await ref.read(storyNotifierProvider.notifier).fetchCachedFile(videoFile["url"]);
    //     print('Cached video of [${videoFile["url"]}] is: ${fileInfo?.file.path}');
    //     if(fileInfo == null) {
    //       String url = videoFile["url"];
    //       runTask(url, url.split("-").last);
    //     }
    //   }
    // });
  }

  // not used
  void runTask(String url, String id) {
    // isolates.spawn<String>(initializeCacheDownloader,
    //     name: "videoFile$id",
    //     // Executed every time data is received from the spawned isolate.
    //     onReceive: setVideoId,
    //     // Executed once when spawned isolate is ready for communication.
    //     onInitialized: () => isolates.send({"url": url, "id": id}, to: "videoFile$id")
    // );
  }
}

// @pragma('vm:entry-point')
// Future<void> uploadViewedUserBackgroundProcess(Map<String, dynamic> data) async {
//   try {
//     final token = data["token"];
//     final StoryFeed storyFeed = data["story"] as StoryFeed;
//     final int currentStoryDisplayed = data["currentStoryDisplayed"] as int;
//     final Map<String, dynamic> storyUserData = data["storyUserData"] as Map<String, dynamic>;
//
//     BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
//     WidgetsFlutterBinding.ensureInitialized();
//     DartPluginRegistrant.ensureInitialized();
//     await Firebase.initializeApp();
//
//     final storyId = storyFeed.id!;
//     final mediaId = storyFeed.files[currentStoryDisplayed]["id"];
//     String id = "${GeneralUtils().userUid}-$storyId-$mediaId";
//
//     final checkViewed = await FirebaseFirestore.instance.collection("stories").doc(storyId).collection("viewed-users").doc(id).get();
//     if(checkViewed.exists) {
//       return;
//     }
//
//     await FirebaseFirestore.instance.collection("stories").doc(storyId).collection("viewed-users").doc(id).set(storyUserData);
//
//     await FirebaseFirestore.instance.collection("stories").doc(storyId).update({
//       "views_count.$mediaId": FieldValue.increment(1)
//     });
//   } catch(e) {
//     print(e);
//   }
// }

// @pragma('vm:entry-point')
// Future<List<Map<String, dynamic>>> fetchViewedUsersBackgroundProcess(Map<String, dynamic> data) async {
//   try {
//     final token = data["token"];
//     final StoryFeed storyFeed = data["story"] as StoryFeed;
//     final int currentStoryDisplayed = data["currentStoryDisplayed"] as int;
//
//     BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
//     WidgetsFlutterBinding.ensureInitialized();
//     DartPluginRegistrant.ensureInitialized();
//     await Firebase.initializeApp();
//
//     final storyId = storyFeed.id!;
//     final mediaId = storyFeed.files[currentStoryDisplayed]["id"];
//
//     final snapshot = await FirebaseFirestore.instance.collection("stories").doc(storyId).collection("viewed-users").where("storyId", isEqualTo: storyId).where("mediaId", isEqualTo: mediaId).get();
//
//     return snapshot.docs.map((doc) => doc.data()).toList();
//   }  catch(e) {
//     print(e);
//     return [];
//   }
// }

// final isolates = IsolateHandler();
String videoUrl = "";
int videoIndex = 0;

void setVideoId(String id) {
  // counter = count;

  // We will no longer be needing the isolate, let's dispose of it.
  // isolates.kill("videoFile$id");
}

@pragma('vm:entry-point')
Future<void> initializeCacheDownloader(Map<String, dynamic> data) async {
  print("data is $data =========================================");
  // final messenger = HandledIsolate.initialize(data);
  //
  // messenger.listen((message) async {
  //   print("message is $message =========================================");
  //   final cacheManager = CacheManager(Config("libCachedVideoPlayerData"));
  //   String dataSource = message["url"]; //data["url"];
  //   final storage = GetStorage('cached_video_player');
  //   await storage.initStorage;
  //
  //   // late String realDataSource;
  //   bool isCacheAvailable = false;
  //
  //   FileInfo? cachedFile = await cacheManager.getFileFromCache(dataSource);
  //
  //   print('Cached video of [$dataSource] is: ${cachedFile?.file.path}');
  //
  //   if (cachedFile != null) {
  //     final cachedElapsedMillis = storage.read('cached_video_player_video_expiration_of_${Uri.parse(dataSource)}'); //_getCacheKey(dataSource));
  //
  //     if (cachedElapsedMillis != null) {
  //       final now = DateTime.timestamp();
  //       final cachedDate = DateTime.fromMillisecondsSinceEpoch(
  //         cachedElapsedMillis,
  //       );
  //       final difference = now.difference(cachedDate);
  //
  //       print(
  //         'Cache for [$dataSource] valid till: '
  //             '${cachedDate.add(const Duration(days: 1))}',
  //       );
  //
  //       if (difference > const Duration(days: 1)) {
  //         print('Cache of [$dataSource] expired. Removing...');
  //         await cacheManager.removeFile(dataSource);
  //         cachedFile = null;
  //       }
  //     } else {
  //       print('Cache of [$dataSource] expired. Removing...');
  //       await cacheManager.removeFile(dataSource);
  //       cachedFile = null;
  //     }
  //   }
  //
  //   if (cachedFile == null) {
  //     cacheManager
  //         .downloadFile(dataSource)
  //         .then((_) {
  //       storage.write(
  //         'cached_video_player_video_expiration_of_${Uri.parse(dataSource)}',
  //         DateTime.timestamp().millisecondsSinceEpoch,
  //       );
  //       print('Cached video [$dataSource] successfully.');
  //     });
  //   } else {
  //     isCacheAvailable = true;
  //   }
  //
  //   messenger.send(message["id"]);
  // });



  // realDataSource = isCacheAvailable
  //     ? Uri.file(cachedFile!.file.path).toString()
  //     : dataSource;
}
