import 'package:flutter/material.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

class Line extends StatelessWidget {
  const Line({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
            child: Divider(
              thickness: 1,
              color: AppColors.grey600,
            )),
        const SizedBox(
          width: 5,
        ),
        Text(
          "OR",
          style: bodyStyle.copyWith(color: AppColors.grey600, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          width: 5,
        ),
        const Expanded(
            child: Divider(
              thickness: 1,
              color: AppColors.grey600,
            )),
      ],
    );
  }
}