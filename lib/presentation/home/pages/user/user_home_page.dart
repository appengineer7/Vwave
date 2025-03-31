import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/club/models/club.dart';
import 'package:vwave_new/presentation/club/providers/club_notifier_provider.dart';
import 'package:vwave_new/presentation/events/providers/club_event_notifier_provider.dart';

import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../../widgets/user_avatar.dart';
import '../../../club/providers/club_state.dart';
import '../../../club/widgets/club_vertical_display.dart';
import '../../../events/providers/club_event_state.dart';
import '../../../events/widgets/club_event_cardview.dart';
import '../../../livestream/providers/livestream_notifier_provider.dart';
import '../../../livestream/providers/livestream_state.dart';
import '../../../livestream/widgets/livestream_horizontal_full_display.dart';
import '../../../stories/pages/story_page.dart';
import '../../../stories/providers/story_notifier_provider.dart';
import '../../widgets/shimmer_effect.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  StorageSystem ss = StorageSystem();
  bool isAccountSetup = false;
  dynamic userProfile;

  final TextEditingController _controller = TextEditingController(text: "");
  late ScrollController _scrollController;

  late String userLocation;
  String clubName = "";
  Map<String, dynamic> userLocationDetails = {};

  List<dynamic> suggestedUsers = [];

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic>? userData = jsonDecode(user);
    if (!mounted) return;
    setState(() {
      clubName = userData!["club_name"] ?? "";
      if (userData["location_details"] != null) {
        if (userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails =
            GeneralUtils().getLocationDetailsData(userData["location_details"]);
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
    // _controller.addListener(() {
    //   String query = _controller.text;
    //   if(query.length >= 3) {
    //     setState(() {
    //       _controller.clear();
    //     });
    //     Navigator.of(context).pushNamed("/search_club", arguments: query); //search_entire_users
    //   }
    // });
    getProfileDetails();

    _scrollController = ScrollController();

    // _scrollController.addListener(() {
    //   // print('pixel is ${_controller.position.pixels}');
    //   // print('max is ${_controller.position.maxScrollExtent}');
    //   if (_scrollController.position.pixels >
    //       _scrollController.position.maxScrollExtent -
    //           MediaQuery.of(context).size.height) {
    //     if (!ref.read(clubNotifierProvider).maxReached) {
    //       // make sure ListView has newest data after previous loadMore
    //       print("herrr");
    //       final ClubState state = ref.read(clubNotifierProvider);
    //       final Club lastClub = state.clubs.last;
    //       ref
    //           .read(clubNotifierProvider.notifier)
    //           .getMoreClubs(lastClub);
    //     }
    //   }
    // });
  }

  void getProfileDetails() {
    Future.delayed(Duration.zero, () async {
      dynamic profile = await GeneralUtils().getUserProfile();
      setState(() {
        userProfile = profile;
      });
      await getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final livestreamState = ref.watch(livestreamNotifierProvider);
    final clubState = ref.watch(clubNotifierProvider);
    final clubEventState = ref.watch(clubEventNotifierProvider);
    final storiesState = ref.watch(storyNotifierProvider);

    final isLoading = livestreamState.loading && clubState.loading && clubEventState.loading;

    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: RefreshIndicator(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        profileHeader(clubState),
                        isLoading ? isFullLoading() : afterLoadingResultLayout(livestreamState, clubState, clubEventState)
                      ],
                    ),
                  ),
                  onRefresh: () async {
                    // ref.read(livestreamNotifierProvider.notifier).getLivestreams();
                    ref.read(clubNotifierProvider.notifier).getClubs();
                    ref
                        .read(storyNotifierProvider.notifier)
                        .getStoryFeeds(isRefreshed: true);
                    ref.read(clubEventNotifierProvider.notifier).getClubEventsForUsers();
                  }))),
    );
  }

  Widget isFullLoading() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: const ShimmerEffects("full"),
    );
  }

  Widget afterLoadingResultLayout(LivestreamState livestreamState, ClubState clubState, ClubEventState clubEventState) {
    if(livestreamState.livestream.isEmpty && clubState.clubs.isEmpty && clubEventState.upcomingEvents.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: emptySection("VWave is not yet in your location.", clubState, "club"),
        ),
      );
    }
    return Column(
      children: [
        const StoryPage(),
        livestreamsLayout(livestreamState),
        clubsNearYouLayout(clubState, livestreamState),
        eventsLayout(clubEventState),
        recommendedClubsLayout(clubState),
      ],
    );
  }

  Widget loadingLayoutHeader(String title, String loadingType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
          ],
        ),
        ShimmerEffects(loadingType)
      ],
    );
  }

  Widget livestreamsLayout(LivestreamState livestreamState) {
    if(livestreamState.loading) {
      return loadingLayoutHeader("Livestreams 🔥", "livestream");
    }
    if(livestreamState.livestream.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: [
        const SizedBox(height: 24,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Livestreams 🔥",
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            (livestreamState.livestream.isEmpty)
                ? const SizedBox()
                : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/livestreams",
                    arguments: livestreamState.livestream);
              },
              child: Text(
                "View all",
                style: bodyStyle.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: livestreamState.livestream
                .sublist(0, livestreamState.livestream.length < 6
                    ? livestreamState.livestream.length : 6)
                .map((e) => LivestreamHorizontalFullDisplay(e))
                .toList(),
          ),
        )
      ],
    );
  }

  Widget clubsNearYouLayout(ClubState clubState, LivestreamState livestreamState) {
    if(clubState.loading) {
      return loadingLayoutHeader("Clubs Near You ✨", "club");
    }
    if(clubState.clubs.isEmpty) {
      return const SizedBox();
    }
    // if (clubState.nearbyClubs.isEmpty) {
    //   return emptySection("There are no clubs near you. Change location to find clubs.", clubState, "club");
    // }
    List<Club> nearbyClubs = clubState.nearbyClubs.isEmpty
        ? clubState.clubs.sublist(0, clubState.clubs.length < 6 ? clubState.clubs.length : 6)
        : clubState.nearbyClubs.sublist(0, clubState.nearbyClubs.length < 6
            ? clubState.nearbyClubs.length
            : 6);
    return Column(
      children: [
        SizedBox(height: livestreamState.livestream.isEmpty ? 10 : 24,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Clubs Near You ✨",
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            (clubState.clubs.isEmpty) ? const SizedBox()
                : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/clubs_near",
                    arguments: clubState.nearbyClubs);
              },
              child: Text(
                "View all",
                style: bodyStyle.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 370,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: nearbyClubs
                .map((e) => ClubVerticalDisplay(
              e,
              showReviews: true,
              width: (MediaQuery.of(context).size.width - 48) / 1.5,
            ))
                .toList(),
          ),
        )
      ],
    );
  }

  Widget eventsLayout(ClubEventState clubEventState) {
    if(clubEventState.loading || userLocationDetails.isEmpty) {
      return loadingLayoutHeader("Upcoming Events 🥳", "event");
    }
    if(clubEventState.upcomingEvents.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: [
        const SizedBox(height: 24,),
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
            (clubEventState.upcomingEvents.isEmpty) ? const SizedBox()
                : GestureDetector(
              onTap: () {
                Map<String, dynamic> data = {
                  "club_event": clubEventState.upcomingEvents,
                  "user_type": "user",
                  "location_details": userLocationDetails,
                };
                Navigator.of(context).pushNamed("/user_events_list",
                    arguments: data);
              },
              child: Text(
                "View all",
                style: bodyStyle.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w500),
              ),
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
            children: clubEventState.upcomingEvents.map((e) =>
                ClubEventCardViewDisplay(e, userType: "user", locationDetails: userLocationDetails,)).toList(),
          ),
        )
      ],
    );
  }

  Widget recommendedClubsLayout(ClubState clubState) {
    if(clubState.loading) {
      return loadingLayoutHeader("Recommended For You ✨", "club");
    }
    if(clubState.clubs.isEmpty) {
      return const SizedBox();
    }
    List<Club> allClubs = clubState.clubs.sublist(
        0, clubState.clubs.length < 10 ? clubState.clubs.length : 10);
    int count = allClubs.length;
    const int itemsPerRow = 2;
    const double ratio = 2 / 3.8;
    const double horizontalPadding = 0;
    final double calcHeight = ((MediaQuery.of(context).size.width / itemsPerRow) - (horizontalPadding)) *
        (count / itemsPerRow).ceil() *
        (1 / ratio);
    // print(calcHeight);
    return Column(
      children: [
        const SizedBox(height: 24,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Recommended For You ✨",
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            (clubState.clubs.isEmpty) ? const SizedBox()
                : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/clubs",
                    arguments: clubState.clubs);
              },
              child: Text(
                "View all",
                style: bodyStyle.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: calcHeight, //MediaQuery.of(context).size.height - 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allClubs.length,
            itemBuilder: (context, index) {
              return ClubVerticalDisplay(
                allClubs[index],
                showReviews: false,
                width: 0,
                marginRight: 0,
              );
            },
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
        )
      ],
    );
  }

  Widget trash(livestreamState, clubState) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Stack(
          children: [
            SearchFieldWidget(
              _controller,
              hintText: "Search for",
              readOnly: true,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 3),
                  child: Wrap(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              "/search_entire_users");
                        },
                        child: Chip(
                          label: Text(
                            "Users",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: captionStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          backgroundColor: AppColors.grey600,
                          side: BorderSide.none,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              "/search_club",
                              arguments: "");
                        },
                        child: Chip(
                          label: Text(
                            "Clubs",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: captionStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          backgroundColor: AppColors.grey600,
                          side: BorderSide.none,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ))
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        const StoryPage(),
        otherLayouts(
            "Livestreams 🔥",
            "There are no livestreams at this time",
            "livestream", () {
          Navigator.of(context).pushNamed("/livestreams",
              arguments: livestreamState.livestream);
        }, livestreamState, clubState, false),
        const SizedBox(
          height: 24,
        ),
        otherLayouts(
            "Near You ✨",
            "There are no clubs near you. Change location to find clubs.",
            "club", () {
          Navigator.of(context).pushNamed("/clubs_near",
              arguments: clubState.clubs);
        }, livestreamState, clubState, false),
        const SizedBox(
          height: 24,
        ),
        otherLayouts(
            "Recommended For You✨",
            "There are no clubs near you. Change location to find clubs.",
            "club", () {
          Navigator.of(context)
              .pushNamed("/clubs", arguments: clubState.clubs);
        }, livestreamState, clubState, true),
      ],
    );
  }

  Widget profileHeader(ClubState clubState) {
    return userProfile == null
        ? const SizedBox()
        : Container(
            width: MediaQuery.of(context).size.width - 48,
            height: 60,
            margin: const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                    onTap: () async {
                      await Navigator.of(context)
                          .pushNamed("/user_account");
                      getProfileDetails();
                    },
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        GeneralUserAvatar(
                          40.0,
                          avatarData: userProfile["picture"],
                          userUid: GeneralUtils()
                              .userUid, //widget.conversation.participants[1],
                          clickable: false,
                        ),
                        const Positioned(
                          top: 30,
                          left: 30,
                          child: CircleAvatar(
                            backgroundColor: AppColors.green,
                            radius: 5,
                          ),
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
                        Text(
                          "Hello 👋",
                          style:
                              captionStyle.copyWith(color: AppColors.grey700),
                        ),
                        Text(
                          "${userProfile["first_name"]} ${userProfile["last_name"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: captionStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900),
                        )
                      ],
                    )
                  ],
                )),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed("/clubs_near", arguments: clubState.clubs);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Current location",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              style: captionStyle.copyWith(
                                  color: AppColors.grey600),
                            ),
                            SizedBox(
                              // width: MediaQuery.of(context).size.width / 2.3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/location_gray.svg",
                                    height: 12,
                                  ),
                                  Text(
                                      userLocation.length > 13 ? "${userLocation.substring(0, (userLocation.length / 2).ceil())}..." : userLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.end,
                                    style: captionStyle.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.grey900),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ))
              ],
            ),
          );
  }

  // (tag == "club" && !isRecommended && clubState.nearbyClubs.isEmpty) ? Text("chan"):
  Widget otherLayouts(
      String title,
      String body,
      String tag,
      Function()? onPress,
      LivestreamState liveState,
      ClubState clubState,
      bool isRecommended) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title,
              style: titleStyle.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            ((tag == "livestream" && liveState.livestream.isEmpty) ||
                    (tag == "club" && clubState.clubs.isEmpty))
                ? const SizedBox()
                : GestureDetector(
                    onTap: onPress,
                    child: Text(
                      "View all",
                      style: bodyStyle.copyWith(
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
          ],
        ),
        resultLayout(title, body, tag, liveState, clubState, isRecommended)
      ],
    );
  }

  Widget resultLayout(String title, String body, String tag, LivestreamState liveState, ClubState clubState, bool isRecommended) {
    if ((tag == "livestream" && liveState.loading) ||
        (tag == "club" && clubState.loading)) {
      return const Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    }
    if (tag == "livestream") {
      if (liveState.livestream.isEmpty || liveState.error.isNotEmpty) {
        return emptySection(body, clubState, tag);
      }
    }
    if (tag == "club") {
      if (clubState.clubs.isEmpty || clubState.error.isNotEmpty) {
        return emptySection(body, clubState, tag);
      }
    }

    if (tag == "livestream") {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: liveState.livestream
              .sublist(
                  0,
                  liveState.livestream.length < 6
                      ? liveState.livestream.length
                      : 6)
              .map((e) => LivestreamHorizontalFullDisplay(e))
              .toList(),
        ),
      );
    }

    if (tag == "club" && !isRecommended) {
      // Map<String, dynamic> position = userLocationDetails["position"];
      // List<Club> nearbyClubs = clubState.clubs.map((e) {
      //   return GeoFirePoint(position["geopoint"]).distanceBetweenInKm(geopoint: e.locationDetails["position"]["geopoint"]) <= 20;
      // }).toList();
      List<Club> nearbyClubs = clubState.nearbyClubs.isEmpty
          ? clubState.clubs.sublist(
              0, clubState.clubs.length < 6 ? clubState.clubs.length : 6)
          : clubState.nearbyClubs.sublist(
              0,
              clubState.nearbyClubs.length < 6
                  ? clubState.nearbyClubs.length
                  : 6);
      // clubState.clubs.sublist(0, clubState.clubs.length < 5 ? clubState.clubs.length : 5)
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 370,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: nearbyClubs
              .map((e) => ClubVerticalDisplay(
                    e,
                    showReviews: true,
                    width: (MediaQuery.of(context).size.width - 48) / 1.5,
                  ))
              .toList(),
        ),
      );
    }

    if (tag == "club" && isRecommended) {
      List<Club> allClubs = clubState.clubs.sublist(
          0, clubState.clubs.length < 10 ? clubState.clubs.length : 10);
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 350,
        child:
            // Expanded(
            //   child:
            GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: allClubs.length,
          itemBuilder: (context, index) {
            return ClubVerticalDisplay(
              allClubs[index],
              showReviews: false,
              width: 0,
              marginRight: 0,
            );
          },
          scrollDirection: Axis.vertical,
          // physics: const NeverScrollableScrollPhysics(),
          // shrinkWrap: true,
        ),
        // )
        // ListView(
        //   children: clubState.clubs.map((e) =>
        //       ClubVerticalDisplay(e, showReviews: false, width: (MediaQuery.of(context).size.width - 48),)
        //   ).toList(),
        // ),
      );
    }

    return const SizedBox();
  }

  Widget emptySection(String body, clubState, String tag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 40,
        ),
        Image.asset(
          "assets/images/empty_club_home.png",
          height: 100,
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
              text: body,
              style: captionStyle.copyWith(
                  color: AppColors.grey700, fontWeight: FontWeight.w500),
            ),
            // if (tag == "club")
            //   TextSpan(
            //     text: "\n\nTap here to change location",
            //     style: captionStyle.copyWith(
            //         color: AppColors.primaryBase, fontWeight: FontWeight.w700),
            //     recognizer: TapGestureRecognizer()
            //       ..onTap = () {
            //         Navigator.of(context)
            //             .pushNamed("/clubs_near", arguments: clubState.clubs);
            //       },
            //   )
          ]),
        ),
        TextButton.icon(
            iconAlignment: IconAlignment.start,
            icon: const Icon(Icons.location_on_rounded, size: 18,),
            onPressed: (){
          Navigator.of(context)
              .pushNamed("/clubs_near", arguments: clubState.clubs);
        }, label: Text("Tap here to change location", style: captionStyle.copyWith(
            color: AppColors.primaryBase, fontWeight: FontWeight.w700))),
        TextButton.icon(
          iconAlignment: IconAlignment.start,
            icon: const Icon(Icons.build_rounded, size: 18,),
            onPressed: () {
          Navigator.of(context).pushNamed("/club_suggestion", arguments: clubState.clubs);
        }, label: Text("Suggest a club to VWave", style: captionStyle.copyWith(
            color: AppColors.primaryBase, fontWeight: FontWeight.w700))),
      ],
    );
  }
}
