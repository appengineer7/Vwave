
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/report_dialog.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/user_avatar.dart';
import '../../messaging/providers/create_conversation_provider.dart';
import '../repositories/profile_repository.dart';

class SimpleUserProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  const SimpleUserProfilePage(this.user, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SimpleUserProfilePage();
}

class _SimpleUserProfilePage extends ConsumerState<SimpleUserProfilePage> {

  StorageSystem ss = StorageSystem();


  int followersCount = 0;
  int followingCount = 0;

  bool isButtonLoading = false;
  bool fetchingUser = false;
  bool isFollowingUser = false;

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
            () async {
              String getUser = (await ss.getItem('user'))!;
              if(!mounted) return;
              setState(() {
                userData = jsonDecode(getUser);
              });
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              String? userType = prefs.getString("user_type");
              if(userType != "user") {
                Navigator.of(context).pop();
                return;
              }
              fetchFriendsCount();
              checkIfFollowed();
            });

  }

  Future<void> fetchFriendsCount() async {
    final res = await GeneralUtils().makeRequest("getfriendscount?uid=${widget.user["uid"]}", {}, method: "get");
    if(res.statusCode != 200) {
      return;
    }
    final resp = jsonDecode(res.body);
    if(!mounted) return;
    setState(() {
      followersCount = resp["followers_count"];
      followingCount = resp["following_count"];
    });
  }

  Future<void> checkIfFollowed() async {
    final checkFollow = await FirebaseFirestore.instance.collection("users")
        .doc(GeneralUtils().userUid)
        .collection("following")
        .doc(widget.user["uid"]).get();
    if(!mounted) return;
    setState(() {
      isFollowingUser = checkFollow.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 24.0),
            child: GestureDetector(
              onTap: () {
                final reportDialog = ReportDialog(widget.user["uid"], "user");
                reportDialog.displayReportDialog(context, "Attention", "Please enter details about this report");
              },
              child: Text("Report user", style: bodyStyle.copyWith(color: AppColors.errorColor),),
            ),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(widget.user["picture"].isEmpty) {
                            return;
                          }
                          Navigator.of(context).pushNamed("/view_full_image", arguments: {"media": [{"fileType":"image", "url": widget.user["picture"]}], "index": 0});
                        },
                        child: GeneralUserAvatar(100,
                          avatarData: widget.user["picture"],
                          clickable: false,
                          userUid: widget.user["uid"],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${widget.user["first_name"]} ${widget.user["last_name"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: subHeadingStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  profileDetails(),
                  SizedBox(height: MediaQuery.of(context).size.height / 3.5),
                  ActionButton(
                    text: isFollowingUser ? "Unfollow" : "Follow",
                    loading: isButtonLoading,
                    backgroundColor: AppColors.primaryBase, //isFollowingUser ? AppColors.grey50 :
                    foregroundColor: Colors.white, //isFollowingUser ? AppColors.grey500 :
                    onPressed: followUser,
                  ),
                  const SizedBox(height: 24),
                  (widget.user["allow_conversations"] == "not_allow") ? const SizedBox() : ActionButton(
                    backgroundColor: AppColors.grey50,
                    foregroundColor: AppColors.grey500,
                    text: "Message",
                    loading: fetchingUser,
                    onPressed: () async {
                      if(GeneralUtils().userUid == null) {
                        GeneralUtils.showToast("Please login to continue");
                        return;
                      }
                      if(GeneralUtils().userUid == widget.user["uid"]) {
                        GeneralUtils.showToast("Cannot message this user.");
                        return;
                      }
                      // create or open conversation
                      setState(() {
                        fetchingUser = true;
                      });
                      final allowConversation = await ref.read(profileRepositoryProvider).checkConversationPrivacy(widget.user["allow_conversations"] ?? "allow", widget.user["uid"]);
                      if(!allowConversation) {
                        GeneralUtils.showToast("Cannot message this user due to their privacy settings", fontSize: 12);
                        setState(() {
                          fetchingUser = false;
                        });
                        return;
                      }
                      // final currentUser = await ref.read(profileRepositoryProvider).fetchMe();
                      if (GeneralUtils().userUid != null) {
                        final conversation = await ref
                            .read(asyncCreateConversationProvider.notifier)
                            .createOrGetConversation(
                            GeneralUtils().userUid!,
                            widget.user["uid"],
                            '${userData["first_name"]} ${userData["last_name"]}'.trim(),
                            '${widget.user["first_name"]} ${widget.user["last_name"]}'.trim(),
                            widget.user["picture"] ?? ""
                        );
                        setState(() {
                          fetchingUser = false;
                        });
                        Navigator.of(context).pushNamed('/chat', arguments: conversation);
                      }
                      setState(() {
                        fetchingUser = false;
                      });

                    },
                  )
                ],
              ))),
    );
  }

  Widget profileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/friends_list", arguments: {"type": "Followers", "uid": widget.user["uid"]});
              },
              child:
              Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                GeneralUtils().shortenLargeNumber(num: followersCount.toDouble()),
                textAlign: TextAlign.center,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "FOLLOWERS",
                    textAlign: TextAlign.center,
                    style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w400, color: AppColors.grey600),
                  ),
                  const Icon(Icons.arrow_right_rounded, color: AppColors.primaryBase,)
                ],
              )
            ],
          )),
          GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed("/friends_list", arguments: {"type": "Following", "uid": widget.user["uid"]});
              },
              child:
              Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                GeneralUtils().shortenLargeNumber(num: followingCount.toDouble()),
                textAlign: TextAlign.center,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "FOLLOWING",
                    textAlign: TextAlign.center,
                    style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w400, color: AppColors.grey600),
                  ),
                  const Icon(Icons.arrow_right_rounded, color: AppColors.primaryBase,)
                ],
              )
            ],
          )),
        ],
      ),
    );
  }

  Future<void> followUser() async {
    if(GeneralUtils().userUid == null) {
      GeneralUtils.showToast("Please login to continue");
      return;
    }
    if(GeneralUtils().userUid == widget.user["uid"]) {
      GeneralUtils.showToast("Cannot follow this user.");
      return;
    }
    setState(() {
      isButtonLoading = true;
    });
    try {
      if(isFollowingUser) {
        await FirebaseFirestore.instance.collection("users")
            .doc(GeneralUtils().userUid)
            .collection("following")
            .doc(widget.user["uid"]).delete();
        // update mutual
        final checkOtherUserFollow = await FirebaseFirestore.instance.collection("users")
            .doc(widget.user["uid"])
            .collection("followers")
            .doc(GeneralUtils().userUid).get();
        if(checkOtherUserFollow.exists) {
          await FirebaseFirestore.instance.collection("users")
              .doc(widget.user["uid"])
              .collection("followers")
              .doc(GeneralUtils().userUid)
              .update({
            "is_mutual": false,
          });
        }

        if(widget.user["notification_id"] != null) {
          await FirebaseFirestore.instance.collection("notifications").doc(widget.user["notification_id"]).update({
            "payload.is_following": false,
          });
        }
        setState(() {
          isButtonLoading = false;
          isFollowingUser = false;
        });
        return;
      }

      // update user following
      await FirebaseFirestore.instance.collection("users")
          .doc(GeneralUtils().userUid)
          .collection("following")
          .doc(widget.user["uid"])
          .set({
        "id": widget.user["uid"],
        "type": "user",
        "is_mutual": false,
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });

      //update user followers

      // check if it is mutual
      final isMutual = await FirebaseFirestore.instance.collection("users")
          .doc(widget.user["uid"])
          .collection("following")
          .doc(GeneralUtils().userUid).get();

      await FirebaseFirestore.instance.collection("users")
          .doc(widget.user["uid"])
          .collection("followers")
          .doc(GeneralUtils().userUid)
          .set({
        "id": GeneralUtils().userUid,
        "type": "user",
        "is_mutual": isMutual.exists,
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });

      if(widget.user["notification_id"] != null) {
        await FirebaseFirestore.instance.collection("notifications").doc(widget.user["notification_id"]).update({
          "payload.is_following": true,
        });
      }
      setState(() {
        isButtonLoading = false;
        isFollowingUser = true;
      });
    } catch(e) {
      setState(() {
        isButtonLoading = false;
      });
      GeneralUtils.showToast("Could not follow user. Try again.");
    }
  }
}