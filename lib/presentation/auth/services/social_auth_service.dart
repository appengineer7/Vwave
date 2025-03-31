import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../utils/general.dart';

class SocialAuthService {
  final Function(User? user, String response, String request, dynamic extraData, bool isExistingUser) onComplete;
  BuildContext context;

  SocialAuthService(this.context, {required this.onComplete});

  Future<void> googleRequest() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser == null) {
        onComplete(null, "error", "google", null, false);
        displaySnackBarErrorMessage("Cannot login to user", Colors.red);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      displaySnackBarErrorMessage("Authorizing user. Please wait...", Colors.green);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      final userExist = await checkIfEmailExists(googleUser.email.toLowerCase());

      Map<String, dynamic> extData = {};
      extData["email"] = googleUser.email.toLowerCase();
      extData["firstname"] = googleUser.displayName?.split(" ")[0];
      extData["lastname"] = googleUser.displayName!.split(" ").length > 1 ? googleUser.displayName?.split(" ")[1] : "";
      extData["picture"] = googleUser.photoUrl ?? "";

      onComplete(user, "success", "google", extData, userExist); //googleAuth
    } catch (e) { //on FirebaseAuthException
      print(e);
      // await FirebaseAuth.instance.currentUser?.delete();
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      onComplete(null, "error", "google", null, false);
      displaySnackBarErrorMessage("Could not sign in with Google. Please try again.", Colors.red);
    }
  }

  Future<void> appleRequest(bool isAvailable) async {
    if (!isAvailable) {
      displaySnackBarErrorMessage("Your device can not use this feature.", Colors.red);
      return;
    }

    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      displaySnackBarErrorMessage("Authorizing user. Please wait...", Colors.green);

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: result.identityToken,
        accessToken: result.authorizationCode,
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final authResult = await _auth.signInWithCredential(credential);
      final user = authResult.user;

      if (user == null) {
        // await FirebaseAuth.instance.currentUser?.delete();
        await FirebaseAuth.instance.signOut();
        onComplete(null, "error", "apple", null, false);
        displaySnackBarErrorMessage("Your email address is required.", Colors.red);
        return;
      }

      if (user.email == null) {
        // await FirebaseAuth.instance.currentUser?.delete();
        await FirebaseAuth.instance.signOut();
        onComplete(null, "error", "apple", null, false);
        displaySnackBarErrorMessage("Your email address is required.", Colors.red);
        return;
      }

      // print(user);
      // print("user userIdentifier is ${result.userIdentifier}");
      // print("user userIdentifier is ${result.familyName}");

      // final credState = await SignInWithApple.getCredentialState(result.userIdentifier!);

      // print("apple name is ====== ${credState.name}");

      // print("user email is ${user.email}");
      // print("user email is ${user.displayName}");
      // print("user email is ${result.givenName}");
      // print("user email is ${result.familyName}");

      final userExist = await checkIfEmailExists(user.email!.toLowerCase());

      Map<String, dynamic> extData = {};
      extData["email"] = user.email!.toLowerCase();
      extData["firstname"] = result.givenName ?? ""; //user.displayName?.split(" ")[0];
      extData["lastname"] = result.familyName ?? ""; //user.displayName!.split(" ").length > 1 ? user.displayName?.split(" ")[1] : "";
      extData["picture"] = user.photoURL ?? "";

      onComplete(user, "success", "apple", extData, userExist);
    } catch(e) {
      // await FirebaseAuth.instance.currentUser?.delete();
      await FirebaseAuth.instance.signOut();
      onComplete(null, "error", "apple", null, false);
      displaySnackBarErrorMessage("Could not sign in with Apple. Please try again.", Colors.red);
    }
  }


  // Future<void> facebookRequest() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final AccessToken accessToken = result.accessToken!;
  //       final AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
  //       final FirebaseAuth _auth = FirebaseAuth.instance;
  //       final mResult = await _auth.signInWithCredential(credential);
  //       final User? user = mResult.user;
  //
  //       print("user email is ${user?.email}");
  //
  //       final userData = await FacebookAuth.instance.getUserData();
  //
  //       Map<String, dynamic> extData = {};
  //       extData["id"] = userData["id"];
  //       extData["email"] = userData["email"];
  //       extData["firstname"] = "${userData["name"]}".split(" ")[0];
  //       extData["lastname"] = "${userData["name"]}".split(" ").length > 1 ? "${userData["name"]}".split(" ")[1] : "";
  //       extData["picture"] = "";
  //       if(userData["picture"] != null) {
  //         final userPicture = userData["picture"];
  //         final imgData = userPicture["data"];
  //         if(imgData != null) {
  //           extData["picture"] = imgData["url"] ?? "";
  //         }
  //       }
  //
  //       final userExist = await checkIfEmailExists(userData["email"]);
  //       onComplete(user, "success", "facebook", extData, userExist["email"]);
  //     } else {
  //       onComplete(null, "error", "facebook", null, false);
  //       displaySnackBarErrorMessage(result.message);
  //     }
  //   } catch(e) {
  //     onComplete(null, "error", "facebook", null, false);
  //   }
  // }

  Future<bool> checkIfEmailExists(String email) async {
    try {
      final res = await GeneralUtils().makeRequest(
          "confirmemail?email=${email.toLowerCase()}", {},
          method: "get", addUserCheck: false);
      Map<String, dynamic> _body = jsonDecode(res.body);
      return _body["email_exist"]; // {"email": _body["email_exist"]};
    } catch (e) {
      return false; //{"email": false};
    }
  }

  void displaySnackBarErrorMessage(String? message, Color? color) {
    message ??= "Action could not be completed. Please try again.";
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white),),
      duration: const Duration(seconds: 5),
      backgroundColor: color,
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {

        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
