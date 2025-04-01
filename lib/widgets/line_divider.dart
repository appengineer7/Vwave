
import 'package:flutter/material.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';


class LineDivider extends StatelessWidget {
  final String text;
  const LineDivider({super.key, this.text = "OR LOGIN AS A USER WITH"});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
            child: Divider(
              thickness: 1,
              color: AppColors.grey400,
            )),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: captionStyle.copyWith(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
        ),
        const SizedBox(
          width: 5,
        ),
        const Expanded(
            child: Divider(
              thickness: 1,
              color: AppColors.grey400,
            )),
      ],
    );
  }
}