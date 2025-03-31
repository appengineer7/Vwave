import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

class CustomInputField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool? autofocus;
  final int? maxLines;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final bool? enableField;
  final Color fillColor;
  final String hintText;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.enableField = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.validator,
    this.prefix,
    this.fillColor = Colors.white,
    this.hintText = "",
    this.keyboardType = TextInputType.text
  });

  @override
  State<StatefulWidget> createState() => _CustomInputField();
}
class _CustomInputField extends State<CustomInputField> {

  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      passwordVisible = widget.obscureText!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppColors.grey400,
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.prefix ?? const SizedBox(),
          widget.prefix != null ? const SizedBox(width: 10,) : const SizedBox(),
        Expanded(
          // width: MediaQuery.of(context).size.width - 110,
          // height: 60,
          // margin: EdgeInsets.only(bottom: 0),
          child: Container(
            child: TextFormField(
              maxLines: widget.maxLines,
              controller: widget.controller,
              obscureText: passwordVisible,
              validator: widget.validator,
              autofocus: widget.autofocus!,
              keyboardType: widget.keyboardType,
              enabled: widget.enableField,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 16),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  // suffixIcon: (widget.labelText.toLowerCase().contains("password")) ? IconButton(
                  //   icon: Icon(passwordVisible
                  //       ? Icons.visibility
                  //       : Icons.visibility_off),
                  //   onPressed: () {
                  //     setState(
                  //           () {
                  //         passwordVisible = !passwordVisible;
                  //       },
                  //     );
                  //   },
                  // ) : null,
                  suffix: (widget.labelText.toLowerCase().contains("password")) ? GestureDetector(
                    onTap: (){
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    child: passwordVisible ? SvgPicture.asset("assets/svg/eye_off.svg", color: AppColors.grey500,) : SvgPicture.asset("assets/svg/eye_on.svg", color: AppColors.grey500,),
                  ) : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 25,
                    minHeight: 25,
                  ),
                  labelText: widget.labelText,
                  labelStyle: bodyStyle.copyWith(
                    color: AppColors.grey500,
                  ),
                  hintText: widget.hintText,
                  hintStyle: bodyStyle.copyWith(
                    color: AppColors.grey500,
                  ),
                  fillColor: widget.fillColor,
                  floatingLabelBehavior: FloatingLabelBehavior.never
                // floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                //   (Set<MaterialState> states) {
                //     final Color color = states.contains(MaterialState.error)
                //         ? Theme.of(context).colorScheme.error
                //         : AppColors.grey400;
                //     return TextStyle(color: color);
                //   },
                // ),
              ),
            ),
          ),
        )
        ],
      ),
    );
  }
}
