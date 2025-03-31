import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave_new/presentation/club/models/club.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/widgets/action_button.dart';
import 'package:vwave_new/widgets/empty_screen.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

import '../../../constants.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/user_avatar.dart';
import '../../profile/providers/profile_notifier_provider.dart';
import '../../profile/repositories/profile_repository.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreen();
}

class _NotificationScreen extends ConsumerState<NotificationScreen> {

  StreamSubscription<Object>? notificationStream;

  List<NotificationModel> notifications = [];

  late NotificationRepository notificationRepository;

  String userType = "";
  late String timeZone;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    timeZone = userCurrentTimeZone.last;
    notificationRepository = NotificationRepository(context);
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userType = prefs.getString("user_type") ?? "user";
      });
    });
    getUserNotifications();
  }

  @override
  void dispose() {
    if (notificationStream != null) {
      notificationStream!.cancel();
    }
    super.dispose();
  }

  void getUserNotifications() {
    final today = DateTime.now();
    final fromDate = today.subtract(const Duration(days: 30)); //DateTime(today.year, today.month, 1);
    // final toDate = fromDate.add(const Duration(days: 30));
    if (GeneralUtils().userUid == null || GeneralUtils().userUid == "") return;
    notificationStream = FirebaseFirestore.instance
        .collection("notifications")
        .where("user_uid", isEqualTo: GeneralUtils().userUid)
        .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
        .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((query) {
      if (query.size == 0) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      if(!mounted) return;
      notifications.clear();
      notifications = query.docs.map((doc) => NotificationModel.fromSnapshot(doc.data())).toList();
      setState(() {
        isLoading = false;
      });

      // for (var doc in query.docs) {
      //   NotificationModel nm = NotificationModel.fromSnapshot(doc.data());
      //   setState(() {
      //     notifications.add(nm);
      //   });
      // }
    });
  }

  bool isRecentNotificationOld(NotificationModel notification) {
    Timestamp t = notification.timestamp;
    final today = DateTime.now();
    final cDate = DateTime.fromMillisecondsSinceEpoch(t.seconds * 1000);
    final createdDate = GeneralUtils().returnFormattedDate(cDate.toString(), notification.time_zone ?? "Africa/Lagos", returnAgo: false);
    final notificationDatetime = DateTime.parse(createdDate);
    // print(today.difference(notificationDatetime).inDays);
    return today.isAtSameMomentAs(notificationDatetime) || today.difference(notificationDatetime).inDays <= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: userType == "club_owner" ? Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ) : null,
        title: Text("Notifications", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(child: isLoading ? const Center(child: CircularProgressIndicator(),) : (notifications.isEmpty) ? SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 0,),
                Image.asset("assets/images/empty_notification.png", height: MediaQuery.of(context).size.height / 4,),
                const SizedBox(height: 10,),
                Text("Empty", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
                const SizedBox(height: 10,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 60), child: Text("You don't have any notifications at this time", textAlign: TextAlign.center, style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),),
                const SizedBox(height: 10,),
              ],
            ),
          )) : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(24),
        // margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.builder(itemBuilder: (context, index) {
          final notification = notifications[index];
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      width: 45,
                      height: 45,
                      child: GeneralUserAvatar(
                        45.0,
                        avatarData: notification.payload?.profileImage,
                        userUid: notification.payload?.profileUid,
                        clickable: false,
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${notification.payload?.profileUsername} ",
                              style: titleStyle.copyWith(
                                  color: AppColors.grey900,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            TextSpan(
                              text: (notification.notification_type == "livestream") ? "has started a livestream. " : (notification.notification_type == "following") ? "has started following you. " : "submitted a review. ",
                              style: titleStyle.copyWith(
                                color: AppColors.grey900,
                              ),
                            ), //DateTime.fromMillisecondsSinceEpoch(notification.timestamp.seconds * 1000).toString() (timeZone == null) ? "" :
                            TextSpan(
                              text: GeneralUtils().returnFormattedDate(DateTime.fromMillisecondsSinceEpoch(notification.timestamp.seconds * 1000).toString(), "UTC"), // notification.time_zone ?? timeZone), //
                              style: titleStyle.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ]
                      ),
                    ),
                    //notification.notification_type == "following" &&
                    trailing: (userType == "club_owner") ? null : SizedBox(
                      width: 80,
                      height: 35,
                      child: (notification.notification_type == "livestream") ? ActionButton(
                        text: "Join Now",
                        padding: const EdgeInsets.all(5),
                        textStyle: captionStyle,
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBase,
                        onPressed: () {
                          final livestream = Livestream.fromJson(notification.payload?.livestreamData);
                          Navigator.of(context).pushNamed("/livestream_view", arguments: livestream);
                        }, //(userType == "club_owner") ? const SizedBox() :
                      ) : ActionButton(
                        text: notification.payload!.isFollowing! ? "Following" : "Follow",
                        padding: const EdgeInsets.all(5),
                        textStyle: captionStyle,
                        backgroundColor: notification.payload!.isFollowing! ? AppColors.grey50 : AppColors.primaryBase,
                        foregroundColor: notification.payload!.isFollowing! ? AppColors.grey500 : Colors.white,
                        onPressed: () async {
                          bool isFF = notification.payload!.isFollowing!;
                          setState(() {
                            notification.payload!.isFollowing = !notification.payload!.isFollowing!;
                          });
                          await ref.read(profileNotifierProvider.notifier).performFriendRequest(isFF, notification.payload!.followingUserUid!);
                          await notificationRepository.updateNotificationData(notification, {"payload.is_following": !isFF});
                        },
                      ),
                    ),
                    onTap: () async {
                      if(userType == "club_owner") {
                        return;
                      }
                      if(notification.notification_type == "livestream") {
                        final livestream = Livestream.fromJson(notification.payload?.livestreamData);
                        final getClub = await FirebaseFirestore.instance.collection("clubs").doc(livestream.userUid).get();
                        if(!getClub.exists) {
                          return;
                        }
                        final club = Club.fromDocument(getClub);
                        Navigator.of(context).pushNamed("/club_details", arguments: club);
                        return;
                      }
                      Map<String, dynamic> user = {
                        "uid": notification.payload!.profileUid,
                        "first_name": notification.payload!.followingUsername!.split(" ").first,
                        "last_name": notification.payload!.followingUsername!.split(" ").last,
                        "picture": notification.payload!.profileImage,
                        "allow_conversations": "allow",
                      };
                      Navigator.of(context).pushNamed("/user_profile", arguments: user);
                    },
                  ),
                  const SizedBox(height: 15,),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                    ),
                  ),
                ],
              )
          );
        },
          scrollDirection: Axis.vertical,
          itemCount: notifications.length,
          shrinkWrap: true,
        ),
      )
      ),
    );
  }
}