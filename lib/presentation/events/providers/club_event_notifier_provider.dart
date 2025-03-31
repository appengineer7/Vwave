
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/events/providers/club_event_state.dart';
import 'package:vwave/utils/exceptions.dart';

import '../models/club_event.dart';
import '../repositories/club_event_repository.dart';


class ClubEventStateNotifier extends StateNotifier<ClubEventState> {
  final Ref ref;
  ClubEventStateNotifier(this.ref)
      : super(
    const ClubEventState(
        clubEvents: [],
        loading: false,
        loadingMore: false,
        loadingMoreError: '',
        error: '',
        maxReached: false,
        hasEnded: false,
        upcomingEvents: [],
        searchedEvents: [],
    ),
  );

  void setStateLoading(bool isLoading) async {
    state = state.copyWith(loading: isLoading);
  }

  void setUpcomingEvents(List<ClubEvent> clubEvents) async {
    state = state.copyWith(upcomingEvents: clubEvents);
  }

  Future<void> getClubEvents() async {
    try {
      state = state.copyWith(loading: true);
      final events = await ref.read(clubEventRepositoryProvider).getClubEvents();

      // get upcoming events
      final upcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);

      state = state.copyWith(loading: false, clubEvents: events, upcomingEvents: upcomingEvents);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getClubEventsForUsersFromHive() async {
    try {
      state = state.copyWith(loading: true);
      final events = await ref.read(clubEventRepositoryProvider).getClubEventsForUsersFromHive();

      // get upcoming events
      final upcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);

      print(upcomingEvents);

      // state = state.copyWith(loading: false, upcomingEvents: upcomingEvents);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getClubEventsForUsers() async {
    try {
      state = state.copyWith(loading: true);
      final events = await ref.read(clubEventRepositoryProvider).getClubEventsForUsers();

      // get upcoming events
      final upcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);

      state = state.copyWith(loading: false, upcomingEvents: upcomingEvents);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> getEventsForUsersNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    state = state.copyWith(loading: true);

    try {
      final events = await ref.read(clubEventRepositoryProvider).getEventsForUsersNearMe(distance: distance, location: location);

      // get upcoming events
      final upcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);

      state = state.copyWith(loading: false, searchedEvents: upcomingEvents);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }

  Future<void> deleteClubEvent(ClubEvent clubEvent) async {
    await ref.read(clubEventRepositoryProvider).deleteClubEvent(clubEvent.id!);
    try {
      List<ClubEvent> events = List.from(state.clubEvents);
      events.remove(clubEvent);
      final upcomingEvents = await ref.read(clubEventRepositoryProvider).getUpcomingEvents(events);
      state = state.copyWith(loading: false, clubEvents: events, upcomingEvents: upcomingEvents);
    } on CustomException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    }
  }
}

final clubEventNotifierProvider =
StateNotifierProvider<ClubEventStateNotifier, ClubEventState>(
      (ref) => ClubEventStateNotifier(ref),
);

final clubEventExceptionProvider = StateProvider<CustomException?>((ref) => null);
