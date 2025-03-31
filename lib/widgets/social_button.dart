
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

import '../presentation/auth/services/social_auth_service.dart';
import '../presentation/club/providers/club_notifier_provider.dart';
import '../utils/exceptions.dart';
import '../utils/general.dart';
import '../utils/storage.dart';

class SocialButton extends ConsumerStatefulWidget {
  final String iconName, social;
  final bool termsCheck;
  const SocialButton(this.iconName, this.social, this.termsCheck, {super.key,});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SocialButton();
}

class _SocialButton extends ConsumerState<SocialButton> {

  bool inAsyncCall = false;

  StorageSystem ss = StorageSystem();

  String deviceToken = "", mDeviceInfo = "";

  @override
  void initState() {
    super.initState();
    getTokenAndDeviceInfo();
  }

  getTokenAndDeviceInfo() async {
    FirebaseMessaging.instance.getToken().then((token) {
      deviceToken = token!;
    });

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        mDeviceInfo =
        "${androidInfo.fingerprint}_${androidInfo.model}_${androidInfo.board}_${androidInfo.version.securityPatch}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        mDeviceInfo = iosInfo.identifierForVendor!;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if(!widget.termsCheck) {
          GeneralUtils().displayAlertDialog(context, "Attention", "Please accept the terms and conditions.");
          return;
        }
        setState(() {
          inAsyncCall = true;
        });
        final socialAuth = SocialAuthService(context, onComplete: onSocialAuthComplete);
        if(widget.social == "facebook") {
          // await socialAuth.facebookRequest();
          return;
        }
        if(widget.social == "apple") {
          final isAvailable = await SignInWithApple.isAvailable();
          await socialAuth.appleRequest(isAvailable);
          return;
        }
        if(widget.social == "google") {
          await socialAuth.googleRequest();
          return;
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 96) / 3,
        height: 56,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey400)
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/${widget.iconName}.svg",
                width: 25,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSocialAuthComplete(User? user, String response, String request, dynamic extraData, bool isExistingUser) async {
    if(user == null || response == "error") {
      setState(() {
        inAsyncCall = false;
      });
      return;
    }

    try {
      String email = extraData["email"];
      String firstName = extraData["firstname"];
      String lastName = extraData["lastname"];
      String picture = extraData["picture"];

      if(isExistingUser) { // login user
        GeneralUtils.showToast("Signing user in, please wait...");
        CollectionReference getUsers = FirebaseFirestore.instance.collection('users');
        final result = await getUsers.doc(user.uid).get();

        if(!result.exists) {
          await signOut();
          throw const CustomException(message: "User does not exist. Please create an account.");
        }

        Map<String, dynamic> mUser = result.data() as Map<String, dynamic>;
        bool blocked = mUser["blocked"];

        if(blocked) {
          await signOut();
          throw const CustomException(message: "Sorry, user has been blocked. Please contact support.");
        }

        Map<String, dynamic> updateUserData = {};
        List<dynamic> msgIds = mUser["msgId"] ?? [];
        if (deviceToken.isNotEmpty) {
          updateUserData['msgId'] = (msgIds.length >= 3) ? [deviceToken] : FieldValue.arrayUnion([deviceToken]);
          await getUsers
              .doc(user.uid)
              .update(updateUserData);
        }

        Map<String, dynamic> userData = {};
        userData['uid'] = user.uid;
        userData['type'] = "user";
        userData['email'] = mUser['email'];
        userData['first_name'] = mUser['first_name'];
        userData['last_name'] = mUser['last_name'];
        userData['picture'] = mUser['picture'];
        userData['allow_conversations'] = mUser['allow_conversations'] ?? "allow";
        userData['story_privacy'] = mUser['story_privacy'] ?? "everyone";
        userData['allow_search_visibility'] = mUser['allow_search_visibility'] ?? true;
        if(mUser['bio'] != null) {
          userData['bio'] = mUser['bio'];
        }
        if(mUser['user_type'] == "club_owner") {
          userData["account_setup"] = "${mUser["account_setup"]}";
        }
        // if(mUser['facebook_link'] != null) {
        //   userData['facebook_link'] = mUser['facebook_link'];
        // }
        // if(mUser['twitter_link'] != null) {
        //   userData['twitter_link'] = mUser['twitter_link'];
        // }
        // if(mUser['instagram_link'] != null) {
        //   userData['instagram_link'] = mUser['instagram_link'];
        // }
        // if(mUser['tiktok_link'] != null) {
        //   userData['tiktok_link'] = mUser['tiktok_link'];
        // }
        // if(mUser['paypal_email'] != null) {
        //   userData['paypal_email'] = mUser['paypal_email'];
        // }
        if(mUser['location'] != null) {
          userData['location'] = mUser['location'];
          dynamic ld = mUser["location_details"];
          userData['location_details'] = {
            "address": ld["address"],
            "latitude": ld["latitude"],
            "longitude": ld["longitude"],
          };
        }
        userData['msgId'] = (msgIds.length >= 2) ? [deviceToken] : mUser['msgId'];
        await ss.setPrefItem('loggedin', 'true');
        await ss.setPrefItem('user', jsonEncode(userData));


        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_type", mUser['user_type']);

        DocumentSnapshot query = await FirebaseFirestore.instance.collection("users").doc(user.uid)
            .collection("setups").doc("user-data").get();
        if (query.exists) {
          Map<String, dynamic> userSetup = query.data() as Map<String, dynamic>;
          userSetup.forEach((key, value) async {
            await ss.setPrefItem(key, "$value");
          });
        }

        await ref.read(clubNotifierProvider.notifier).getSavedClubs();

        setState(() {
          inAsyncCall = false;
        });

        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }

      /// create an account
      /// set user location first

      Map<String, dynamic> userData = {
        "uid": user.uid,
        "user": user,
        "firstName": firstName,
        "lastName": lastName,
        "email": email.trim().toLowerCase(),
        "deviceToken": deviceToken,
        "deviceInfo": mDeviceInfo,
        "documents": [],
        "user_type": "user",
        "method": request,
        "picture": picture
      };

      setState(() {
        inAsyncCall = false;
      });
      Navigator.of(context).pushNamed("/set_location", arguments: userData);


      // Map<String, dynamic> newUserData = {};
      // newUserData['auth_type'] = request;
      // newUserData['bio'] = "";
      // newUserData['documents'] = [];
      // newUserData['location'] = "";
      // newUserData['location_details'] = {};
      // newUserData['email'] = email.trim().toLowerCase();
      // newUserData['first_name'] = firstName;
      // newUserData['last_name'] = lastName;
      // newUserData['picture'] = picture;
      // newUserData['id'] = user.uid;
      // newUserData['blocked'] = false;
      // newUserData['verified'] = true;
      // newUserData['created_date'] = DateTime.now().toString();
      // newUserData['modified_date'] = DateTime.now().toString();
      // newUserData['msgId'] = deviceToken.isEmpty ? [] : [deviceToken];
      // newUserData['devices'] = [mDeviceInfo];
      // newUserData['device_fingerprint'] = mDeviceInfo;
      // newUserData['referral_code'] = user.uid.substring(user.uid.length - 6).toLowerCase();
      // newUserData['timestamp'] = FieldValue.serverTimestamp();
      // newUserData['user_type'] = "user";
      // newUserData['user_role_type'] = "owner";
      //
      // await FirebaseFirestore.instance.collection("users").doc(user.uid).set(newUserData);
      //
      // await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("setups").doc("user-data")
      //     .set({"vwave":"true"});
      //
      // Map<String, dynamic> userData = {};
      // userData['uid'] = user.uid;
      // userData['type'] = "user";
      // userData['email'] = email.trim().toLowerCase();
      // userData['first_name'] = firstName;
      // userData['last_name'] = lastName;
      // userData['msgId'] = [deviceToken];
      // userData['picture'] = picture;
      //
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString("user_type", "user");
      //
      // await ss.setPrefItem('loggedin', 'true', isStoreOnline: false);
      // await ss.setPrefItem('user', jsonEncode(userData), isStoreOnline: false);
      //
      // setState(() {
      //   inAsyncCall = false;
      // });
      //
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch(e) {
      setState(() {
        inAsyncCall = false;
      });
      displaySnackBarErrorMessage("$e");
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await _googleSignIn.signOut();
      // await FacebookAuth.instance.logOut();
    } catch(e){}
  }

  void displaySnackBarErrorMessage(String? message) {
    message ??= "Action could not be completed. Please try again.";
    final snackBar = SnackBar(
      backgroundColor: AppColors.errorColor,
      content: Text(message),
      duration: const Duration(seconds: 10),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Close',
        onPressed: () {

        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}