
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:vwave/utils/exceptions.dart';

import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../models/club.dart';
import '../repositories/club_repository.dart';
import 'club_state.dart';


class ClubStateNotifier extends StateNotifier<ClubState> {
  final Ref ref;
  ClubStateNotifier(this.ref)
      : super(
    const ClubState(
        clubs: [],
        loading: false,
        loadingMore: false,
        loadingMoreError: '',
        error: '',
        maxReached: false,
      nearbyClubs: [],
        searchedNearbyClubs: [],
      savedClubs: [],
    ),
  );

  void setStateLoading(bool isLoading) async {
    state = state.copyWith(loading: isLoading);
  }

  Future<void> getClubs() async {
    state = state.copyWith(loading: true);

    try {
      final clubs = await ref.read(clubRepositoryProvider).getClubs();
      final nearby = await getNearbyClubsWithinDistance(clubs);

      state = state.copyWith(loading: false, clubs: clubs, nearbyClubs: nearby, searchedNearbyClubs: nearby);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getClubsFromHive() async {
    state = state.copyWith(loading: true);

    try {
      final clubs = await ref.read(clubRepositoryProvider).getClubsFromHive();
      print(clubs);
      final nearby = await getNearbyClubsWithinDistance(clubs);

      // state = state.copyWith(loading: false, clubs: clubs, nearbyClubs: nearby, searchedNearbyClubs: nearby);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  void getMoreClubs(Club club) async {
    state = state.copyWith(loadingMore: true);

    try {
      final clubs =
      await ref.read(clubRepositoryProvider).getMoreClubs(club);
      final nearby = await getNearbyClubsWithinDistance(clubs);

      if (clubs.isEmpty) {
        state = state.copyWith(maxReached: true);
      }
      state = state.copyWith(
        loadingMore: false,
        clubs: [...state.clubs, ...clubs],
        nearbyClubs: [...state.nearbyClubs, ...nearby],
        searchedNearbyClubs: [...state.searchedNearbyClubs, ...nearby],
      );
      // print(products);
    } on CustomException catch (e) {
      state = state.copyWith(loadingMoreError: e.message, loadingMore: false);
    }
  }

  Future<void> getClubsNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    state = state.copyWith(loading: true);

    try {
      final clubs = await ref.read(clubRepositoryProvider).getClubsNearMe(distance: distance, location: location);

      state = state.copyWith(loading: false, searchedNearbyClubs: clubs);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getSavedClubs() async {
    state = state.copyWith(loading: true);

    try {
      final savedItems = await ref.read(clubRepositoryProvider).getSavedClubs();

      state = state.copyWith(loading: false, savedClubs: savedItems);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> deleteSavedClub(String itemId, String clubId) async {
    try {
      await ref.read(clubRepositoryProvider).deleteSavedClub(itemId, clubId);
      state.savedClubs.removeWhere((element) => element["item_id"] == itemId);
      state = state.copyWith(loading: false, savedClubs: state.savedClubs);
    } on CustomException catch (e) {
      GeneralUtils.showToast("This action couldn't be completed. Please try again.");
    }
  }

  Future<void> saveFavoriteClubs(Club club) async {
    try {
      String? itemId = await ref.read(clubRepositoryProvider).saveFavoriteClubs(club);
      if(itemId != null) {
        state.savedClubs.removeWhere((element) => element["item_id"] == itemId);
        state = state.copyWith(loading: false, savedClubs: state.savedClubs);
      }
    } on CustomException catch (e) {
      GeneralUtils.showToast("This action couldn't be completed. Please try again.");
    }
  }

  Future<List<Club>> getNearbyClubsWithinDistance(List<Club> clubs) async{
    StorageSystem ss = StorageSystem();
    String? user = await ss.getItem("user");
    if (user == null) {
      return [];
    }
    Map<String, dynamic> userData = jsonDecode(user);
    Map<String, dynamic> userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
    Map<String, dynamic> position = userLocationDetails["position"];
    List<Club> nearBy = [];
    for (var club in clubs) {
      double dist = GeoFirePoint(position["geopoint"]).distanceBetweenInKm(geopoint: club.locationDetails["position"]["geopoint"]);
      // print(dist);
      if(dist <= 40) {
        nearBy.add(club);
      }
    }
    return nearBy;
    // return clubs.map((club) {
    //   double dist = GeoFirePoint(position["geopoint"]).distanceBetweenInKm(geopoint: club.locationDetails["position"]["geopoint"]);
    //   if(dist <= 20.0) {
    //     return club;
    //   }
    // }).toList();
  }

}

final clubNotifierProvider =
StateNotifierProvider<ClubStateNotifier, ClubState>(
      (ref) => ClubStateNotifier(ref),
);

final clubExceptionProvider = StateProvider<CustomException?>((ref) => null);
