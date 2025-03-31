import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/presentation/club/providers/club_notifier_provider.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';

import '../../../common/providers/firebase.dart';
import '../../../utils/exceptions.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
    required String actionType,
  });

  Future<User?> createUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
    required String location,
    required Map<String, dynamic> locationDetails,
  });
  Future<User?> createUserAccountWithSocialLogin({required Map<String, dynamic> mUserData});
  Future<User?> createClubOwnerWithEmailAndPassword({required Map<String, dynamic> mUserData});
  Future<void> sendResetPasswordEmail({required String email});
  Future<void> updatePassword({required String password});
  Future<void> updateUserData({required Map<String, dynamic> data});
  User? getCurrentUser();
  Future<void> signOut();
  Future<void> getCurrentUserData(String userId);
}

class AuthRepository implements BaseAuthRepository {
  final Ref ref;

  const AuthRepository(this.ref);

  @override
  Stream<User?> get authStateChanges =>
      ref.read(firebaseAuthProvider).authStateChanges();

  @override
  Future<void> getCurrentUserData(String userId) async {
    StorageSystem ss = StorageSystem();
    if(userId == "" || userId == "null") {
      return;
    }
    CollectionReference getUsers = ref.read(firebaseFirestoreProvider).collection('users');
    final result = await getUsers.doc(userId).get();
    if(!result.exists) {
      return;
    }
    print("getting data");
    Map<String, dynamic> user = result.data() as Map<String, dynamic>;
    Map<String, dynamic> userData = {};
    userData['uid'] = userId;
    userData['email'] = user['email'];
    userData['type'] = user['user_type'];
    userData['first_name'] = user['first_name'];
    userData['last_name'] = user['last_name'];
    userData['picture'] = user['picture'];
    userData['allow_conversations'] = user['allow_conversations'] ?? "allow";
    userData['story_privacy'] = user['story_privacy'] ?? "everyone";
    userData['allow_search_visibility'] = user['allow_search_visibility'] ?? true;
    if(user['bio'] != null) {
      userData['bio'] = user['bio'];
    }
    if(user['user_type'] == "club_owner") {
      userData["account_setup"] = "${user["account_setup"]}";
    }
    if(user['location'] != null) {
      userData['location'] = user['location'];
      dynamic ld = user["location_details"];
      userData['location_details'] = {
        "address": ld["address"],
        "latitude": ld["latitude"],
        "longitude": ld["longitude"],
      };
    }
    userData['msgId'] = user['msgId'];
    await ss.setPrefItem('loggedin', 'true');
    await ss.setPrefItem('user', jsonEncode(userData));
  }

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
    required String actionType,
  }) async {
    try {
      StorageSystem ss = StorageSystem();
      final UserCredential userCredential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      if(userCredential.user == null) {
        throw const CustomException(message: "Sorry, user not found.");
      }

      if(actionType == "login") {
        CollectionReference getUsers = ref.read(firebaseFirestoreProvider).collection('users');
        final result = await getUsers.doc(userCredential.user?.uid).get();

        if(!result.exists) {
          await signOut();
          throw const CustomException(message: "User does not exist. Please create an account.");
        }

        Map<String, dynamic> user = result.data() as Map<String, dynamic>;
        bool blocked = user["blocked"];

        if(blocked) {
          await signOut();
          throw const CustomException(message: "Sorry, user has been blocked. Please contact support.");
        }

        Map<String, dynamic> updateUserData = {};
        List<dynamic> msgIds = user["msgId"] ?? [];
        if (deviceToken.isNotEmpty) {
          updateUserData['msgId'] = (msgIds.length >= 2) ? [deviceToken] : FieldValue.arrayUnion([deviceToken]);
          await getUsers
              .doc(userCredential.user?.uid)
              .update(updateUserData);
        }

        Map<String, dynamic> userData = {};
        userData['uid'] = userCredential.user?.uid;
        userData['email'] = user['email'];
        userData['type'] = user['user_type'];
        userData['first_name'] = user['first_name'];
        userData['last_name'] = user['last_name'];
        userData['picture'] = user['picture'];
        userData['allow_conversations'] = user['allow_conversations'] ?? "allow";
        userData['story_privacy'] = user['story_privacy'] ?? "everyone";
        userData['allow_search_visibility'] = user['allow_search_visibility'] ?? true;
        if(user['bio'] != null) {
          userData['bio'] = user['bio'];
        }
        if(user['user_type'] == "club_owner") {
          userData["account_setup"] = "${user["account_setup"]}";
        }
        // if(user['facebook_link'] != null) {
        //   userData['facebook_link'] = user['facebook_link'];
        // }
        // if(user['twitter_link'] != null) {
        //   userData['twitter_link'] = user['twitter_link'];
        // }
        // if(user['instagram_link'] != null) {
        //   userData['instagram_link'] = user['instagram_link'];
        // }
        // if(user['tiktok_link'] != null) {
        //   userData['tiktok_link'] = user['tiktok_link'];
        // }
        // if(user['paypal_email'] != null) {
        //   userData['paypal_email'] = user['paypal_email'];
        // }
        if(user['location'] != null) {
          userData['location'] = user['location'];
          dynamic ld = user["location_details"];
          userData['location_details'] = {
            "address": ld["address"],
            "latitude": ld["latitude"],
            "longitude": ld["longitude"],
          };
        }
        userData['msgId'] = (msgIds.length >= 3) ? [deviceToken] : user['msgId'];
        await ss.setPrefItem('loggedin', 'true');
        await ss.setPrefItem('user', jsonEncode(userData));

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_type", user['user_type']);

        DocumentSnapshot query = await FirebaseFirestore.instance.collection("users").doc(userCredential.user?.uid)
            .collection("setups").doc("user-data").get();
        if (query.exists) {
          Map<String, dynamic> userSetup = query.data() as Map<String, dynamic>;
          userSetup.forEach((key, value) async {
            await ss.setPrefItem(key, "$value");
          });
        }
        if(user['user_type'] == "user") {
          await ref.read(clubNotifierProvider.notifier).getSavedClubs();
        }
      }

      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String deviceToken,
    required String deviceInfo,
    required String location,
    required Map<String, dynamic> locationDetails,
  }) async {
    try {
      final UserCredential userCredential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email.trim(), password: password);

      if(userCredential.user == null) {
        throw const CustomException(message: "Sorry, user not found.");
      }

      CollectionReference users =
          ref.read(firebaseFirestoreProvider).collection('users');

      StorageSystem ss = StorageSystem();

      Map<String, dynamic> newUserData = {};
      newUserData['auth_type'] = "firebase";
      newUserData['bio'] = "";
      newUserData['documents'] = [];
      newUserData['location'] = location;
      newUserData['location_details'] = locationDetails;
      newUserData['email'] = email.trim().toLowerCase();
      newUserData['first_name'] = firstName;
      newUserData['last_name'] = lastName;
      newUserData['allow_conversations'] = "allow";
      newUserData['story_privacy'] = "everyone";
      newUserData['allow_search_visibility'] = true;
      newUserData['picture'] = (userCredential.user?.photoURL == null) ? "" : userCredential.user?.photoURL;
      newUserData['id'] = userCredential.user?.uid;
      newUserData['blocked'] = false;
      newUserData['verified'] = true;
      newUserData['account_setup'] = true;
      newUserData['created_date'] = DateTime.now().toString();
      newUserData['modified_date'] = DateTime.now().toString();
      newUserData['msgId'] = deviceToken.isEmpty ? [] : [deviceToken];
      newUserData['devices'] = [deviceInfo];
      newUserData['device_fingerprint'] = deviceInfo;
      if(userCredential.user != null) {
        newUserData['referral_code'] = userCredential.user!.uid.substring(userCredential.user!.uid.length - 6).toLowerCase();
      }
      newUserData['timestamp'] = FieldValue.serverTimestamp();
      newUserData['user_type'] = "user";
      newUserData['user_role_type'] = "owner";

      await users.doc(userCredential.user?.uid).set(newUserData);

      await FirebaseFirestore.instance.collection("users").doc(userCredential.user?.uid).collection("setups").doc("user-data")
          .set({"vwave":"true"});

      Map<String, dynamic> userData = {};
      userData['uid'] = userCredential.user?.uid;
      userData['type'] = "user";
      userData['email'] = email.trim().toLowerCase();
      userData['first_name'] = firstName;
      userData['last_name'] = lastName;
      userData['allow_conversations'] = "allow";
      userData['story_privacy'] = "everyone";
      userData['allow_search_visibility'] = true;
      userData['msgId'] = [deviceToken];
      userData['picture'] = (userCredential.user?.photoURL == null) ? "" : userCredential.user?.photoURL;
      userData["location"] = location;
      userData["location_details"] = {
        "address": locationDetails["address"],
        "latitude": locationDetails["latitude"],
        "longitude": locationDetails["longitude"],
      };

      await ss.setPrefItem('loggedin', 'true', isStoreOnline: false);
      await ss.setPrefItem('user', jsonEncode(userData), isStoreOnline: false);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_type", "user");

      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<User?> createUserAccountWithSocialLogin({
    required Map<String, dynamic> mUserData
  }) async {
    try {

      String email = mUserData["email"];
      String firstName = mUserData["firstName"];
      String lastName = mUserData["lastName"];
      String deviceToken = mUserData["deviceToken"];
      String deviceInfo = mUserData["deviceInfo"];
      String location = mUserData["location"];
      Map<String, dynamic> locationDetails = mUserData["location_details"];
      User mUser = mUserData["user"] as User;

      CollectionReference users =
      ref.read(firebaseFirestoreProvider).collection('users');

      StorageSystem ss = StorageSystem();

      Map<String, dynamic> newUserData = {};
      newUserData['auth_type'] = mUserData["method"];
      newUserData['bio'] = "";
      newUserData['documents'] = [];
      newUserData['location'] = location;
      newUserData['location_details'] = locationDetails;
      newUserData['email'] = email.trim().toLowerCase();
      newUserData['first_name'] = firstName;
      newUserData['last_name'] = lastName;
      newUserData['allow_conversations'] = "allow";
      newUserData['story_privacy'] = "everyone";
      newUserData['allow_search_visibility'] = true;
      newUserData['picture'] = (mUser.photoURL == null) ? "" : mUser.photoURL;
      newUserData['id'] = mUser.uid;
      newUserData['blocked'] = false;
      newUserData['verified'] = true;
      newUserData['account_setup'] = true;
      newUserData['created_date'] = DateTime.now().toString();
      newUserData['modified_date'] = DateTime.now().toString();
      newUserData['msgId'] = deviceToken.isEmpty ? [] : [deviceToken];
      newUserData['devices'] = [deviceInfo];
      newUserData['device_fingerprint'] = deviceInfo;
      newUserData['referral_code'] = mUser.uid.substring(mUser.uid.length - 6).toLowerCase();
      newUserData['timestamp'] = FieldValue.serverTimestamp();
      newUserData['user_type'] = "user";
      newUserData['user_role_type'] = "owner";

      await users.doc(mUser.uid).set(newUserData);

      await FirebaseFirestore.instance.collection("users").doc(mUser.uid).collection("setups").doc("user-data")
          .set({"vwave":"true"});

      Map<String, dynamic> userData = {};
      userData['uid'] = mUser.uid;
      userData['type'] = "user";
      userData['email'] = email.trim().toLowerCase();
      userData['first_name'] = firstName;
      userData['last_name'] = lastName;
      userData['allow_conversations'] = "allow";
      userData['story_privacy'] = "everyone";
      userData['allow_search_visibility'] = true;
      userData['msgId'] = [deviceToken];
      userData['picture'] = (mUser.photoURL == null) ? "" : mUser.photoURL;
      userData["location"] = location;
      userData["location_details"] = {
        "address": locationDetails["address"],
        "latitude": locationDetails["latitude"],
        "longitude": locationDetails["longitude"],
      };

      await ss.setPrefItem('loggedin', 'true', isStoreOnline: false);
      await ss.setPrefItem('user', jsonEncode(userData), isStoreOnline: false);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_type", "user");

      return mUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<User?> createClubOwnerWithEmailAndPassword({
    required Map<String, dynamic> mUserData
  }) async {
    try {
      String email = mUserData["email"];
      String password = mUserData["password"];
      String firstName = mUserData["firstName"];
      String lastName = mUserData["lastName"];
      String deviceToken = mUserData["deviceToken"];
      String deviceInfo = mUserData["deviceInfo"];

      final UserCredential userCredential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email.trim(), password: password);

      if(userCredential.user == null) {
        return null;
      }

      CollectionReference users =
          ref.read(firebaseFirestoreProvider).collection('users');

      StorageSystem ss = StorageSystem();

      Map<String, dynamic> newUserData = {};
      newUserData['auth_type'] = "firebase";
      newUserData['bio'] = "";
      newUserData['documents'] = mUserData["documents"];
      newUserData['location'] = mUserData["location"];
      newUserData['location_details'] = mUserData["location_details"];
      newUserData['email'] = email.trim().toLowerCase();
      newUserData['first_name'] = firstName;
      newUserData['last_name'] = lastName;
      newUserData['allow_conversations'] = "allow";
      newUserData['story_privacy'] = "everyone";
      newUserData['allow_search_visibility'] = true;
      newUserData['picture'] = (userCredential.user?.photoURL == null) ? "" : userCredential.user?.photoURL;
      newUserData['id'] = userCredential.user?.uid;
      newUserData['blocked'] = false;
      newUserData['verified'] = false;
      newUserData['account_setup'] = false;
      newUserData['created_date'] = DateTime.now().toString();
      newUserData['modified_date'] = DateTime.now().toString();
      newUserData['msgId'] = deviceToken.isEmpty ? [] : [deviceToken];
      newUserData['devices'] = [deviceInfo];
      newUserData['device_fingerprint'] = deviceInfo;
      if(userCredential.user != null) {
        newUserData['referral_code'] = userCredential.user!.uid.substring(userCredential.user!.uid.length - 6).toLowerCase();
      }
      newUserData['timestamp'] = FieldValue.serverTimestamp();
      newUserData['user_type'] = "club_owner";
      newUserData['user_role_type'] = "owner";

      await users.doc(userCredential.user?.uid).set(newUserData);

      await FirebaseFirestore.instance.collection("users").doc(userCredential.user?.uid).collection("setups").doc("user-data")
          .set({"vwave":"true"});

      Map<String, dynamic> loc = mUserData["location_details"];

      Map<String, dynamic> userData = {};
      userData['uid'] = userCredential.user?.uid;
      userData['type'] = "club_owner";
      userData['account_setup'] = "false";
      userData['email'] = email.trim().toLowerCase();
      userData['first_name'] = firstName;
      userData['last_name'] = lastName;
      userData['allow_conversations'] = "allow";
      userData['story_privacy'] = "everyone";
      userData['allow_search_visibility'] = true;
      userData['msgId'] = [deviceToken];
      userData['picture'] = (userCredential.user?.photoURL == null) ? "" : userCredential.user?.photoURL;
      userData["location"] = mUserData["location"];
      userData["location_details"] = {
        "address": loc["address"],
        "latitude": loc["latitude"],
        "longitude": loc["longitude"],
      };

      await ss.setPrefItem('loggedin', 'true', isStoreOnline: false);
      await ss.setPrefItem('user', jsonEncode(userData), isStoreOnline: false);


      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_type", "club_owner");

      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  User? getCurrentUser() {
    try {
      return ref.read(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await ref.read(firebaseFirestoreProvider).collection("users").doc(GeneralUtils().userUid).delete();
      await ref.read(firebaseAuthProvider).signOut();
      StorageSystem ss = StorageSystem();
      ss.clearPref();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      StorageSystem ss = StorageSystem();
      ss.clearPref();
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await _googleSignIn.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // await FacebookAuth.instance.logOut();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> sendResetPasswordEmail({required String email}) async {
    try {
      return ref
          .read(firebaseAuthProvider)
          .sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      final User? user = ref.read(firebaseAuthProvider).currentUser;

      if (user == null) {
        throw const CustomException(message: "You are not logged in");
      }

      await user.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateUserData({required Map<String, dynamic> data}) async {
    try {
      if (GeneralUtils().userUid == null) {
        throw const CustomException(message: "You are not logged in");
      }

      await ref.read(firebaseFirestoreProvider).collection("users").doc(GeneralUtils().userUid).update(data);
      StorageSystem ss = StorageSystem();
      String? user = await ss.getItem("user");
      if(user == null) {
        throw const CustomException(message: "You are not logged in");
      }
      dynamic json = jsonDecode(user);
      Map<String, dynamic> userData = {
        ...json,
        ...data
      };
      await ss.setPrefItem('user', jsonEncode(userData), isStoreOnline: false);
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref),
);
