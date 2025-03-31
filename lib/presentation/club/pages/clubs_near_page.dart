
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_places_flutter/model/prediction.dart';


import '../../../constants.dart';
import '../../../library/google_autocomplete_places.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../events/providers/club_event_notifier_provider.dart';
import '../../events/widgets/club_event_cardview.dart';
import '../../livestream/providers/livestream_notifier_provider.dart';
import '../../livestream/widgets/livestream_horizontal_full_display.dart';
import '../models/club.dart';
import '../providers/club_notifier_provider.dart';
import '../providers/club_state.dart';
import '../widgets/club_vertical_display.dart';
import '../widgets/distance_popup_view.dart';

class ClubsNearPage extends ConsumerStatefulWidget {
  final List<Club> clubs;
  const ClubsNearPage(this.clubs, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClubsNearPageState();
}

class _ClubsNearPageState extends ConsumerState<ClubsNearPage> {

  StorageSystem ss = StorageSystem();
  String? userLocation;
  final TextEditingController _locationController = TextEditingController();
  late ScrollController _scrollController;

  double locationLatitude = 0;
  double locationLongitude = 0;

  bool isSearching = false;

  double withinKm = 40;
  Map<String, dynamic> userLocationDetails = {};
  String selectedOption = "Clubs";

  late final OverlayPortalController _distancePopupController;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _distancePopupController = OverlayPortalController();
    getUserData();
    _scrollController = ScrollController();
    // final ClubState state = ref.read(clubNotifierProvider);
    // setState(() {
    //   state.copyWith(searchedNearbyClubs: state.nearbyClubs);
    // });

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

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    if (!mounted) return;
    setState(() {
      if (userData["location_details"] != null) {
        if (userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubNotifierProvider);
    final clubEventState = ref.watch(clubEventNotifierProvider);
    final livestreamState = ref.watch(livestreamNotifierProvider);

    final clubs = isSearching ? clubState.searchedNearbyClubs : clubState.nearbyClubs;
    final upcomingEvents = isSearching ? clubEventState.searchedEvents : clubEventState.upcomingEvents;
    final livestreams = isSearching ? livestreamState.searchedLivestreams : livestreamState.livestream;

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
        title: Text("Near Me", style: titleStyle.copyWith(
            color: AppColors.grey900, fontWeight: FontWeight.w700),),
        // actions: [
        //   Padding(
        //       padding: const EdgeInsets.only(right: 24.0),
        //       child: GestureDetector(
        //         child: SvgPicture.asset("assets/svg/search.svg"),
        //         onTap: () {
        //           Navigator.of(context).pushReplacementNamed(
        //               "/search_club", arguments: "");
        //         },
        //       ))
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            headerLocation(),
            const SizedBox(height: 10),
            Row(
              children: [
                searchOptionBuilder("Clubs"),
                const SizedBox(width: 10),
                searchOptionBuilder("Events"),
                const SizedBox(width: 10),
                searchOptionBuilder("Livestreams", width: 120),
              ],
            ),
            const SizedBox(height: 15),
            displayLocationChangeResult(selectedOption == "Clubs" ? clubs : selectedOption == "Events" ? upcomingEvents : livestreams, selectedOption == "Clubs" ? clubState.loading : selectedOption == "Events" ? clubEventState.loading : livestreamState.loading)
          ],
        ),
      ),
    );
  }

  Widget headerLocation() {
    if(userLocationDetails.isEmpty) {
      return const SizedBox();
    }
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(24)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width / 1.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ //km
                DistanceSliderViewButton(
                  _distancePopupController, distance: withinKm,
                  siUnit: getSIUnit(),
                  onSelectedDistance: (distance) {
                    // print("distance selected is $distance");
                    // print("locationLatitude selected is $locationLatitude");
                    // print("locationLongitude selected is $locationLongitude");
                    withinKm = distance;
                    Map<String, dynamic>? loc;
                    if (locationLatitude != 0 && locationLongitude != 0) {
                      loc = {
                        "latitude": locationLatitude,
                        "longitude": locationLongitude
                      };
                    }
                    setState(() {
                      isSearching = true;
                    });
                    ref.read(clubNotifierProvider.notifier).getClubsNearMe(
                        location: loc, distance: distance);
                    ref.read(clubEventNotifierProvider.notifier).getEventsForUsersNearMe(location: loc, distance: distance);
                    ref.read(livestreamNotifierProvider.notifier).getLivestreamsNearMe(location: loc, distance: distance);
                  },),
                const SizedBox(height: 10,),
                Text(userLocation ?? "Change location", maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.grey900),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: changeLocation,
            child: Wrap(
              children: [
                Chip(
                  label: Row(
                    children: [
                      SvgPicture.asset("assets/svg/edit_loc.svg"),
                      const SizedBox(width: 5,),
                      Text(
                        "Change", maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: captionStyle.copyWith(
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primaryBase,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget searchOptionBuilder(String title, {double width = 80}) {
    return SizedBox(
      width: width,
      height: 40,
      child: ActionButton(
        text: title,
        onPressed: (){
          setState(() {
            selectedOption = title;
          });
        },
        backgroundColor: Colors.transparent,
        foregroundColor: selectedOption == title ? AppColors.primaryBase : AppColors.grey900,
        borderSide: BorderSide(color: selectedOption == title ? AppColors.primaryBase : AppColors.grey200),
        borderRadius: 100,
        padding: const EdgeInsets.all(5),
      ),
    );
  }

  String getSIUnit() {
    String address = userLocationDetails["address"];
    if (address.toLowerCase().contains("usa") ||
        address.toLowerCase().contains("united states")) {
      return "miles";
    }
    return "Km";
  }

  Widget emptySection(String body, bool isLoading) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.9,
      child: Center(
        child: isLoading ? const CircularProgressIndicator() : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40,),
            Image.asset("assets/images/empty_club_home.png", height: 100,),
            const SizedBox(height: 20,),
            Text(body, textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  Widget displayLocationChangeResult(dynamic result, bool isLoading) {
    if(selectedOption == "Clubs") {
      return result.isEmpty ? emptySection(
          "No clubs found\n Click on 'Change' to enter a new location.",
          isLoading) : Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 4.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: result.length, itemBuilder: (context, index) {
          return ClubVerticalDisplay(
            result[index], showReviews: true, width: 0, marginRight: 0,);
        },
          controller: _scrollController,
        ),
      );
    }
    if(selectedOption == "Livestreams") {
      return result.isEmpty ? emptySection(
          "No livestreams found\n Click on 'Change' to enter a new location.",
          isLoading) : Expanded(
        child: ListView.builder(
          // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 1,
          //   childAspectRatio: 1 / 1,
          //   crossAxisSpacing: 0,
          //   mainAxisSpacing: 0,
          // ),
          itemCount: result.length,
          itemBuilder: (context, index) {
          return LivestreamHorizontalFullDisplay(
              result[index], allowRightMargin: false,);
        },
          controller: _scrollController,
        ),
      );
    }
    return result.isEmpty ? emptySection(
        "No events found\n Click on 'Change' to enter a new location.",
        isLoading) : Expanded(
      child: ListView.builder(
        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //   crossAxisCount: 1,
        //   childAspectRatio: 1 / 1,
        //   crossAxisSpacing: 8,
        //   mainAxisSpacing: 8,
        // ),
        itemCount: result.length, itemBuilder: (context, index) {
        return ClubEventCardViewDisplay(
          result[index], userType: "user", allowRightMargin: false, locationDetails: userLocationDetails,);
      },
        controller: _scrollController,
      )
    );
  }

  Future<void> changeLocation() async {

    // locationLatitude = 0;
    // locationLongitude = 0;

    final res = await showModalBottomSheet<dynamic>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        isScrollControlled: true,
        showDragHandle: false,
        isDismissible: true,
        enableDrag: true,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.7,
              snapAnimationDuration: const Duration(milliseconds: 400),
              snap: true,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              expand: false,
              builder: (mContext, scrollController) {
            return StatefulBuilder(builder: (context, StateSetter setState) {
              return GestureDetector(
                onTap: (){
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Container(
                  // height: 500,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Enter address", style: bodyStyle.copyWith(color: AppColors.titleTextColor, fontWeight: FontWeight.w700,),),
                            const SizedBox(height: 10,),
                            GooglePlaceAutoCompleteTextField(
                              textEditingController: _locationController,
                              googleAPIKey: googleApiKey,
                              inputDecoration: InputDecoration(
                                alignLabelWithHint: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBase,
                                  ),
                                ),
                                labelText: "Location",
                                labelStyle: titleStyle.copyWith(
                                  color: AppColors.grey400,
                                ),
                                filled: true,
                                hintText: "Enter an address",
                                hintStyle: captionStyle.copyWith(
                                  color: AppColors.grey400,
                                ),
                                border: InputBorder.none,
                                fillColor: AppColors.grey50,
                              ),
                              debounceTime: 800, // default 600 ms,
                              isLatLngRequired: true, // if you required coordinates from place detail
                              getPlaceDetailWithLatLng: (Prediction prediction) {
                                locationLatitude = double.parse(prediction.lat!);
                                locationLongitude = double.parse(prediction.lng!);
                                // print("lat: ${double.parse(prediction.lat!)}");
                                // print("lng: ${double.parse(prediction.lng!)}");
                              }, // this callback is called when isLatLngRequired is true
                              itemClick: (Prediction prediction) {
                                _locationController.text = prediction.description!;
                                _locationController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: prediction.description!.length));
                                userLocation = _locationController.text;
                              },
                              // if we want to make custom list item builder
                              itemBuilder: (context, index, Prediction prediction) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      // const Icon(Icons.location_on),
                                      SvgPicture.asset("assets/svg/location_gray.svg"),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(child: Text(prediction.description ?? ""))
                                    ],
                                  ),
                                );
                              },
                              // if you want to add seperator between list items
                              seperatedBuilder: const Divider(),
                              // want to show close icon
                              isCrossBtnShown: true,
                              showError: true,
                              boxDecoration: const BoxDecoration(),
                            ),
                            SizedBox(height: MediaQuery.of(mContext).size.height / 2.2,),
                            ActionButton(text: "Change", onPressed: (){
                              Navigator.of(context).pop({"lat": locationLatitude, "lng": locationLongitude});
                            }),
                          ],
                        ),
                      ),
                    )
                ),
              );
            });
          });
        },
    );

    // print("res = $res");

    setState(() {
      isSearching = true;
    });

    // print(locationLatitude);
    // print(locationLongitude);

    // if (locationLatitude == 0 && locationLongitude == 0) {
    //   return;
    // }
    if(res == null) {
      return;
    }

    if (res["lat"] == 0 && res["lng"] == 0) {
      return;
    }
    // print("getting");
    updateUserLocationCoordinates(res["lat"], res["lng"]);
    ref.read(clubNotifierProvider.notifier).getClubsNearMe(location: {"latitude": res["lat"], "longitude": res["lng"]}, distance: withinKm);
    ref.read(clubEventNotifierProvider.notifier).getEventsForUsersNearMe(location: {"latitude": res["lat"], "longitude": res["lng"]}, distance: withinKm);
    ref.read(livestreamNotifierProvider.notifier).getLivestreamsNearMe(location: {"latitude": res["lat"], "longitude": res["lng"]}, distance: withinKm);
  }

  updateUserLocationCoordinates(double latitude, double longitude) {
    setState(() {
      userLocationDetails = {
        "address": userLocationDetails["address"],
        "latitude": latitude,
        "longitude": longitude,
        "position": {
          "geohash": GeneralUtils().encodeGeoHash(latitude, longitude, 9),
          "geopoint": GeoPoint(latitude, longitude)
        }
      };
    });
  }
}