
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';


import '../../../utils/general.dart';
import '../../../utils/validators.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/password_slider.dart';
import '../../../widgets/pin_input_form.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../providers/password_strength_notifier.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum AccountFlow { EMAIL, CONFIRMATION_CODE, RESET_PASSWORD }

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool loading = false;
  String verificationCode = "";
  String enteredConfirmationCode = "";
  AccountFlow accountFlow = AccountFlow.EMAIL;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordController.addListener(() {
      final text = _passwordController.text;

      ref.read(passwordStrengthNotifierProvider.notifier).update(text);
    });
  }

  void generateCode() {
    verificationCode = "";
    for (int i = 1; i <= 6; i++) {
      verificationCode += Random().nextInt(9).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen<AuthState>(authNotifierProvider,
    //         (AuthState? previousState, AuthState newState) {
    //       if (newState is ForgotPasswordLoadedState) {
    //         Navigator.of(context).pushReplacementNamed('/login');
    //       } else if (newState is AuthErrorState) {
    //         print("message is ${newState.message}");
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             elevation: 4,
    //             backgroundColor: Colors.red,
    //             content: Text(
    //               newState.message,
    //               style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
    //             ),
    //           ),
    //         );
    //       }
    //     });
    //
    // final authState = ref.watch(authNotifierProvider);
    // final loading = authState is ForgotPasswordLoadedState;
    final passwordStrength = ref.watch(passwordStrengthNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              if (accountFlow == AccountFlow.EMAIL) {
                Navigator.of(context).pop();
                return;
              }
              if (accountFlow == AccountFlow.CONFIRMATION_CODE) {
                setState(() {
                  accountFlow = AccountFlow.EMAIL;
                });
                return;
              }
              if (accountFlow == AccountFlow.RESET_PASSWORD) {
                setState(() {
                  accountFlow = AccountFlow.CONFIRMATION_CODE;
                });
                return;
              }
            },
          ),
        ),
        title: SvgPicture.asset(
          "assets/images/logo.svg",
          width: 120,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...emailLayout(),
                    ...confirmationCodeLayout(),
                    ...passwordLayout(passwordStrength),
                  ],
                ),
                // accountFlow == AccountFlow.EMAIL
                //     ? SizedBox(
                //   height: MediaQuery.of(context).size.height / 5,
                // )
                //     : accountFlow == AccountFlow.CONFIRMATION_CODE
                //     ? SizedBox(
                //   height: MediaQuery.of(context).size.height / 3,
                // )
                //     : const SizedBox(
                //   height: 70,
                // ),
                Column(
                    children: [
                      ...bottomButton(loading),
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> emailLayout() {
    if (accountFlow != AccountFlow.EMAIL) {
      return [];
    }
    return [
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
          Text(
            "Forgot Password!",
            style: subHeadingStyle.copyWith(color: AppColors.grey900),
          ),
          const SizedBox(height: 4),
          Text(
            "Enter your email address to receive your verification code.",
            style: bodyStyle.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: 24),
          CustomInputField(
            labelText: "Email Address",
            prefix: SvgPicture.asset("assets/svg/message.svg",color: AppColors.grey500, height: 24),
            controller: _emailController,
            validator: emailValidator,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
      //   ],
      // ),
      // Column(
      //   children: [
      //     ActionButton(
      //       loading: loading,
      //       text: "Continue",
      //       onPressed: () {
      //         if (_formKey.currentState!.validate()) {
      //           sendVerificationCode(true);
      //         }
      //       },
      //     ),
      //     const SizedBox(
      //       height: 24,
      //     )
      //   ],
      // )
    ];
  }

  List<Widget> confirmationCodeLayout() {
    if (accountFlow != AccountFlow.CONFIRMATION_CODE) {
      return [];
    }
    return [
      Text(
        "Verification Code",
        style: subHeadingStyle.copyWith(color: AppColors.grey900),
      ),
      const SizedBox(height: 4),
      Text(
        "Enter the 6-digit code sent to this email ${_emailController.text.toLowerCase().trim()}",
        style: bodyStyle.copyWith(color: AppColors.grey700),
      ),
      const SizedBox(height: 24),
      PinInputForm(
        onFinish: (code) {
          enteredConfirmationCode = code;
        },
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> passwordLayout(PasswordStrength passwordStrength) {
    if (accountFlow != AccountFlow.RESET_PASSWORD) {
      return [];
    }
    return [
      Text(
        "Create New Password",
        style: subHeadingStyle.copyWith(color: AppColors.grey900),
      ),
      const SizedBox(height: 4),
      Text(
        "Enter a secure password",
        style: bodyStyle.copyWith(color: AppColors.grey700),
      ),
      const SizedBox(height: 24),
      CustomInputField(
        labelText: "Password",
        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
        controller: _passwordController,
        obscureText: true,
        validator: newpasswordValidator,
      ),
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
      const SizedBox(height: 16),
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
    ];
  }

  List<Widget> bottomButton(bool loading) {
    if (accountFlow == AccountFlow.EMAIL) {
      return [
      ActionButton(
        loading: loading,
        text: "Continue",
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            sendVerificationCode(true);
          }
        },
      ),
        const SizedBox(
          height: 24,
        ),
      ];
    }
    if (accountFlow == AccountFlow.CONFIRMATION_CODE) {
      return [
        ActionButton(
          text: "Continue",
          onPressed: () {
            if (verificationCode == enteredConfirmationCode) {
              enteredConfirmationCode = "";
              setState(() {
                accountFlow = AccountFlow.RESET_PASSWORD;
              });
              return;
            }
            GeneralUtils.showToast("Incorrect verification code");
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ActionButton(
          loading: loading,
          text: "Return to Login",
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBase,
          borderSide: const BorderSide( color: AppColors.primaryBase),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ];
    }
    return [
      SizedBox(height: MediaQuery.of(context).size.height / 3.5,),
      ActionButton(
        loading: loading,
        text: "Reset Password",
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final password = _passwordController.text;
            final confirmPassword = _confirmPasswordController.text;

            if(password != confirmPassword) {
              GeneralUtils.showToast("Passwords do not match");
              return;
            }

            resetUserPassword();

          }
        },
      ),
      const SizedBox(
        height: 30,
      ),
    ];
  }

  Future<void> sendVerificationCode(bool showBottomSheetResponse) async {
    setState(() {
      loading = true;
    });
    generateCode();
    // print("verification code is $verificationCode");
    final res = await GeneralUtils().makeRequest(
        "sendverificationemail",
        {
          "first_name": "",
          "code": verificationCode,
          "email": _emailController.text.trim().toLowerCase()
        },
        addUserCheck: false);
    setState(() {
      loading = false;
    });
    if(res.statusCode != 200) {
      final resp = jsonDecode(res.body);
      GeneralUtils.showToast(resp["message"]);
      return;
    }
    if(showBottomSheetResponse) {
      GeneralUtils().showResponseBottomSheet(
          context, "verify_account", "Verify Account",
          "Please enter the 6-digit code sent to ${_emailController.text}",
          "Proceed", () {
        Navigator.of(context).pop();
        setState(() {
          accountFlow = AccountFlow.CONFIRMATION_CODE;
        });
      });
    } else {
      GeneralUtils.showToast("Verification code sent");
    }

  }


  Future<void> resetUserPassword() async {
    setState(() {
      loading = true;
    });
    final res = await GeneralUtils().makeRequest(
        "resetuserpassword",
        {
          "password": _confirmPasswordController.text,
          "email": _emailController.text.trim().toLowerCase()
        },
        addUserCheck: false);
    setState(() {
      loading = false;
    });
    if(res.statusCode != 200) {
      final resp = jsonDecode(res.body);
      GeneralUtils.showToast(resp["message"]);
      return;
    }
    GeneralUtils().showResponseBottomSheet(
        context, "success_lock", "Success",
        "Password changed successfully",
        "Proceed to Login", () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });

  }

}

