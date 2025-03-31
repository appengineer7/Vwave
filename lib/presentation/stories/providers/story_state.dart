import 'package:flutter/foundation.dart';

import '../models/story.dart';


@immutable
class StoryState {
  const StoryState({
    required this.storyFeed,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.loadingMoreError,
    required this.maxReached,
    required this.hasEnded,
  });

  // All properties should be `final` on our class.
  final List<StoryFeed> storyFeed;
  final bool loading;
  final bool loadingMore;
  final String error;
  final String loadingMoreError;
  final bool maxReached;
  final bool hasEnded;

  // Since ProductState is immutable, we implement a method that allows cloning the
  // ProductState with slightly different content.
  StoryState copyWith({
    List<StoryFeed>? copiedStoryFeed,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? loadingMoreError,
    bool? maxReached,
    bool? hasEnded,
  }) {
    return StoryState(
      storyFeed: copiedStoryFeed ?? storyFeed,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      maxReached: maxReached ?? this.maxReached,
      hasEnded: hasEnded ?? this.hasEnded,
    );
  }
}
