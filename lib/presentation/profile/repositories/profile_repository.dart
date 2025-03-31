import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/firebase.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/general.dart';
import '../../auth/models/user.dart';

abstract class BaseProfileRepository {
  Future<User?> fetchUserById(String id);
  Future<User?> fetchMe();
  Future<void> performFriendRequest(bool isFollowingUser, String otherUserUid);
  Future<bool> checkConversationPrivacy(String allowConversation, String otherUserUid);
  Future<User?> updateProfile({
    required Map<String, dynamic> userData
    // required String id,
    // required String firstName,
    // required String lastName,
    // required bio,
  });
}

class ProfileRepository implements BaseProfileRepository {
  final Ref ref;

  const ProfileRepository(this.ref);

  // @override
  // Future<List<Tag>> getTags() async {
  //   try {
  //     final snapshot =
  //         await ref.read(firebaseFirestoreProvider).collection('tags').get();

  //     return snapshot.docs.map((doc) => Tag.fromDocument(doc)).toList();
  //   } on FirebaseException catch (e) {
  //     throw CustomException(message: e.message);
  //   }
  // }

  @override
  Future<User?> fetchUserById(String? id) async {
    try {
      // if(GeneralUtils().userUid == null || GeneralUtils().userUid != id!) {
      //   final res = await GeneralUtils().makeRequest("getuserdata", {"user_uid": id}, addUserCheck: false);
      //   if(res.statusCode != 200) {
      //     return null;
      //   }
      //   final body = jsonDecode(res.body);
      //   return User.fromJson(body["data"]);
      // }
      final snapshot = await ref
          .read(firebaseFirestoreProvider)
          .collection('users')
          .doc(id)
          .get();

      if (snapshot.exists) {
        final userObject = snapshot.data();
        if(userObject == null) {
          return null;
        }

        if(userObject["allow_conversations"] == null || userObject["allow_search_visibility"] == null || userObject["story_privacy"] == null) {
          userObject["allow_conversations"] = "allow";
          userObject["allow_search_visibility"] = true;
          userObject["story_privacy"] = "everyone";
        }
        return User.fromJson(userObject);
      }
      return null;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<User?> fetchMe() async {
    try {
      // final currentUser = ref.read(authRepositoryProvider).getCurrentUser();

      final User? user = await fetchUserById(GeneralUtils().userUid); //currentUser?.uid

      return user;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> performFriendRequest(bool isFollowingUser, String otherUserUid) async {
    try {
      if(isFollowingUser) {
        await FirebaseFirestore.instance.collection("users")
            .doc(GeneralUtils().userUid)
            .collection("following")
            .doc(otherUserUid).delete();

        await FirebaseFirestore.instance.collection("users")
            .doc(otherUserUid)
            .collection("followers")
            .doc(GeneralUtils().userUid).delete();
        // update mutual
        // final checkOtherUserFollow = await FirebaseFirestore.instance.collection("users")
        //     .doc(otherUserUid)
        //     .collection("followers")
        //     .doc(GeneralUtils().userUid).get();
        // if(checkOtherUserFollow.exists) {
        //   await FirebaseFirestore.instance.collection("users")
        //       .doc(otherUserUid)
        //       .collection("followers")
        //       .doc(GeneralUtils().userUid)
        //       .update({
        //     "is_mutual": false,
        //   });
        // }
        return;
      }

      // update user following
      await FirebaseFirestore.instance.collection("users")
          .doc(GeneralUtils().userUid)
          .collection("following")
          .doc(otherUserUid)
          .set({
        "id": otherUserUid,
        "type": "user",
        "is_mutual": false,
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });

      //update user followers

      // check if it is mutual
      final isMutual = await FirebaseFirestore.instance.collection("users")
          .doc(otherUserUid)
          .collection("following")
          .doc(GeneralUtils().userUid).get();

      await FirebaseFirestore.instance.collection("users")
          .doc(otherUserUid)
          .collection("followers")
          .doc(GeneralUtils().userUid)
          .set({
        "id": GeneralUtils().userUid,
        "type": "user",
        "is_mutual": isMutual.exists,
        "created_date": DateTime.now().toString(),
        "timestamp": FieldValue.serverTimestamp()
      });
    } catch(e) {
      throw CustomException(message: "$e");
    }
  }

  @override
  Future<bool> checkConversationPrivacy(String allowConversation, String otherUserUid) async {
    if(allowConversation == "allow") {
      return true;
    }
    if(allowConversation == "not_allow") {
      return false;
    }
    if(allowConversation == "follows_me") {
      final checkFollower = await FirebaseFirestore.instance.collection("users").doc(otherUserUid).collection("followers").doc(GeneralUtils().userUid).get();
      return checkFollower.exists;
    }
    if(allowConversation == "i_follows") {
      final checkFollowing = await FirebaseFirestore.instance.collection("users").doc(otherUserUid).collection("following").doc(GeneralUtils().userUid).get();
      return checkFollowing.exists;
    }
    return false;
  }

  @override
  Future<User?> updateProfile({
    required Map<String, dynamic> userData
    // required String id,
    // required String firstName,
    // required String lastName,
    // required bio,
  }) async {
    try {
      final userRef =
      ref.read(firebaseFirestoreProvider).collection('users').doc(userData["id"]);

      await userRef
          .update(userData); //{"first_name": firstName, "last_name": lastName, "bio": bio}

      final user = await fetchUserById(userData["id"]);

      return user;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
      (ref) => ProfileRepository(ref),
);
