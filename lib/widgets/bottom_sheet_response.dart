import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/widgets/action_button.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

class BottomSheetResponse extends StatelessWidget {
  final String imageName, title, subtitle, buttonTitle;
  final Function() onPress;
  const BottomSheetResponse({super.key, required this.imageName, required this.title, required this.subtitle, required this.buttonTitle, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 500,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
          color: Colors.white
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/svg/$imageName.svg"),
            const SizedBox(
              height: 30,
            ),
            Text(
              title,
              style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              subtitle,
              style: bodyStyle.copyWith(color: AppColors.grey700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            ActionButton(
              text: buttonTitle,
              onPressed: onPress,
            )
          ],
        ),
      ),
    );
  }
}
