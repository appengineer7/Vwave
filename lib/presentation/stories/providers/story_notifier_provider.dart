import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/presentation/stories/providers/story_state.dart';
import '../../../common/providers/firebase.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/general.dart';
import '../../auth/models/user.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

class StoryStateNotifier extends StateNotifier<StoryState> {

  final Ref ref;
  StoryStateNotifier(this.ref)
      : super(
    const StoryState(
      storyFeed: [],
      loading: false,
      loadingMore: false,
      loadingMoreError: '',
      error: '',
      maxReached: false,
      hasEnded: true,
    ),
  );

  // void setCurrentStoryFeedId(String id) {
  //   state = state.copyWith(currentFeedId: id);
  // }
  //
  // String getCurrentStoryFeedId() {
  //   return state.currentFeedId;
  // }

  List<StoryFeed> getCurrentStoryFeeds() {
    return state.storyFeed;
  }

  Future<void> getStoryFeeds({bool isRefreshed = false, bool reArrangeStories = false}) async {
    try {
      // if(state.storyFeed.isNotEmpty && reArrangeStories) {
      //   final SharedPreferences prefs = await SharedPreferences.getInstance();
      //   final stories = state.storyFeed;
      //   final arrangedStories = ref.read(storyRepositoryProvider).reArrangeStories(stories, prefs);
      //   state = state.copyWith(loading: false, copiedStoryFeed: arrangedStories);
      //   return;
      // }
      // if(state.storyFeed.isNotEmpty && !isRefreshed) {
      //   return;
      // }
      state = state.copyWith(loading: true);
      final today = DateTime.now();
      final dateFrom = today.subtract(const Duration(days: 1));
      final dateTo = today;
      final tsFrom = Timestamp.fromDate(dateFrom);
      final tsTo = Timestamp.fromDate(dateTo);
      ref
          .read(firebaseFirestoreProvider)
          .collection('stories')
          .where("timestamp", isGreaterThanOrEqualTo: tsFrom)
          .where("timestamp", isLessThanOrEqualTo: tsTo)
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((event) async {
        final stories = await ref.read(storyRepositoryProvider).getStoryFeeds();
        state = state.copyWith(loading: false, copiedStoryFeed: stories);
      });
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> deleteStory(StoryFeed story, int currentIndex) async {
    await ref.read(storyRepositoryProvider).deleteStory(story, currentIndex);
    GeneralUtils.showToast("Story deleted.");
  }

  Future<bool> hasStoryViewed(StoryFeed story) async {
    return await ref.read(storyRepositoryProvider).hasStoryViewed(story);
  }

  Future<FileInfo?> fetchCachedFile(String url) async {
    return await ref.read(storyRepositoryProvider).fetchCachedFile(url);
  }

  Future<void> uploadStoryViewData(Map<String, dynamic> viewData, String storyId, String mediaId) async {
    await ref.read(storyRepositoryProvider).uploadStoryViewData(viewData, storyId, mediaId);
  }

  // Future<int> getViewedUsersCount(String storyId, String mediaId) async {
  //   return await ref.read(storyRepositoryProvider).getViewedUsersCount(storyId, mediaId);
  // }

  Future<List<Map<String, dynamic>>> getViewedUsersList(String storyId, String mediaId) async {
    return await ref.read(storyRepositoryProvider).getViewedUsersList(storyId, mediaId);
  }

  // Future<void> initialize(String url) async {
  //   await ref.read(storyRepositoryProvider).initialize(url);
  // }

}

final storyNotifierProvider =
StateNotifierProvider<StoryStateNotifier, StoryState>(
      (ref) => StoryStateNotifier(ref),
);

final clubExceptionProvider = StateProvider<CustomException?>((ref) => null);
