import 'package:flutter/foundation.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';


@immutable
class LivestreamState {
  const LivestreamState({
    required this.livestream,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.loadingMoreError,
    required this.maxReached,
    required this.hasEnded,
    // this.newProduct,
    // this.savedProducts,
    required this.recentLivestreams,
    required this.searchedLivestreams,
    required this.clubFollowers,
  });

  // All properties should be `final` on our class.
  final List<Livestream> livestream;
  final bool loading;
  final bool loadingMore;
  final String error;
  final String loadingMoreError;
  final bool maxReached;
  final bool hasEnded;
  // final Livestream? newLivestream;
  // final List<Map<String, dynamic>>? savedProducts;
  final List<Livestream> recentLivestreams;
  final List<Livestream> searchedLivestreams;
  final List<dynamic> clubFollowers;

  // Since ProductState is immutable, we implement a method that allows cloning the
  // ProductState with slightly different content.
  LivestreamState copyWith({
    List<Livestream>? livestreams,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? loadingMoreError,
    bool? maxReached,
    bool? hasEnded,
    // Product? newProduct,
    // List<Map<String, dynamic>>? savedProducts,
    List<Livestream>? recentLivestreams,
    List<Livestream>? searchedLivestreams,
    List<dynamic>? clubFollowers,
  }) {
    return LivestreamState(
      livestream: livestreams ?? livestream,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      maxReached: maxReached ?? this.maxReached,
      hasEnded: hasEnded ?? this.hasEnded,
      // newProduct: newProduct ?? this.newProduct,
      // savedProducts: savedProducts ?? this.savedProducts,
      recentLivestreams: recentLivestreams ?? this.recentLivestreams,
      searchedLivestreams: searchedLivestreams ?? this.searchedLivestreams,
      clubFollowers: clubFollowers ?? this.clubFollowers,
    );
  }
}
