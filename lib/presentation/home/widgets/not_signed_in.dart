
import 'package:flutter/material.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../widgets/empty_screen.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class NotSignedInUser extends StatelessWidget {
  const NotSignedInUser({super.key});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EmptyScreen("No Access to this page",
      textStyle: subHeadingStyle,
      textColor: AppColors.secondaryBase,
      image: "assets/images/no_access.png",
      imageHeight: 150.0,
      bottomPadding: 10.0,
      bottomChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("You need to sign in or create an account to \naccess this page", style: bodyStyle.copyWith(color: AppColors.grey500), textAlign: TextAlign.center,),
            const SizedBox(height: 100,),
            ActionButton(
              text: "Sign in",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
            const SizedBox(height: 20,),
            ActionButton(
              text: "Create an account",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/register');
              },
              backgroundColor: AppColors.primaryBase.withOpacity(0.2),
              foregroundColor: AppColors.primaryBase,
            )
          ],
        ),
      ),
    );
  }
}