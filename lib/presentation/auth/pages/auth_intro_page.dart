import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../utils/exceptions.dart';
import '../../../utils/storage.dart';
import '../../../widgets/nav_back_button.dart';
import '../services/social_auth_service.dart';
import '../widgets/sign_up_later.dart';

class AuthIntroPage extends StatefulWidget {
  const AuthIntroPage({super.key});

  @override
  State<AuthIntroPage> createState() => _AuthIntroPageState();
}

class _AuthIntroPageState extends State<AuthIntroPage> {

  String selectedOption = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: NavBackButton(
              color: AppColors.titleTextColor,
              onPress: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: SvgPicture.asset(
            "assets/images/logo.svg",
            width: 120,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Select sign up option", textAlign: TextAlign.start,
                          style: subHeadingStyle.copyWith(color: AppColors.grey900),
                        ),
                        signupOptions(selectedOption == "user", "As a user", "user"),
                        signupOptions(selectedOption == "club", "As a club owner", "club"),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(children: [
                      ActionButton(
                      onPressed: (){
                        if(selectedOption.isEmpty) {
                          return;
                        }
                        if(selectedOption == "user") {
                          Navigator.of(context).pushNamed("/register");
                        } else {
                          Navigator.of(context).pushNamed("/register_club");
                          // Map<String, dynamic> ud = {"h": "he"};
                          // Navigator.of(context).pushNamed("/set_club_owner_location", arguments: ud);
                        }
                      },
                      text: "Continue",
                    ),
                      const SizedBox(height: 20,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: bodyStyle.copyWith(
                                color: AppColors.grey900,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign in',
                              style: bodyStyle.copyWith(
                                color: AppColors.primaryBase,
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushNamed('/login');
                                },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20,),
      ],)
                  )
                ],
              ),
            ],
          ),
        )
    );
  }

  Widget signupOptions(bool selected, String title, String tag) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = tag;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.all(15),
        height: 80,
        decoration: BoxDecoration(
            color: selected ? AppColors.primaryBase.withOpacity(0.2) : AppColors.grey200,
            borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.primaryBase) : null
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(48)
              ),
              child: SvgPicture.asset("assets/svg/profile.svg", fit: BoxFit.scaleDown, color: selected ? AppColors.primaryBase : AppColors.grey500,),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Text(title, style: titleStyle.copyWith(fontWeight: FontWeight.w700, color: selected ? AppColors.primaryBase : AppColors.grey900),)
          ],
        ),
      ),
    );
  }
}
