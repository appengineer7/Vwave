
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/presentation/club/models/club.dart';
import 'package:vwave/presentation/club/providers/club_notifier_provider.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/presentation/events/providers/club_event_notifier_provider.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../common/providers/firebase.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/multiple_options_bottom_sheet.dart';
import '../../../widgets/report_dialog.dart';
import '../../events/repositories/club_event_repository.dart';
import '../../events/widgets/club_event_cardview.dart';
import '../models/review.dart';
import '../repositories/club_repository.dart';
import '../widgets/club_review_display_widget.dart';
import '../widgets/create_new_review_bottom_sheet.dart';

class ClubDetailsPage extends ConsumerStatefulWidget {
  final Club club;
  const ClubDetailsPage(this.club, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClubDetailsPage();
}

class _ClubDetailsPage extends ConsumerState<ClubDetailsPage> {

  bool clubLiked = false;
  bool notifyLivestreams = false;
  bool isFollowingClub = false;
  bool isButtonLoading = false;

  StorageSystem ss = StorageSystem();

  final controller = PageController(initialPage: 0);
  int displayImagesIndex = 0;

  Livestream? currentLivestream;

  List<ClubEvent> upcomingEvents = [];
  Map<String, dynamic> userLocationDetails = {};

  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userType = prefs.getString("user_type");
      if(userType != "user") {
        Navigator.of(context).pop();
        return;
      }
      String? isSaved = await ss.getItem("club_${widget.club.id}");
      setState(() {
        clubLiked = isSaved == "true";
      });
      getNotificationSettings();
      checkIfFollowed();
      fetchFollowersCount();
      getCurrentLivestream();
      fetchClubUpcomingEvents();
    });
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic>? userData = jsonDecode(user);
    if (!mounted) return;
    if(userData == null) {
      return;
    }
    setState(() {
      if (userData["location_details"] != null) {
        if (userData["location_details"]["address"] == null) {
          return;
        }
        userLocationDetails =
            GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
    });
  }

  Future<void> getNotificationSettings() async {
    String? lP = await ss.getItem("notification_livestream_status_${widget.club.id}");
    setState(() {
      notifyLivestreams = lP == "true";
    });
  }

  Future<void> checkIfFollowed() async {
    final checkFollow = await FirebaseFirestore.instance.collection("users")
        .doc(GeneralUtils().userUid)
        .collection("following")
        .doc(widget.club.id).get();
    setState(() {
      isFollowingClub = checkFollow.exists;
    });
  }

  Future<void> getCurrentLivestream() async {
    final getLive = await FirebaseFirestore.instance.collection("livestreams").where("user_uid", isEqualTo: widget.club.userUid).where("has_ended", isEqualTo: false).orderBy("timestamp", descending: true).limit(1).get();
    if(getLive.docs.isEmpty) {
      return;
    }
    setState(() {
      currentLivestream = Livestream.fromDocument(getLive.docs.first);
    });
  }

  Future<void> fetchFollowersCount() async {
    final ffc = await FirebaseFirestore.instance.collection("users").doc(widget.club.userUid).collection("followers").count().get();
    setState(() {
      followersCount = ffc.count ?? 0;
    });
  }

  Future<void> fetchClubUpcomingEvents() async {
    Future.delayed(Duration.zero, () async {
      await getUserData();
      final today = DateTime.now();
      final tsTo = Timestamp.fromDate(today);
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('club_events')
          .where("club_id", isEqualTo: widget.club.id)
          .where("event_date_timestamp", isGreaterThanOrEqualTo: tsTo)
          .orderBy("created_timestamp", descending: true)
          .get();

      final events = snapshot.docs.map((e) => ClubEvent.fromJson(e.data())).toList();
      final mUpcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);
      if(!mounted) return;
      setState(() {
        upcomingEvents = mUpcomingEvents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text("Details", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () async {
                String? isSaved = await ss.getItem("club_${widget.club.id}");
                if (isSaved == "true") {
                  // await ss.deletePref("club_${widget.club.id}");
                  setState(() {
                    clubLiked = false;
                  });
                } else {
                  setState(() {
                    clubLiked = true;
                  });
                }
                ref.read(clubNotifierProvider.notifier).saveFavoriteClubs(widget.club);
              },
              child: clubLiked
                  ? SvgPicture.asset("assets/svg/heart.svg", height: 24,)
                  : SvgPicture.asset("assets/svg/heart_outline.svg", height: 24),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                child: (notifyLivestreams) ? SvgPicture.asset("assets/svg/navigation/notification_selected.svg") : SvgPicture.asset("assets/svg/navigation/notification.svg"),
                onTap: () {
                  updateNotificationSettings("livestream", !notifyLivestreams);
                },
              )),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: GestureDetector(
              child: const Icon(Icons.more_vert_rounded, color: AppColors.primaryBase,),
              onTap: () async {
                final res = await showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return MultipleOptionsBottomSheet("club", containerHeight: 250,);
                  },
                );
                if (res == "Report club") {
                  final reportDialog = ReportDialog(widget.club.userUid, "user");
                  reportDialog.displayReportDialog(context, "Attention", "Please enter details about this report");
                  return;
                }
                if (res == "Share club profile") {
                  String body = "Check out this club by clicking on this link.\n\n${widget.club.link}";
                  Share.share(body);
                  return;
                }
              },
            ),
          )
          // Padding(
          //     padding: const EdgeInsets.only(right: 24.0),
          //     child: GestureDetector(
          //       child: SvgPicture.asset("assets/svg/share.svg"),
          //       onTap: () {
          //         String body =
          //             "Check out this club by clicking on this link.\n\n${widget.club.link}";
          //         Share.share(body);
          //       },
          //     ))
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: widget.club.coverImages.length,
                          pageSnapping: true,
                          controller: controller,
                          onPageChanged: (i) {
                            setState(() {
                              displayImagesIndex = i;
                            });
                          },
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: (){
                              Navigator.of(context).pushNamed("/view_full_image", arguments: widget.club.coverImages[index]["url"]);
                            },
                            child: SizedBox(
                              child: CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                height: 180.0,
                                // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                                imageUrl: widget.club.coverImages[index]["url"],
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                                imageBuilder: (c, i) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17),
                                        image: DecorationImage(image: i, fit: BoxFit.cover)
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // alignment: Alignment.bottomCenter,
                          bottom: 5,
                          left: 230/1.5,
                          child: SizedBox(
                            height: 20,
                            width: (15.0 * widget.club.coverImages.length),
                            child: ListView.builder(
                              itemCount: widget.club.coverImages.length,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: displayImagesIndex == i
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  isClubLivestreaming(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      widget.club.clubName,
                      textAlign: TextAlign.start,
                      style: subHeadingStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                          fontSize: 20
                      ),
                    ),
                    subtitle: followersCount < 100 ? null :  Text("${GeneralUtils().shortenLargeNumber(num: followersCount.toDouble())} ${followersCount == 1 ? "follower" : "followers"}",
                      textAlign: TextAlign.start,
                      style: captionStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBase,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      height: 30,
                      child: ActionButton(
                        text: isFollowingClub ? "Following" : "Follow",
                        padding: const EdgeInsets.all(5),
                        textStyle: captionStyle,
                        borderRadius: 30,
                        loading: isButtonLoading,
                        backgroundColor: isFollowingClub ? AppColors.grey50 : AppColors.primaryBase,
                        foregroundColor: isFollowingClub ? AppColors.grey500 : Colors.white,
                        onPressed: followClub,
                      ),
                    ),
                  ),
                  // Text(
                  //   widget.club.clubName,
                  //   textAlign: TextAlign.start,
                  //   style: subHeadingStyle.copyWith(
                  //       fontWeight: FontWeight.w700,
                  //       color: AppColors.grey900,
                  //       fontSize: 20
                  //   ),
                  // ),

                  const SizedBox(height: 10,),
                  Text(
                    widget.club.description,
                    textAlign: TextAlign.start,
                    style: captionStyle.copyWith(
                        fontWeight: FontWeight.w400,height: 1,
                        color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ListTile(
                    leading: SvgPicture.asset("assets/svg/calendar.svg", height: 32),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      widget.club.openingDays,
                      textAlign: TextAlign.start,
                      style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    subtitle: Text(
                      widget.club.openingTimes,
                      textAlign: TextAlign.start,
                      style: captionStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: SvgPicture.asset("assets/svg/location_circle.svg", height: 32,),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      widget.club.location["secondary_text"],
                      textAlign: TextAlign.start,
                      style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.club.locationDetails["address"],
                          textAlign: TextAlign.start,
                          style: captionStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey900,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            MapsLauncher.launchCoordinates(widget.club.locationDetails["latitude"], widget.club.locationDetails["longitude"]);
                          },
                          child: SizedBox(
                            width: 190,
                            child: Wrap(
                              children: [
                                Chip(label: Row(children: [
                                  SvgPicture.asset("assets/svg/map_pin.svg", color: Colors.white,),
                                  const SizedBox(width: 5,),
                                  Text("See location on maps", maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],),
                                  backgroundColor: AppColors.primaryBase,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    leading: SvgPicture.asset("assets/svg/phone_circle.svg", height: 32,),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      widget.club.phoneNumber["complete_number"],
                      textAlign: TextAlign.start,
                      style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            GeneralUtils().launchExternalApplication("tel:${widget.club.phoneNumber["complete_number"]}");
                          },
                          child: SizedBox(
                            width: 140,
                            child: Wrap(
                              children: [
                                Chip(label: Row(children: [
                                  SvgPicture.asset("assets/svg/phone_white.svg", color: Colors.white,),
                                  const SizedBox(width: 10,),
                                  Text("Make a call ", maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],),
                                  backgroundColor: AppColors.primaryBase,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  clubEvents(),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.dividerColor.withOpacity(0), AppColors.dividerColor.withOpacity(0.2), AppColors.dividerColor.withOpacity(0)], stops: const [0,0.5,1],begin: Alignment.centerLeft, end: Alignment.centerRight)
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("Gallery", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
                      (widget.club.gallery.length <= 3) ? const SizedBox() : GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed("/gallery_view", arguments: widget.club.gallery);
                        },
                        child: Text("See All", style: bodyStyle.copyWith(color: AppColors.primaryBase, fontWeight: FontWeight.w700),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  galleryRow(),
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("Ratings", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Text(double.parse("${widget.club.totalRating ?? 0.0}").toStringAsFixed(1),
                        textAlign: TextAlign.start,
                        style: subHeadingStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey900,
                          fontSize: 24
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset("assets/svg/star.svg"),
                              const SizedBox(width: 5,),
                              SvgPicture.asset("assets/svg/star.svg"),
                              const SizedBox(width: 5,),
                              SvgPicture.asset("assets/svg/star.svg"),
                              const SizedBox(width: 5,),
                              SvgPicture.asset("assets/svg/star.svg"),
                              const SizedBox(width: 5,),
                              SvgPicture.asset("assets/svg/star.svg"),
                              const SizedBox(width: 5,),
                            ],
                          ),
                          Text("Based on ${widget.club.totalReviews} review(s)", style: captionStyle.copyWith(color: AppColors.grey600),),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  buildRatingBreakdownLayout("5", AppColors.green),
                  buildRatingBreakdownLayout("4", AppColors.primaryBase),
                  buildRatingBreakdownLayout("3", AppColors.alertWarningTextColor),
                  buildRatingBreakdownLayout("2", AppColors.alertDangerBackgroundColors),
                  buildRatingBreakdownLayout(" 1", AppColors.secondaryBase),
                  ...displayRecentReviews(),
                  ActionButton(text: "Leave Review", onPressed: (){
                    showModalBottomSheet(builder: (context) {
                      return CreateNewReviewBottomSheet(widget.club);
                    },
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        ),
                        isScrollControlled: true,
                        showDragHandle: false,
                        isDismissible: false,
                        enableDrag: true,
                        context: context);
                  }),
                  const SizedBox(height: 30,),
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget isClubLivestreaming() {
    if(currentLivestream == null) {
      return const SizedBox();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: (){
          Navigator.of(context).pushNamed("/livestream_view", arguments: currentLivestream);
        },
        title: Text("${widget.club.clubName} is streaming live now. Click to join", style: captionStyle.copyWith(fontWeight: FontWeight.w500, color: AppColors.grey900,),),
        trailing: SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Wrap(
                runSpacing: 0,
                spacing: 10,
                children: [
                  Chip(
                    label: Text("LIVE", maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: AppColors.secondaryBase,
                    side: BorderSide.none,
                  ),
                  Chip(
                    label: Row(
                      children: [
                        SvgPicture.asset("assets/svg/eye_on.svg", height: 12, color: Colors.white,),
                        const SizedBox(width: 5,),
                        Text(GeneralUtils().shortenLargeNumber(num: currentLivestream!.liveViews == null ? 0 : currentLivestream!.liveViews!.toDouble()), maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.grey600,
                    side: BorderSide.none,
                  )
                ],
              )
            ],
          ),
        )
      ),
    );
  }

  Widget clubEvents() {
    if(upcomingEvents.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Upcoming Events 🥳",
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 340,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: upcomingEvents.map((e) =>
                ClubEventCardViewDisplay(e, userType: "user", locationDetails: userLocationDetails,)).toList(),
          ),
        ),
        const SizedBox(height: 20,),
      ],
    );
  }

  Widget galleryRow() {
    List<dynamic> gallery = widget.club.gallery.sublist(0,widget.club.gallery.length < 3 ? widget.club.gallery.length : 3);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 120.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: widget.club.gallery.length <= 2 ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: gallery.map((e) {
          return GestureDetector(
            onTap: (){
              if(widget.club.gallery.length > 3 && gallery.indexOf(e) == 2) {
                Navigator.of(context).pushNamed("/gallery_view", arguments: widget.club.gallery);
                return;
              }
              Navigator.of(context).pushNamed("/view_full_image", arguments: {"media": widget.club.gallery, "index": gallery.indexOf(e)});
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 3.5,
              margin: EdgeInsets.only(right: widget.club.gallery.length <= 2 ? 10 : 0),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.fitWidth,
                    height: 120.0,
                    // width: (MediaQuery.of(context).size.width - 66) / 1.5,
                    imageUrl: e["fileType"] == "video" ? e["thumbnailUrl"] : e["url"],
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                    imageBuilder: (c, i) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            image: DecorationImage(image: i, fit: BoxFit.cover)
                        ),
                      );
                    },
                  ),
                  (e["fileType"] == "video") ? const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.play_arrow_rounded, size: 48, color: AppColors.primaryBase, shadows: [Shadow(color: Colors.white, blurRadius: 10.5, offset: Offset(0, 0))],),
                  ) : const SizedBox(),
                  (widget.club.gallery.length > 3 && gallery.indexOf(e) == 2) ? Align(
                    alignment: Alignment.center,
                    child: Text("+${widget.club.gallery.length - 3}", style: titleStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),),
                  ) : const SizedBox()
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRatingBreakdownLayout(String rating, Color valueColor) {
    final ratingCount = widget.club.ratingCountObject == null ? 0 : widget.club.ratingCountObject[rating.trim()] ?? 0;
    double progressPercentage = 0;
    if(ratingCount == 0 && widget.club.totalReviews == 0) {
      progressPercentage = 0;
    } else if(ratingCount > 0 && widget.club.totalReviews == 0) {
      progressPercentage = 0;
    } else {
      progressPercentage = (ratingCount / widget.club.totalReviews) * 100;
    }
    // print("progressPercentage is");
    // print(widget.club.ratingCountObject[rating]);
    // print(widget.club.totalReviews);
    // print(progressPercentage);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(rating, style: bodyStyle.copyWith(color: AppColors.grey900),),
              const SizedBox(width: 5,),
              SvgPicture.asset("assets/svg/star.svg"),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.35,
            child: LinearProgressIndicator(backgroundColor: AppColors.grayNeutral, value: progressPercentage / 100, borderRadius: BorderRadius.circular(8), valueColor: AlwaysStoppedAnimation<Color>(valueColor),),
          ),
        ],
      ),
    );
  }

  List<Widget> displayRecentReviews() {
    if(widget.club.recentReviews.isEmpty) {
      return [
        const SizedBox(height: 30,),
      ];
    }
    return [
      const SizedBox(height: 30,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Reviews", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
          (widget.club.totalReviews <= 2) ? const SizedBox() : GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed("/club_reviews", arguments: widget.club);
            },
            child: Text("View All", style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
          ),
        ],
      ),
      Column(
        children: widget.club.recentReviews.map((e) {
          Review review = Review.fromJson(e);
          return ClubReviewWidget(review);
        }).toList(),
      ),
      const SizedBox(height: 60,),
    ];
  }

  Future<void> updateNotificationSettings(String type, bool status) async {
    if(type == "livestream") {
      if(status) {
        await FirebaseMessaging.instance.subscribeToTopic("notification_livestream_${widget.club.id}");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("notification_livestream_${widget.club.id}");
      }
      await ss.setPrefItem("notification_livestream_status_${widget.club.id}", "$status", isStoreOnline: true);
      setState(() {
        notifyLivestreams = status;
      });
    }
    GeneralUtils.showToast("${status ? "Subscribed" : "Unsubscribed"} to $type notifications");
  }

  Future<void> followClub() async {
    if(GeneralUtils().userUid == null) {
      GeneralUtils.showToast("Please login to continue");
      return;
    }
    setState(() {
      isButtonLoading = true;
    });
    try {
      if(isFollowingClub) {
        await FirebaseFirestore.instance.collection("users")
            .doc(GeneralUtils().userUid)
            .collection("following")
            .doc(widget.club.id).delete();
        await FirebaseFirestore.instance.collection("users")
            .doc(widget.club.id)
            .collection("followers")
            .doc(GeneralUtils().userUid).delete();
        setState(() {
          isButtonLoading = false;
          isFollowingClub = false;
        });
        return;
      }

      // update user following
      await FirebaseFirestore.instance.collection("users")
          .doc(GeneralUtils().userUid)
          .collection("following")
          .doc(widget.club.id)
          .set({
        "id": widget.club.id,
        "type": "club",
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });

      //update club followers
      await FirebaseFirestore.instance.collection("users")
          .doc(widget.club.userUid)
          .collection("followers")
          .doc(GeneralUtils().userUid)
          .set({
        "id": GeneralUtils().userUid,
        "type": "user",
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });
      setState(() {
        isButtonLoading = false;
        isFollowingClub = true;
      });
      updateNotificationSettings("livestream", true);
    } catch(e) {
      setState(() {
        isButtonLoading = false;
      });
      GeneralUtils.showToast("Could not perform action. Try again.");
    }
  }
}