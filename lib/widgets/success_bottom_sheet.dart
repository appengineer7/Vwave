import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/svg/success.svg"),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Success",
            style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 8,
          ),
          const Text(
            "You have successfully created an item for sale. It would be approved by the admin in the next 24 hours.",
            style: bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 24,
          ),
          ActionButton(
            text: "Okay",
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          )
        ],
      ),
    );
  }
}
