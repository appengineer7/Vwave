import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utils/general.dart';
import '../../../utils/validators.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/password_slider.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/providers/auth_state.dart';
import '../../auth/providers/auth_state_notifier.dart';
import '../../auth/providers/password_strength_notifier.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      ref.read(passwordStrengthNotifierProvider.notifier).update("");
    });
    _passwordController.addListener(() {
      final text = _passwordController.text;
      ref.read(passwordStrengthNotifierProvider.notifier).update(text);
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
            (AuthState? previousState, AuthState newState) {
          if (newState is AuthLoadedState) {
            // GeneralUtils().showResponseBottomSheet(
            //     context, "success_lock", "Success",
            //     "Password changed successfully",
            //     "Proceed", () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).pop();
            // });
            // Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 4,
                backgroundColor: Colors.green,
                content: Text(
                  "Your password was changed successfully",
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          } else if (newState is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 4,
                backgroundColor: Colors.red,
                content: Text(
                  newState.message,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }
        });

    final authState = ref.watch(authNotifierProvider);
    final loading = authState is AuthLoadingState;

    final passwordStrength = ref.watch(passwordStrengthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Account Settings", style: titleStyle.copyWith(fontWeight: FontWeight.w700),),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        labelText: "Current Password",
                        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
                        controller: _oldPasswordController,
                        obscureText: true,
                        validator: textValidator,
                      ),
                      // InputField(
                      //   labelText: "Current Password",
                      //   controller: _oldPasswordController,
                      //   validator: textValidator,
                      //   obscureText: true,
                      // ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        labelText: "New Password",
                        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
                        controller: _passwordController,
                        obscureText: true,
                        validator: newpasswordValidator,
                      ),
                      // InputField(
                      //   labelText: "New Password",
                      //   controller: _passwordController,
                      //   validator: newpasswordValidator,
                      //   obscureText: true,
                      // ),
                      const SizedBox(height: 24),
                      Text("Min 8 characters with a combination of uppercase, lowercase letters and numbers", style: captionStyle.copyWith(color: AppColors.grey500),),
                      const SizedBox(height: 16),
                      PasswordSlider(passwordStrength),
                      const SizedBox(height: 16),
                      CustomInputField(
                        labelText: "Confirm Password",
                        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: newpasswordValidator,
                      ),
                      // InputField(
                      //   labelText: "Confirm Password",
                      //   controller: _confirmPasswordController,
                      //   validator: newpasswordValidator,
                      //   obscureText: true,
                      // ),
                      const SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     passwordStrength.minimumCharacters
                      //         ? const Icon(
                      //       Icons.check,
                      //       color: Colors.green,
                      //     )
                      //         : const Icon(
                      //       Icons.close,
                      //       color: AppColors.errorColor,
                      //     ),
                      //     const SizedBox(
                      //       width: 4,
                      //     ),
                      //     const Text("Minimum 8 Characters")
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     passwordStrength.hasNumber
                      //         ? const Icon(
                      //       Icons.check,
                      //       color: Colors.green,
                      //     )
                      //         : const Icon(
                      //       Icons.close,
                      //       color: AppColors.errorColor,
                      //     ),
                      //     const SizedBox(
                      //       width: 4,
                      //     ),
                      //     const Text("At least 1 number (0-9)")
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     passwordStrength.hasUppercaseLetter
                      //         ? const Icon(
                      //       Icons.check,
                      //       color: Colors.green,
                      //     )
                      //         : const Icon(
                      //       Icons.close,
                      //       color: AppColors.errorColor,
                      //     ),
                      //     const SizedBox(
                      //       width: 4,
                      //     ),
                      //     const Text("At least 1 uppercase letter")
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     passwordStrength.hasLowercaseLetter
                      //         ? const Icon(
                      //       Icons.check,
                      //       color: Colors.green,
                      //     )
                      //         : const Icon(
                      //       Icons.close,
                      //       color: AppColors.errorColor,
                      //     ),
                      //     const SizedBox(
                      //       width: 4,
                      //     ),
                      //     const Text("At least 1 lowercase letter")
                      //   ],
                      // ),
                    ],
                  ),
                  // const SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.5),
                    child: ActionButton(
                      loading: loading,
                      text: "Save Changes",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if(_confirmPasswordController.text != _passwordController.text) {
                            GeneralUtils.showToast("Passwords do not match");
                            return;
                          }
                          ref.read(authNotifierProvider.notifier).updatePassword(
                            oldPassword: _oldPasswordController.text,
                            newPassword: _passwordController.text,
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
