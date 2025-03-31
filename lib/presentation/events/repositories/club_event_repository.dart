import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:vwave/common/providers/firebase.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/utils/exceptions.dart';
import 'package:vwave/utils/general.dart';

import '../../../services/hive_database.dart';
import '../../../utils/storage.dart';

abstract class BaseClubEventRepository {
  Future<List<ClubEvent>> getClubEvents();
  Future<List<ClubEvent>> getClubEventsForUsers();
  Future<List<ClubEvent>> getClubEventsForUsersFromHive();
  Future<List<ClubEvent>> getEventsForUsersNearMe();
  Future<List<ClubEvent>> getUpcomingEvents(List<ClubEvent> events);
  Future<void> deleteClubEvent(String id);
}

class ClubEventRepository implements BaseClubEventRepository {
  final Ref ref;

  const ClubEventRepository(this.ref);

  @override
  Future<List<ClubEvent>> getClubEvents() async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('club_events')
          .where("club_id", isEqualTo: GeneralUtils().userUid)
          .orderBy("created_timestamp", descending: true)
          .get();

      return snapshot.docs.map((e) => ClubEvent.fromJson(e.data())).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<ClubEvent>> getUpcomingEvents(List<ClubEvent> events) async {

    List<ClubEvent> upcomingEvents = [];

    for (var evt in events) {
      final today = DateTime.now();
      final date = GeneralUtils().getConvertedDateTime(evt.eventDate, evt.timeZone);
      final eventDate = DateTime.parse(date);
      int difference = eventDate.difference(today).inMilliseconds;
      if(difference > 0) {
        upcomingEvents.add(evt);
      }
    }

    return upcomingEvents;
  }

  @override
  Future<void> deleteClubEvent(String id) async {
    try {
      await ref
          .read(firebaseFirestoreProvider)
          .collection('club_events').doc(id).delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<ClubEvent>> getClubEventsForUsers({double distance = 80}) async {
    try {
      final today = DateTime.now();
      final tsTo = Timestamp.fromDate(today);

      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('club_events')
          .where("event_date_timestamp", isGreaterThanOrEqualTo: tsTo)
          .get();
      return snapshot.docs.map((e) => ClubEvent.fromDocument(e)).toList();

      // StorageSystem ss = StorageSystem();
      // String? user = await ss.getItem("user");
      // if (user == null) {
      //   return [];
      // }
      // Map<String, dynamic> userData = jsonDecode(user);
      // Map<String, dynamic> loc = userData["location_details"];
      //
      // final geoCollection = ref.read(firebaseFirestoreProvider).collection('club_events');
      // final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
      //   return GeoPoint(loc["latitude"], loc["longitude"]);
      // },
      //     queryBuilder: (q) {
      //       return ref.read(firebaseFirestoreProvider).collection('club_events').where("event_date_timestamp", isGreaterThanOrEqualTo: tsTo);
      //     },
      //     strictMode: true);
      //
      // // save data to hiveDb
      // // final hiveDb = HiveDb();
      // // await hiveDb.addNewDataCollection("events", snapshot.map((s) => s.documentSnapshot.data()!).toList());
      //
      // snapshot.sort((a,b) => a.distanceFromCenterInKm.compareTo(b.distanceFromCenterInKm));
      //
      // return snapshot.map((e) => ClubEvent.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<ClubEvent>> getEventsForUsersNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    try {
      final today = DateTime.now();
      final tsTo = Timestamp.fromDate(today);

      StorageSystem ss = StorageSystem();
      String? user = await ss.getItem("user");
      if (user == null) {
        return [];
      }
      Map<String, dynamic> userData = jsonDecode(user);
      Map<String, dynamic> loc = location ?? userData["location_details"];

      final geoCollection = ref.read(firebaseFirestoreProvider).collection('club_events');
      final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
        return GeoPoint(loc["latitude"], loc["longitude"]);
      },
          queryBuilder: (q) {
            return ref.read(firebaseFirestoreProvider).collection('club_events').where("event_date_timestamp", isGreaterThanOrEqualTo: tsTo);
          },
          strictMode: true);

      snapshot.sort((a,b) => a.distanceFromCenterInKm.compareTo(b.distanceFromCenterInKm));

      return snapshot.map((e) => ClubEvent.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<ClubEvent>> getClubEventsForUsersFromHive() async {
    // get data from hiveDb
    // final hiveDb = HiveDb();
    // final List<Map<String, dynamic>> snapshot = hiveDb.fetchDataCollection("events");
    //
    // return snapshot.map((e) => ClubEvent.fromJson(e)).toList();
    return [];
  }
}

final clubEventRepositoryProvider = Provider<ClubEventRepository>(
      (ref) => ClubEventRepository(ref),
);
