import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final double? width;
  final bool readOnly;
  final String hintText;
  final Function()? onPress;
  const SearchFieldWidget(this.controller, {super.key, this.readOnly = false, this.onPress, this.width, this.hintText = "Search..."});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.only(),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.grey400)
        ),
        width: width ?? MediaQuery.of(context).size.width,
        height: 55.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: SvgPicture.asset("assets/svg/search.svg"),
            ),
            const SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              height: 50,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: controller,
                maxLines: 1,
                readOnly: readOnly,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  // onSearchingNotification(value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle:
                  titleStyle.copyWith(color: AppColors.grey500),
                  labelStyle: titleStyle.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}