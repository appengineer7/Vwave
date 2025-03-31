import 'package:flutter/material.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onPressed;
  final double? width;
  final TextStyle? textStyle;
  final double? borderRadius;
  final double? height;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide borderSide;

  const ActionButton({
    Key? key,
    this.width = double.infinity,
    this.height = 56,
    required this.text,
    this.loading = false,
    this.textStyle,
    this.borderRadius,
    this.borderSide = BorderSide.none,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.backgroundColor = AppColors.primaryBase,
    this.foregroundColor = Colors.white,
    required this.onPressed,
  }) : super(key: key);
//MaterialStateProperty
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(padding!),
          backgroundColor: onPressed == null
              ? WidgetStateProperty.all<Color>(
                  backgroundColor.withOpacity(0.1))
              : WidgetStateProperty.all<Color>(backgroundColor),
          foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
          elevation: WidgetStateProperty.all<double>(0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
              side: borderSide
            ),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: textStyle ??
                    titleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
      ),
    );
  }
}
