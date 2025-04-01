import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

class InputField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool? autofocus;
  final int? maxLines;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final Color fillColor;
  final String hintText;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.validator,
    this.prefix,
    this.fillColor = Colors.white,
    this.hintText = "",
    this.keyboardType = TextInputType.text
  });

  @override
  State<StatefulWidget> createState() => _InputField();
}
class _InputField extends State<InputField> {

  bool passwordVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      passwordVisible = widget.obscureText!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      obscureText: passwordVisible,
      validator: widget.validator,
      autofocus: widget.autofocus!,
      keyboardType: widget.keyboardType,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: AppColors.grey400,
            )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppColors.grey400,
          ),
        ),
        prefix: widget.prefix,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 25,
            minHeight: 25,
          ),
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
        suffix: (widget.labelText.toLowerCase().contains("password")) ? InkWell(
          onTap: (){
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
          child: passwordVisible ? SvgPicture.asset("assets/svg/eye_off.svg") : SvgPicture.asset("assets/svg/eye_on.svg", color: AppColors.grey500,),
        ) : null,
        labelText: widget.labelText,
        labelStyle: bodyStyle.copyWith(
          color: AppColors.grey500,
        ),
        filled: true,
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
    );
  }
}
