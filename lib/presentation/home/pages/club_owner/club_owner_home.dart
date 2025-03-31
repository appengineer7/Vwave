import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/presentation/events/providers/club_event_notifier_provider.dart';
import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../../widgets/user_avatar.dart';
import '../../../events/providers/club_event_state.dart';
import '../../../events/widgets/club_event_cardview.dart';
import '../../../livestream/providers/livestream_notifier_provider.dart';
import '../../../livestream/providers/livestream_state.dart';
import '../../../livestream/widgets/livestream_vertical_display.dart';
import '../../widgets/start_livestream_bottom_sheet.dart';


class ClubOwnerHomePage extends ConsumerStatefulWidget {
  const ClubOwnerHomePage({super.key});

  @override
  ConsumerState<ClubOwnerHomePage> createState() => _ClubOwnerHomePageState();
}

class _ClubOwnerHomePageState extends ConsumerState<ClubOwnerHomePage> {


  StorageSystem ss = StorageSystem();
  bool isAccountSetup = false;
  dynamic userProfile;

  final TextEditingController _controller = TextEditingController(text: "");

  late PersistentBottomSheetController _bottomSheetController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? userLocation;
  String clubName = "";
  Map<String, dynamic> userLocationDetails = {};

  // List<dynamic> suggestedUsers = [];

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic>? userData = jsonDecode(user);
    if (!mounted) return;
    setState(() {
      clubName = userData!["club_name"] ?? "";
      if(userData["location_details"] != null) {
        if(userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      bool acctSetup = await GeneralUtils().isClubOwnerAccountSetupComplete();
      dynamic profile = await GeneralUtils().getUserProfile();
      setState(() {
        isAccountSetup = acctSetup;
        userProfile = profile;
      });
      await getUserData();
      // await searchUsersOnline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livestreamNotifierProvider);
    final eventState = ref.watch(clubEventNotifierProvider);
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   toolbarHeight: 100.0,
      //   centerTitle: false,
      //   automaticallyImplyLeading: false,
      //   title: Container(
      //     width: MediaQuery.of(context).size.width,
      //     height: 45,
      //     margin: const EdgeInsets.only(left: 8),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Stack(
      //           clipBehavior: Clip.hardEdge,
      //           children: [
      //             GeneralUserAvatar(
      //               40.0,
      //               avatarData: userProfile["picture"],
      //               userUid: GeneralUtils().userUid, //widget.conversation.participants[1],
      //               clickable: false,
      //             ),
      //             const Positioned(
      //               top: 30,
      //               left: 30,
      //               child: CircleAvatar(backgroundColor: AppColors.green, radius: 5,),
      //             )
      //           ],
      //         ),
      //         const SizedBox(
      //           width: 8,
      //         ),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             const SizedBox(
      //               height: 8,
      //             ),
      //             Text("Hello 👋",
      //               style: captionStyle.copyWith(color: AppColors.grey700),
      //             ),
      //             Text("${userProfile["first_name"]} ${userProfile["last_name"]}", maxLines: 1, overflow: TextOverflow.ellipsis,
      //               style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
      //             )
      //           ],
      //         )
      //       ],
      //     ),
      //   ),
      //   actions: [
      //     Padding(padding: const EdgeInsets.only(right: 24), child: GestureDetector(
      //       onTap: (){
      //         Navigator.of(context).pop();
      //       },
      //       child: SvgPicture.asset("assets/svg/notification.svg"),
      //     ),)
      //   ],
      // ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: RefreshIndicator(child: SingleChildScrollView(
          child: Column(
            children: [
              profileHeader(),
              // const SizedBox(height: 10,),
              // SearchFieldWidget(_controller),
              const SizedBox(height: 24,),
              topHeader(),
              const SizedBox(height: 24,),
              eventLayout("Upcoming Events", "You don't have any upcoming events at this time", eventState),
              const SizedBox(height: 24,),
              otherLayouts("Recent Activities", "You don't have any recent activities at this time", "activity", (){Navigator.of(context).pushNamed("/recent_activities", arguments: state.recentLivestreams);}, state),
              const SizedBox(height: 24,),
              otherLayouts("Top Follower(s) ✨", "You don't have any top followers at this time", "follower", (){Navigator.of(context).pushNamed("/top_followers", arguments: state.clubFollowers);}, state),
            ], //[{"id": "fjfd", "first_name": "Gisanrinnnnnnn", "picture": ""},]
          ),
        ),
            onRefresh: () async {
              ref.read(livestreamNotifierProvider.notifier).getRecentLivestreamsAndClubFollowers(getClubFollower: false);
              ref.read(clubEventNotifierProvider.notifier).getClubEvents();
            })
      )),
    );
  }

  Widget profileHeader() {
    return userProfile == null ? const SizedBox() : Container(
      width: MediaQuery.of(context).size.width - 48,
      height: 60,
      margin: const EdgeInsets.only(top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  GeneralUserAvatar(
                    40.0,
                    avatarData: userProfile["picture"],
                    userUid: GeneralUtils().userUid, //widget.conversation.participants[1],
                    clickable: false,
                  ),
                  const Positioned(
                    top: 30,
                    left: 30,
                    child: CircleAvatar(backgroundColor: AppColors.green, radius: 5,),
                  )
                ],
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Text("Hello 👋",
                    style: captionStyle.copyWith(color: AppColors.grey700),
                  ),
                  Text("${userProfile["first_name"]} ${userProfile["last_name"]}", maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: captionStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
                  )
                ],
              )
            ],
          ),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed("/notifications");
            },
            child: SvgPicture.asset("assets/svg/notification.svg"),
          )
        ],
      ),
    );
  }

  Widget topHeader() {
    if(isAccountSetup) {
      return GestureDetector(
        onTap: startLivestream,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primaryBase,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/svg/navigation/livestream.svg", height: 40, color: Colors.white,),
              Text("Start Livestream", style: subHeadingStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
              SvgPicture.asset("assets/svg/rounded_arrow.svg")
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: setupAccount,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 120.0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryBase,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/account_setup.png", height: 60,),
            Text("Complete your\naccount setup", style: subHeadingStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
            SvgPicture.asset("assets/svg/rounded_arrow.svg")
          ],
        ),
      ),
    );
  }

  Widget otherLayouts(String title, String body, String tag, Function()? onPress, LivestreamState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(title, style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
            ((tag == "activity" && state.recentLivestreams.isEmpty) || (tag == "follower" && state.clubFollowers.isEmpty)) ? const SizedBox() : GestureDetector(
              onTap: onPress,
              child: Text("View all", style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
            ),
            // (tag == "follower" && suggestedUsers.isEmpty) ? const SizedBox() : GestureDetector(
            //   onTap: onPress,
            //   child: Text("View all", style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
            // )
          ],
        ),
        resultLayout(title, body, tag, state,)
      ],
    );
  }

  Widget resultLayout(String title, String body, String tag, LivestreamState state) {
    // print(state.error);
    if(state.loading) {
      return const Column(
        children: [
          SizedBox(height: 40,),
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 20,),
        ],
      );
    }
    if(tag == "activity") {
      if(state.recentLivestreams.isEmpty || state.error.isNotEmpty) {
        return emptySection(body);
      }
    }
    if(tag == "follower") {
      if(state.clubFollowers.isEmpty) {
        return emptySection(body);
      }
    }
    // if(((state.recentLivestreams!.isEmpty || state.error.isNotEmpty) && tag == "activity") || (suggestedUsers.isEmpty && tag == "follower")) {
    //   return Column(
    //     children: [
    //       const SizedBox(height: 40,),
    //       Image.asset("assets/images/empty_club_home.png", height: 100,),
    //       const SizedBox(height: 20,),
    //       Text(body, style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
    //     ],
    //   );
    // }
    if(tag == "activity") {
      return SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 340,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: state.recentLivestreams.sublist(0,state.recentLivestreams.length < 5 ? state.recentLivestreams.length : 5).map((e) =>
              LivestreamVerticalDisplay(e)).toList(),
        ),
      );
    }

    if(tag == "follower") {
      // return followerLayout({"id": "fjfd", "first_name": "Gisanrinnnnnnn", "picture": ""});
      return SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: state.clubFollowers.map((e) =>
              followerLayout(e)
          ).toList(),
        ),
      );
    }

    return const SizedBox();
  }

  Widget emptySection(String body) {
    return Column(
      children: [
        const SizedBox(height: 40,),
        Image.asset("assets/images/empty_club_home.png", height: 100,),
        const SizedBox(height: 20,),
        Text(body, style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
      ],
    );
  }

  Widget followerLayout(dynamic follower) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 24, top: 20),
        width: 100,
        child: Column(
          children: [
            GeneralUserAvatar(
              80.0,
              avatarData: follower["picture"],
              userUid: follower["id"],
              clickable: false,
            ),
            const SizedBox(height: 10,),
            Text("${follower["first_name"]}", textAlign: TextAlign.center, style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
          ],
        ),
      ),
    );
  }

  Widget eventLayout(String title, String body, ClubEventState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(title, style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
            // (state.upcomingEvents.isEmpty) ? const SizedBox() : GestureDetector(
            //   onTap: onPress,
            //   child: Text("View all", style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
            // ),
          ],
        ),
        if(state.loading)
          const Column(
            children: [
              SizedBox(height: 40,),
              Center(
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 20,),
            ],
          ),
        if(state.upcomingEvents.isEmpty && !state.loading)
          emptySection(body),
        if(state.upcomingEvents.isNotEmpty && !state.loading)
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 340,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: state.upcomingEvents.map((e) =>
                  ClubEventCardViewDisplay(e, userType: "club_owner", locationDetails: userLocationDetails,)).toList(),
            ),
          )
      ],
    );
  }

  Future<void> setupAccount() async {
    await GeneralUtils().showResponseBottomSheet(context, "warning", "Account Setup", "You need to complete your account setup", "Proceed", (){
      Navigator.of(context).pop();
    });
    await Navigator.of(context).pushNamed("/club_owner_account_setup");
    bool acctSetup = await GeneralUtils().isClubOwnerAccountSetupComplete();
    setState(() {
      isAccountSetup = acctSetup;
    });
  }

  Future<void> startLivestream() async {
    final isVerified = await GeneralUtils().isClubOwnerAccountVerified();
    if(!isVerified) {
      await GeneralUtils().showResponseBottomSheet(context, "warning", "Account Verification", "Your account has not yet been verified. Please check back again.", "Ok", (){
        Navigator.of(context).pop();
      });
      return;
    }
    _bottomSheetController = _scaffoldKey.currentState!.showBottomSheet((context) {
          return StartLivestreamBottomSheet(_bottomSheetController);
        },
        backgroundColor: Colors.white,

        // isDismissible: false,
        // showDragHandle: true,
        enableDrag: false);
  }

  // Future<void> searchUsersOnline() async {
  //
  //   String url = "getfollowers?user_uid=${GeneralUtils().userUid}";
  //
  //   final res = await GeneralUtils().makeRequest(url, {}, method: "get");
  //
  //   if(res.statusCode != 200) {
  //     return;
  //   }
  //
  //   final body = jsonDecode(res.body);
  //
  //   List<dynamic> data = body["data"];
  //
  //   if(!mounted) return;
  //   setState(() {
  //     suggestedUsers = data.map((e) => e).toList();
  //   });
  // }
}
