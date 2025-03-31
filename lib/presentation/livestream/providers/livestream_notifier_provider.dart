import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/utils/exceptions.dart';
import 'package:vwave/utils/general.dart';

import '../../../common/providers/firebase.dart';
import '../repositories/livestream_repository.dart';
import 'livestream_state.dart';

class LivestreamStateNotifier extends StateNotifier<LivestreamState> {
  final Ref ref;
  LivestreamStateNotifier(this.ref)
      : super(
          const LivestreamState(
              livestream: [],
              loading: false,
              loadingMore: false,
              loadingMoreError: '',
              error: '',
              maxReached: false,
              hasEnded: false,
              recentLivestreams: [],
              searchedLivestreams: [],
              clubFollowers: []),
        );

  void setStateLoading(bool isLoading) async {
    state = state.copyWith(loading: isLoading);
  }

  void setStateHasEnded(bool ended) async {
    state = state.copyWith(hasEnded: ended);
  }

  Future<void> getRecentLivestreamsAndClubFollowers(
      {bool getClubFollower = true}) async {
    state = state.copyWith(loading: true);

    try {
      final recentLivestreams = await ref
          .read(livestreamRepositoryProvider)
          .getClubOwnerRecentLivestreams();
      List<dynamic> clubFollowers = [];
      if (getClubFollower) {
        clubFollowers =
            await ref.read(livestreamRepositoryProvider).getClubFollowers();
        state = state.copyWith(
            loading: false,
            recentLivestreams: recentLivestreams,
            clubFollowers: clubFollowers);
      } else {
        state = state.copyWith(
            loading: false, recentLivestreams: recentLivestreams);
      }
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getLivestreams({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(loading: true);
    }

    try {
      // final livestreams = await ref.read(livestreamRepositoryProvider).getLivestreams();
      ref
          .read(firebaseFirestoreProvider)
          .collection('livestreams')
          .where("has_ended", isEqualTo: false)
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((event) async {
        final livestreams = await ref.read(livestreamRepositoryProvider).getLivestreams();
        state = state.copyWith(loading: false, livestreams: livestreams);
      });
      // state = state.copyWith(loading: false, livestreams: livestreams);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getLivestreamsNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    state = state.copyWith(loading: true);

    try {
      final livestreams = await ref.read(livestreamRepositoryProvider).getLivestreamsNearMe(distance: distance, location: location);

      state = state.copyWith(loading: false, searchedLivestreams: livestreams);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<bool?> hasLivestreamEnded(Livestream livestream) async {
    state = state.copyWith(loading: true);

    try {
      final hasEnded = await ref
          .read(livestreamRepositoryProvider)
          .hasLivestreamEnded(livestream);

      state = state.copyWith(loading: false, hasEnded: hasEnded);
      return hasEnded;
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
      return null;
    }
  }

  Future<void> updateLivestream(
      Livestream livestream, Map<String, dynamic> livestreamData) async {
    try {
      await ref
          .read(livestreamRepositoryProvider)
          .updateLivestream(livestream, livestreamData);
    } on CustomException catch (e) {}
  }

  //
  // Future<void> deleteSavedItem(String itemId, String productId) async {
  //   try {
  //     await ref.read(savedItemsRepositoryProvider).deleteSavedItem(itemId, productId);
  //     state.savedProducts!.removeWhere((element) => element["item_id"] == itemId);
  //     state = state.copyWith(loading: false, savedProducts: state.savedProducts!);
  //   } on CustomException catch (e) {
  //     GeneralUtils.showToast("This action couldn't be completed. Please try again.");
  //   }
  // }
}

final livestreamNotifierProvider =
    StateNotifierProvider<LivestreamStateNotifier, LivestreamState>(
  (ref) => LivestreamStateNotifier(ref),
);

final livestreamExceptionProvider =
    StateProvider<CustomException?>((ref) => null);
