
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/common/providers/firebase.dart';
import 'package:vwave/presentation/stories/models/story.dart';
import 'package:vwave/presentation/stories/repositories/video_cache_manager.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';

import '../../../utils/exceptions.dart';

abstract class BaseStoryRepository {
  Future<List<StoryFeed>> getStoryFeeds();
  Future<bool> hasStoryViewed(StoryFeed story);
  Future<FileInfo?> fetchCachedFile(String url);
  Future<void> uploadStoryViewData(Map<String, dynamic> viewData, String storyId, String mediaId);
  // Future<int> getViewedUsersCount(String storyId, String mediaId);
  Future<List<Map<String, dynamic>>> getViewedUsersList(String storyId, String mediaId);
  Future<void> deleteStory(StoryFeed story, int currentIndex);
  // Future<void> initialize(String dataSource);
}

class StoryRepository implements BaseStoryRepository {
  final Ref ref;

  const StoryRepository(this.ref);

  String _getCacheKey(String dataSource) {
    return 'cached_video_player_video_expiration_of_${Uri.parse(
      dataSource,
    )}';
  }

  /// Attempts to open the given [dataSource] and load metadata about the video.

  /// This will remove cached file from cache of the given [dataSource].
  Future<void> removeCurrentFileFromCache(String dataSource) async {
    final cacheManager = VideoCacheManager();
    final storage = GetStorage('cached_video_player');
    await storage.initStorage;

    await Future.wait([
      cacheManager.removeFile(dataSource),
      storage.remove(_getCacheKey(dataSource)),
    ]);
  }

  /// This will remove cached file from cache of the given [url].
  static Future<void> removeFileFromCache(String url) async {
    final cacheManager = VideoCacheManager();
    final storage = GetStorage('cached_video_player');
    await storage.initStorage;

    url = Uri.parse(url).toString();

    await Future.wait([
      cacheManager.removeFile(url),
      storage.remove('cached_video_player_video_expiration_of_$url'),
    ]);
  }

  /// Clears all cached videos.
  static Future<void> clearAllCache() async {
    final cacheManager = VideoCacheManager();
    final storage = GetStorage('cached_video_player');
    await storage.initStorage;

    await Future.wait([
      cacheManager.emptyCache(),
      storage.erase(),
    ]);
  }

  @override
  Future<List<StoryFeed>> getStoryFeeds() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();

      // final dateFrom = DateTime(today.year, today.month, today.day, 0, 0, 0);
      final dateFrom = today.subtract(const Duration(days: 1));
      final dateTo = today; //DateTime(today.year, today.month, today.day, 23, 59, 59);
      final tsFrom = Timestamp.fromDate(dateFrom);
      final tsTo = Timestamp.fromDate(dateTo);
      final getStories = await FirebaseFirestore.instance.collection("stories").where("timestamp", isGreaterThanOrEqualTo: tsFrom).where("timestamp", isLessThanOrEqualTo: tsTo).orderBy("timestamp", descending: true).get(); //.get();
      // check story privacy
      List<StoryFeed> allowedStories = [];
      for (var st in getStories.docs) {
        final story = StoryFeed.fromDocument(st);
        final isAllowed = await allowCurrentUserViewStory(story);
        if(isAllowed) {
          allowedStories.add(story);
        }
      }
      // return reArrangeStories(getStories.docs.map((e) => StoryFeed.fromDocument(e)).toList(), prefs);
      return reArrangeStories(allowedStories, prefs);
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Future<bool> allowCurrentUserViewStory(StoryFeed story) async {
    if(GeneralUtils().userUid == story.userUid) {
      return true;
    }

    List<String> allowedUid = story.allowedUid ?? [];
    if(allowedUid.contains(GeneralUtils().userUid)) {
      return true;
    }
    final storyPrivacyOption = story.storyPrivacy ?? "everyone";

    if(storyPrivacyOption == "everyone") {
      return true;
    }
    if(storyPrivacyOption == "i_follow") {
      final followingCheck = await ref.read(firebaseFirestoreProvider).collection("users").doc(story.userUid).collection("following").doc(GeneralUtils().userUid).get();
      if(followingCheck.exists) {
        await ref.read(firebaseFirestoreProvider).collection("stories").doc(story.id).update(
            {
              "allowed_uid": FieldValue.arrayUnion([GeneralUtils().userUid])
            });
        return true;
      }
      return false;
    }
    // story privacy option is follows_me
    final followerCheck = await ref.read(firebaseFirestoreProvider).collection("users").doc(story.userUid).collection("followers").doc(GeneralUtils().userUid).get();
    if(followerCheck.exists) {
      await ref.read(firebaseFirestoreProvider).collection("stories").doc(story.id).update(
          {
            "allowed_uid": FieldValue.arrayUnion([GeneralUtils().userUid])
          });
      return true;
    }
    return false;
  }

  @override
  Future<void> uploadStoryViewData(Map<String, dynamic> viewData, String storyId, String mediaId) async {
    try {
      String id = "${GeneralUtils().userUid}-$storyId-$mediaId";

      final checkViewed = await ref.read(firebaseFirestoreProvider).collection("stories").doc(storyId).collection("viewed-users").doc(id).get();

      if(checkViewed.exists) {
        return;
      }

      await ref.read(firebaseFirestoreProvider).collection("stories").doc(storyId).collection("viewed-users").doc(id).set(viewData);

      await ref.read(firebaseFirestoreProvider).collection("stories").doc(storyId).update({
        "views_count.$mediaId": FieldValue.increment(1)
      });

    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  // @override
  // Future<int> getViewedUsersCount(String storyId, String mediaId) async {
  //   final mCount = await ref.read(firebaseFirestoreProvider).collection("stories").doc(storyId).collection("viewed-users").where("storyId", isEqualTo: storyId).where("mediaId", isEqualTo: mediaId).count().get();
  //   return mCount.count ?? 0;
  // }

  @override
  Future<List<Map<String, dynamic>>> getViewedUsersList(String storyId, String mediaId) async {
    final snapshot = await ref.read(firebaseFirestoreProvider).collection("stories").doc(storyId).collection("viewed-users").where("storyId", isEqualTo: storyId).where("mediaId", isEqualTo: mediaId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<bool> hasStoryViewed(StoryFeed story) async {
    List<bool> listViewedMedia = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var file in story.files) {
      bool getViewed = hasViewedStory(story.id!, file["id"], prefs);
      listViewedMedia.add(getViewed);
    }
    return !listViewedMedia.contains(false);
  }

  List<StoryFeed> reArrangeStories(List<StoryFeed> stories, SharedPreferences prefs) {

    List<StoryFeed> listStories = [];

    for (var story in stories) {
      // check for expired stories
      // story.files.removeWhere((e) => hasStoryMediaExpired(e));
      // final deleteMedia = story.files.where((e) => hasStoryMediaExpired(e)).toList();
      // if(deleteMedia.isNotEmpty) {
      //
      // }
      listStories.add(story);
    }

    for (var story in stories) {
      List<bool> listViewedMedia = [];
      for (var file in story.files) {
        bool getViewed = hasViewedStory(story.id!, file["id"], prefs);
        listViewedMedia.add(getViewed);
      }
      if(!listViewedMedia.contains(false)) {
        listStories.remove(story);
        listStories.insert(listStories.length, story);
      }
    }

    return listStories;
  }

  bool hasStoryMediaExpired(Map<String, dynamic> sf) {
    final createdDate = DateTime.parse(sf["created_date"]).toUtc();
    final today = DateTime.now().toUtc();
    final difference = today.difference(createdDate).inHours;
    return difference >= 24;
  }

  bool hasViewedStory(String storyId, String mediaId, SharedPreferences prefs) {
    return prefs.getBool("$storyId/$mediaId") ?? false;
  }

  @override
  Future<void> deleteStory(StoryFeed story, int currentIndex) async {
    try {
      if(story.files.length == 1) {
        // delete story document
        await ref.read(firebaseFirestoreProvider).collection("stories").doc(GeneralUtils().userUid).delete();
        return;
      }
      // delete a particular file
      final fileToDelete = story.files[currentIndex];
      fileToDelete.remove("linearProgressBarValue");

      await ref.read(firebaseFirestoreProvider).collection("stories").doc(GeneralUtils().userUid).update({
        "files": FieldValue.arrayRemove([fileToDelete]),
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Future<FileInfo?> fetchCachedFile(String url) async {
    // final cacheManager = VideoCacheManager();
    final cacheManager = CacheManager(Config("libCachedVideoPlayerData"));
    FileInfo? cachedFile = await cacheManager.getFileFromCache(url);
    return cachedFile;
  }
}

final storyRepositoryProvider = Provider<StoryRepository>(
      (ref) => StoryRepository(ref),
);