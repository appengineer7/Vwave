import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:vwave_new/common/providers/firebase.dart';
import 'package:vwave_new/presentation/club/models/club.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/services/hive_database.dart';
import 'package:vwave_new/utils/exceptions.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';

abstract class BaseClubRepository {
  Future<List<Club>> getClubs();
  Future<List<Club>> getClubsFromHive();
  Future<List<Club>> getMoreClubs(Club club);
  Future<List<Club>> getClubsNearMe();
  Future<List<Map<String, dynamic>>> getSavedClubs();
  Future<void> deleteSavedClub(String itemId, String clubId);
  Future<void> saveFavoriteClubs(Club club);
}

class ClubRepository implements BaseClubRepository {
  final Ref ref;

  const ClubRepository(this.ref);

  @override
  Future<List<Club>> getClubs({double distance = 80}) async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('clubs')
          .where("verified", isEqualTo: true)
          .get();
      return snapshot.docs.map((e) => Club.fromDocument(e)).toList();

      // StorageSystem ss = StorageSystem();
      // String? user = await ss.getItem("user");
      // if (user == null) {
      //   return [];
      // }
      // Map<String, dynamic> userData = jsonDecode(user);
      // Map<String, dynamic> loc = userData["location_details"];
      //
      // final geoCollection = ref.read(firebaseFirestoreProvider).collection('clubs');
      // final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
      //   return GeoPoint(loc["latitude"], loc["longitude"]);
      // },
      //     queryBuilder: (q) {
      //   return ref.read(firebaseFirestoreProvider).collection('clubs').where("verified", isEqualTo: true);
      // },
      //     strictMode: true);
      //
      // // save data to hiveDb
      // // final hiveDb = HiveDb();
      // // await hiveDb.addNewDataCollection("clubs", snapshot.map((s) => s.documentSnapshot.data()!).toList());
      //
      // return snapshot.map((e) => Club.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Club>> getClubsFromHive() async {
    // get data from hiveDb
    // final hiveDb = HiveDb();
    // final List<Map<String, dynamic>> snapshot = hiveDb.fetchDataCollection("clubs");
    //
    // return snapshot.map((e) => Club.fromJson(e)).toList();
    return [];
  }

  @override
  Future<List<Club>> getMoreClubs(Club club, {double distance = 80}) async {
    try {
      StorageSystem ss = StorageSystem();
      String? user = await ss.getItem("user");
      if (user == null) {
        return [];
      }
      Map<String, dynamic> userData = jsonDecode(user);
      Map<String, dynamic> loc = userData["location_details"];

      final geoCollection = ref.read(firebaseFirestoreProvider).collection('clubs');
      final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
        return GeoPoint(loc["latitude"], loc["longitude"]);
      },
      //     queryBuilder: (q) {
      //   return ref.read(firebaseFirestoreProvider).collection('clubs').startAfterDocument(club.toDocument() as DocumentSnapshot<Object?>).limit(10);
      // },
          strictMode: true);

      return snapshot.map((e) => Club.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Club>> getClubsNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    try {
      StorageSystem ss = StorageSystem();
      String? user = await ss.getItem("user");
      if (user == null) {
        return [];
      }
      Map<String, dynamic> userData = jsonDecode(user);
      Map<String, dynamic> loc = location ?? userData["location_details"];

      final geoCollection = ref.read(firebaseFirestoreProvider).collection('clubs');
      final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
        return GeoPoint(loc["latitude"], loc["longitude"]);
      },
          queryBuilder: (q) {
        return ref.read(firebaseFirestoreProvider).collection('clubs').where("verified", isEqualTo: true);
      },
          strictMode: true);

      return snapshot.map((e) => Club.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<String?> saveFavoriteClubs(Club club) async {
    try {
      if (GeneralUtils().userUid == null) {
        GeneralUtils.showToast("Please login to continue");
        return null;
      }
      StorageSystem ss = StorageSystem();
      String? isSaved = await ss.getItem("club_${club.id}");
      if (isSaved == "true") {
        await ss.deletePref("club_${club.id}");
        GeneralUtils.showToast("Club removed");
        final spQ = await FirebaseFirestore.instance
            .collection("saved-clubs")
            .where("item_uid", isEqualTo: GeneralUtils().userUid)
            .where("id", isEqualTo: club.id)
            .limit(1)
            .get();
        if (spQ.docs.isEmpty) {
          return null;
        }
        final sp = spQ.docs[0].data();
        if (sp["item_id"] == null) {
          return null;
        }
        await FirebaseFirestore.instance
            .collection("saved-clubs")
            .doc(sp["item_id"])
            .delete();
        return sp["item_id"]; // to delete
      }
      // final p = club.copyWith(
      //   link: "",
      // );
      // check if exist
      final clubCheck = await FirebaseFirestore.instance.collection("saved-clubs").where("item_uid", isEqualTo: GeneralUtils().userUid).where("id", isEqualTo: club.id).count().get();
      if(clubCheck.count! > 0) {
        await ss.setPrefItem("club_${club.id}", "true");
        return null;
      }
      String id = FirebaseFirestore.instance.collection("saved-clubs").doc().id;
      Map<String, dynamic> savedItem = {
        "item_id": id,
        "item_uid": GeneralUtils().userUid,
        ...club.toJson(),
      };
      await FirebaseFirestore.instance
          .collection("saved-clubs")
          .doc(id)
          .set(savedItem);
      await ss.setPrefItem("club_${club.id}", "true");
      return null;
      // GeneralUtils.showToast("Club saved");
      // return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedClubs() async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('saved-clubs')
          .where("item_uid", isEqualTo: GeneralUtils().userUid)
          .orderBy("timestamp", descending: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data.remove("item_id");
        data.remove("item_uid");
        Club club = Club.fromJson(data);
        StorageSystem().setPrefItem("club_${club.id}", "true");
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final itemId = data["item_id"];
        final itemUid = data["item_uid"];
        data.remove("item_id");
        data.remove("item_uid");
        Club club = Club.fromJson(data);
        return {"item_id": itemId, "item_uid": itemUid, "club": club};
      }).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteSavedClub(String itemId, String clubId) async {
    try {
      await ref
          .read(firebaseFirestoreProvider)
          .collection('saved-clubs').doc(itemId).delete();
      await StorageSystem().deletePref("club_$clubId");
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

}

final clubRepositoryProvider = Provider<ClubRepository>(
      (ref) => ClubRepository(ref),
);
