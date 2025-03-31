import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';


import '../../../utils/general.dart';
import '../../../utils/validators.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/line_divider.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/password_slider.dart';
import '../../../widgets/pin_input_form.dart';
import '../../../widgets/social_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../providers/auth_state.dart';
import '../providers/auth_state_notifier.dart';
import '../providers/password_strength_notifier.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

enum AccountFlow { NAME_AND_EMAIL, CONFIRMATION_CODE }

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String msgId = "", _deviceInfo = "";
  String verificationCode = "";
  String enteredConfirmationCode = "";

  bool termsCheck = false;

  AccountFlow accountFlow = AccountFlow.NAME_AND_EMAIL;

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

    getTokenAndDeviceInfo();
  }

  void generateCode() {
    verificationCode = "";
    for (int i = 1; i <= 6; i++) {
      verificationCode += Random().nextInt(9).toString();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  getTokenAndDeviceInfo() async {
    FirebaseMessaging.instance.getToken().then((token) {
      msgId = token!;
    });

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceInfo =
            "${androidInfo.fingerprint}_${androidInfo.model}_${androidInfo.board}_${androidInfo.version.securityPatch}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = iosInfo.identifierForVendor!;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
        (AuthState? previousState, AuthState newState) {
      if (newState is AuthLoadedState) {
        Navigator.of(context).pushReplacementNamed('/home');
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
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              if (accountFlow == AccountFlow.NAME_AND_EMAIL) {
                Navigator.of(context).pop();
                return;
              }
              if (accountFlow == AccountFlow.CONFIRMATION_CODE) {
                setState(() {
                  accountFlow = AccountFlow.NAME_AND_EMAIL;
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
                    ...nameAndEmailLayout(passwordStrength),
                    ...confirmationCodeLayout(),
                    // ...passwordLayout(passwordStrength),
                  ],
                ),
                accountFlow == AccountFlow.NAME_AND_EMAIL
                    ? const SizedBox(
                        height: 24,
                      )
                    : accountFlow == AccountFlow.CONFIRMATION_CODE
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                          )
                        : const SizedBox(
                            height: 70,
                          ),
                Column(
                  children: [
                    ...bottomButton(loading),
                    accountFlow == AccountFlow.NAME_AND_EMAIL ? RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: bodyStyle.copyWith(
                              color: AppColors.grey900,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: bodyStyle.copyWith(
                              color: AppColors.primaryBase,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamed('/login');
                              },
                          ),
                        ],
                      ),
                    ) :
                    const SizedBox(
                      height: 24,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> nameAndEmailLayout(passwordStrength) {
    if (accountFlow != AccountFlow.NAME_AND_EMAIL) {
      return [];
    }
    return [
      Text(
        "Create Your Account",
        style: subHeadingStyle.copyWith(color: AppColors.grey900),
      ),
      const SizedBox(height: 4),
      Text(
        "Sign up to enjoy all services",
        style: bodyStyle.copyWith(color: AppColors.grey700),
      ),
      const SizedBox(height: 24),
      CustomInputField(
        labelText: "Full name",
        prefix: SvgPicture.asset("assets/svg/profile.svg",color: AppColors.grey500, height: 24),
        controller: _firstNameController,
        validator: textValidator,
        autofocus: false,
      ),
      // const SizedBox(height: 24),
      // InputField(
      //   labelText: "Last name",
      //   controller: _lastNameController,
      //   validator: textValidator,
      // ),
      const SizedBox(height: 24),
      CustomInputField(
        labelText: "Email",
        controller: _emailController,
        prefix: SvgPicture.asset("assets/svg/message.svg",color: AppColors.grey500, height: 24),
        validator: emailValidator,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      CustomInputField(
        labelText: "Password",
        controller: _passwordController,
        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
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
        controller: _confirmPasswordController,
        prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
        obscureText: true,
        validator: newpasswordValidator,
      ),
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

  List<Widget> bottomButton(bool loading) {
    if (accountFlow == AccountFlow.NAME_AND_EMAIL) {
      return [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(value: termsCheck, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), onChanged: (val){
              setState(() {
                termsCheck= val ?? false;
              });
            }, checkColor: Colors.white, activeColor: AppColors.primaryBase),
            Expanded(child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "I agree to the ",
                      style: bodyStyle.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: bodyStyle.copyWith(
                        color: AppColors.primaryBase,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed('/terms_and_conditions');
                        },
                    ),
                    TextSpan(
                      text: " and ",
                      style: bodyStyle.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy policy.',
                      style: bodyStyle.copyWith(
                        color: AppColors.primaryBase,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed('/privacy_policy');
                        },
                    ),
                  ],
                )))
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        ActionButton(
          text: "Continue",
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final password = _passwordController.text;
              final confirmPassword = _confirmPasswordController.text;

              if(password != confirmPassword) {
                GeneralUtils.showToast("Passwords do not match");
                return;
              }

              if(!termsCheck) {
                GeneralUtils().displayAlertDialog(context, "Attention", "Please accept the terms and conditions.");
                return;
              }
              setState(() {
                accountFlow = AccountFlow.CONFIRMATION_CODE;
              });
              sendVerificationCode();
            }
          },
        ),
        const SizedBox(height: 30,),
        const LineDivider(text: "OR REGISTER AS A USER WITH",),
        const SizedBox(height: 40,),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (Platform.isAndroid) ? const SizedBox() : SocialButton("apple", "apple", termsCheck),
            SocialButton("google", "google", termsCheck),
          ],
        ),
        const SizedBox(height: 40,),
      ];
    }
      return [
        ActionButton(
          text: "Proceed",
          onPressed: () {
            if (verificationCode != enteredConfirmationCode) {
              GeneralUtils.showToast("Incorrect verification code");
              return;
            }
            enteredConfirmationCode = "";
            if (_formKey.currentState!.validate()) {
              final firstName = _firstNameController.text.trim().split(" ")[0];
              final lastName = _firstNameController.text.trim().split(" ").length > 1 ? _firstNameController.text.trim().split(" ")[1] : "";
              final email = _emailController.text.trim().toLowerCase();
              final password = _passwordController.text;

              Map<String, dynamic> userData = {
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "deviceToken": msgId,
                "deviceInfo": _deviceInfo,
                "documents": [],
                "user_type": "user",
              };

              Navigator.of(context).pushNamed("/set_location", arguments: userData);

              // ref.read(authNotifierProvider.notifier).createAccount(
              //     firstName: firstName,
              //     lastName: lastName,
              //     email: email,
              //     password: password,
              //     deviceToken: msgId,
              //     deviceInfo: _deviceInfo);
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ];
  }

  Future<void> sendVerificationCode() async {
    generateCode();
    // print("verification code is $verificationCode");
    final res = await GeneralUtils().makeRequest(
        "sendverificationemail",
        {
          "first_name": _firstNameController.text.trim(),
          "code": verificationCode,
          "email": _emailController.text.trim().toLowerCase()
        },
        addUserCheck: false);
    if(res.statusCode != 200) {
      final resp = jsonDecode(res.body);
      GeneralUtils.showToast(resp["message"]);
      return;
    }
    GeneralUtils.showToast("Verification code sent");
  }
}
