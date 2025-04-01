import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

class BottomSheetMultipleResponses extends StatelessWidget {
  final String imageName, title, subtitle, buttonTitle, cancelTitle;
  final TextStyle? titleStyle;
  final Function() onPress;
  final Function()? onCancelPress;
  const BottomSheetMultipleResponses({super.key, required this.imageName, required this.title, required this.subtitle, required this.buttonTitle, required this.cancelTitle, required this.onPress, this.titleStyle, this.onCancelPress});

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
            imageName.isEmpty ? const SizedBox() : SvgPicture.asset("assets/svg/$imageName.svg"),
            const SizedBox(
              height: 30,
            ),
            Text(
              title,
              style: titleStyle ?? subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(color: AppColors.grey200,),
            const SizedBox(
              height: 20,
            ),
            Text(
              subtitle,
              style: bodyStyle.copyWith(color: AppColors.grey700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 90,
            ),
            ActionButton(
              text: buttonTitle,
              onPressed: onPress,
            ),
            const SizedBox(
              height: 20,
            ),
            ActionButton(
              text: cancelTitle,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBase,
              borderSide: const BorderSide(color: AppColors.primaryBase),
              onPressed: onCancelPress ?? () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
