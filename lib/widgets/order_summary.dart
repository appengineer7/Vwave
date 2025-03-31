
import 'package:flutter/material.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

class OrderSummary extends StatelessWidget {

  final String label, text;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final FontWeight? fontWeight;
  final Color? textColor;
  const OrderSummary(this.label, this.text, this.prefixWidget, this.fontWeight, this.textColor, {super.key, this.suffixWidget});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: bodyStyle.copyWith(
                  color: textColor ?? AppColors.grey500,),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                (prefixWidget == null) ? const SizedBox() : prefixWidget!,
                Text(
                  text,
                  style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryBase),
                ),
                (suffixWidget == null) ? const SizedBox() : suffixWidget!,
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Divider(
          color: AppColors.grey200,
        )
      ],
    );
  }
}