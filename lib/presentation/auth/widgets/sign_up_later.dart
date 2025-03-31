import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
// import '../../home/pages/home_page.dart';

class SignupLaterBottomSheet extends StatelessWidget {
  const SignupLaterBottomSheet({super.key});

  void setSeenIntro(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool(PrefKeys.intro, value);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 500,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(10), right: Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 0.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Image.asset(
                  "assets/images/styled_logo.png",
                  height: 90,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Sign up Later?",
                  style: subHeadingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                comment(context, "Must be signed in to submit any transaction"),
                comment(context, "Must be signed in to comment or visit profiles"),
                comment(context, "Must be signed in to access more of the app"),
                const SizedBox(
                  height: 30.0,
                ),
                ActionButton(text: "Proceed", onPressed: () {
                  setSeenIntro(true);
                  Navigator.of(context).pop();
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     builder: (BuildContext context) => const HomePage()));
                })
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget comment(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: AppColors.primaryBase,
              borderRadius: BorderRadius.circular(12)
          ),
        ),
        const SizedBox(width: 10.0,),
        Text(text, style: captionStyle.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.fade,)
      ],
    ),);
  }
}
