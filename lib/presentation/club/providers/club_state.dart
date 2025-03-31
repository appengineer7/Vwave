import 'package:flutter/foundation.dart';
import 'package:vwave/presentation/club/models/club.dart';


@immutable
class ClubState {
  const ClubState({
    required this.clubs,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.loadingMoreError,
    required this.maxReached,
    required this.nearbyClubs,
    required this.searchedNearbyClubs,
    // this.newProduct,
    required this.savedClubs,
  });

  // All properties should be `final` on our class.
  final List<Club> clubs;
  final bool loading;
  final bool loadingMore;
  final String error;
  final String loadingMoreError;
  final bool maxReached;
  final List<Club> nearbyClubs;
  final List<Club> searchedNearbyClubs;
  // final Livestream? newLivestream;
  final List<Map<String, dynamic>> savedClubs;

  // Since ProductState is immutable, we implement a method that allows cloning the
  // ProductState with slightly different content.
  ClubState copyWith({
    List<Club>? clubs,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? loadingMoreError,
    bool? maxReached,
    List<Club>? nearbyClubs,
    List<Club>? searchedNearbyClubs,
    // Product? newProduct,
    List<Map<String, dynamic>>? savedClubs,
  }) {
    return ClubState(
      clubs: clubs ?? this.clubs,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      maxReached: maxReached ?? this.maxReached,
      nearbyClubs: nearbyClubs ?? this.nearbyClubs,
      searchedNearbyClubs: searchedNearbyClubs ?? this.searchedNearbyClubs,
      // newProduct: newProduct ?? this.newProduct,
      savedClubs: savedClubs ?? this.savedClubs,
    );
  }
}
