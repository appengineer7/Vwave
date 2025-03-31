import 'package:flutter/material.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

import '../presentation/auth/providers/password_strength_notifier.dart';

class PasswordSlider extends StatelessWidget {
  final PasswordStrength passwordStrength;
  const PasswordSlider(this.passwordStrength, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isPasswordStrong = (passwordStrength.hasUppercaseLetter &&
        passwordStrength.hasLowercaseLetter &&
        passwordStrength.hasNumber &&
        passwordStrength.minimumCharacters);
    int progress = calculateProgress();

    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: (MediaQuery.of(context).size.width - 48) / 5,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                    progress >= 1 ? AppColors.green : AppColors.grey50),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 48) / 5,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                    progress > 1 ? AppColors.green : AppColors.grey50),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 48) / 5,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                    progress > 2 ? AppColors.green : AppColors.grey50),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 48) / 5,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                    progress == 4 ? AppColors.green : AppColors.grey50),
              ),
              isPasswordStrong
                  ? Text(
                      "Strong",
                      style: bodyStyle.copyWith(
                          color: AppColors.green, fontWeight: FontWeight.w700),
                    )
                  : Text(
                      "Weak",
                      style: bodyStyle.copyWith(
                          color: AppColors.errorColor,
                          fontWeight: FontWeight.w700),
                    )
            ]),
        const SizedBox(),
        Row(
          children: [
            passwordStrength.minimumCharacters
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.close,
                    color: AppColors.errorColor,
                  ),
            const SizedBox(
              width: 4,
            ),
            const Text("Minimum 8 Characters", style: captionStyle)
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            passwordStrength.hasNumber
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.close,
                    color: AppColors.errorColor,
                  ),
            const SizedBox(
              width: 4,
            ),
            const Text("At least 1 number (0-9)", style: captionStyle)
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            passwordStrength.hasUppercaseLetter
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.close,
                    color: AppColors.errorColor,
                  ),
            const SizedBox(
              width: 4,
            ),
            const Text("At least 1 uppercase letter", style: captionStyle)
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            passwordStrength.hasLowercaseLetter
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.close,
                    color: AppColors.errorColor,
                  ),
            const SizedBox(
              width: 4,
            ),
            const Text("At least 1 lowercase letter", style: captionStyle,)
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  calculateProgress() {
    int result = 0;
    if(passwordStrength.hasLowercaseLetter) {
      result += 1;
    }
    if(passwordStrength.hasNumber) {
      result += 1;
    }
    if(passwordStrength.hasUppercaseLetter) {
      result += 1;
    }
    if(passwordStrength.minimumCharacters) {
      result += 1;
    }
    return result;
  }
}
