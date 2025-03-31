import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:vwave_new/common/providers/firebase.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/utils/exceptions.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';

abstract class BaseLivestreamRepository {
  Future<List<Livestream>> getClubOwnerRecentLivestreams();
  Future<List<dynamic>> getClubFollowers();
  Future<List<Livestream>> getLivestreams();
  Future<List<Livestream>> getLivestreamsNearMe();
  Future<bool> hasLivestreamEnded(Livestream livestream);
  Future<void> updateLivestream(Livestream livestream, Map<String, dynamic> livestreamData);
  Future<void> deleteSavedItem(String itemId, String productId);
}

class LivestreamRepository implements BaseLivestreamRepository {
  final Ref ref;

  const LivestreamRepository(this.ref);

  @override
  Future<List<Livestream>> getClubOwnerRecentLivestreams() async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('livestreams')
          .where("user_uid", isEqualTo: GeneralUtils().userUid)
          // .where("has_ended", isEqualTo: true)
          .orderBy("timestamp", descending: true)
          .get();

      return snapshot.docs.map((e) => Livestream.fromJson(e.data())).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<dynamic>> getClubFollowers() async {
    try {
      String url = "getfollowers?user_uid=${GeneralUtils().userUid}&user_type=club";

      final res = await GeneralUtils().makeRequest(url, {}, method: "get");

      if(res.statusCode != 200) {
        return [];
      }

      final body = jsonDecode(res.body);

      List<dynamic> data = body["data"];

      return data.map((e) => e).toList();

    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Livestream>> getLivestreams({double distance = 80}) async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('livestreams')
          .where("has_ended", isEqualTo: false)
          .orderBy("timestamp", descending: true)
          .get();

      return snapshot.docs.map((e) => Livestream.fromJson(e.data())).toList();
      // StorageSystem ss = StorageSystem();
      // String? user = await ss.getItem("user");
      // if (user == null) {
      //   return [];
      // }
      // Map<String, dynamic> userData = jsonDecode(user);
      // Map<String, dynamic> loc = userData["location_details"];
      //
      // final geoCollection = ref.read(firebaseFirestoreProvider).collection(
      //     'livestreams');
      // final snapshot = await GeoCollectionReference(geoCollection)
      //     .fetchWithinWithDistance(
      //     center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])),
      //     radiusInKm: distance,
      //     field: "location_details.position",
      //     geopointFrom: (point) {
      //       return GeoPoint(loc["latitude"], loc["longitude"]);
      //     },
      //     queryBuilder: (q) {
      //       return ref.read(firebaseFirestoreProvider)
      //           .collection('livestreams')
      //           .where("has_ended", isEqualTo: false);
      //     },
      //     strictMode: true);
      //
      // snapshot.sort((a, b) =>
      //     a.distanceFromCenterInKm.compareTo(b.distanceFromCenterInKm));
      //
      // return snapshot.map((e) => Livestream.fromDocument(e.documentSnapshot))
      //     .toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Livestream>> getLivestreamsNearMe({double distance = 40, Map<String, dynamic>? location}) async {
    try {
      StorageSystem ss = StorageSystem();
      String? user = await ss.getItem("user");
      if (user == null) {
        return [];
      }
      Map<String, dynamic> userData = jsonDecode(user);
      Map<String, dynamic> loc = location ?? userData["location_details"];

      final geoCollection = ref.read(firebaseFirestoreProvider).collection('livestreams');
      final snapshot = await GeoCollectionReference(geoCollection).fetchWithinWithDistance(center: GeoFirePoint(GeoPoint(loc["latitude"], loc["longitude"])), radiusInKm: distance, field: "location_details.position", geopointFrom: (point) {
        return GeoPoint(loc["latitude"], loc["longitude"]);
      },
          queryBuilder: (q) {
            return ref.read(firebaseFirestoreProvider).collection('livestreams').where("has_ended", isEqualTo: false);
          },
          strictMode: true);

      snapshot.sort((a,b) => a.distanceFromCenterInKm.compareTo(b.distanceFromCenterInKm));

      return snapshot.map((e) => Livestream.fromDocument(e.documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<bool> hasLivestreamEnded(Livestream livestream) async {
    try {
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('livestreams')
          .doc(livestream.id)
          .get();
      if(!snapshot.exists) {
        return false;
      }
      Livestream ls = Livestream.fromDocument(snapshot);
      return ls.hasEnded;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateLivestream(Livestream livestream, Map<String, dynamic> livestreamData) async {
    try {
      await ref
          .read(firebaseFirestoreProvider)
          .collection('livestreams')
          .doc(livestream.id).update(livestreamData);
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteSavedItem(String itemId, String productId) async {
    try {
      await ref
          .read(firebaseFirestoreProvider)
          .collection('saved-products').doc(itemId).delete();
      await StorageSystem().deletePref("product_$productId");
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}

final livestreamRepositoryProvider = Provider<LivestreamRepository>(
      (ref) => LivestreamRepository(ref),
);
