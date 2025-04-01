import 'package:flutter/foundation.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';


@immutable
class ClubEventState {
  const ClubEventState({
    required this.clubEvents,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.loadingMoreError,
    required this.maxReached,
    required this.hasEnded,
    required this.upcomingEvents,
    required this.searchedEvents,
  });

  // All properties should be `final` on our class.
  final List<ClubEvent> clubEvents;
  final bool loading;
  final bool loadingMore;
  final String error;
  final String loadingMoreError;
  final bool maxReached;
  final bool hasEnded;
  final List<ClubEvent> upcomingEvents;
  final List<ClubEvent> searchedEvents;

  // Since ProductState is immutable, we implement a method that allows cloning the
  // ProductState with slightly different content.
  ClubEventState copyWith({
    List<ClubEvent>? clubEvents,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? loadingMoreError,
    bool? maxReached,
    bool? hasEnded,
    List<ClubEvent>? upcomingEvents,
    List<ClubEvent>? searchedEvents,
  }) {
    return ClubEventState(
      clubEvents: clubEvents ?? this.clubEvents,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      maxReached: maxReached ?? this.maxReached,
      hasEnded: hasEnded ?? this.hasEnded,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      searchedEvents: searchedEvents ?? this.searchedEvents,
    );
  }
}
