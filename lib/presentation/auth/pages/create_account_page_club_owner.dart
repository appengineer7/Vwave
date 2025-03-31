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
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/password_slider.dart';
import '../../../widgets/pin_input_form.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/upload_dialog_view.dart';
import '../providers/auth_state.dart';
import '../providers/auth_state_notifier.dart';
import '../providers/password_strength_notifier.dart';

class CreateAccountClubOwnerPage extends ConsumerStatefulWidget {
  const CreateAccountClubOwnerPage({super.key});

  @override
  ConsumerState<CreateAccountClubOwnerPage> createState() => _CreateAccountClubOwnerPage();
}

enum AccountFlow { NAME_AND_EMAIL, CONFIRMATION_CODE }

class _CreateAccountClubOwnerPage extends ConsumerState<CreateAccountClubOwnerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  // final TextEditingController _locationController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String msgId = "", _deviceInfo = "";
  String verificationCode = "";
  String enteredConfirmationCode = "";

  bool termsCheck = false;

  List<Map<String, dynamic>> businessDocumentsUpload = [];

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
    _businessNameController.dispose();
    // _locationController.dispose();
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
            // Navigator.of(context).pushReplacementNamed('/home');
          } else if (newState is AuthErrorState) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     elevation: 4,
            //     backgroundColor: Colors.red,
            //     content: Text(
            //       newState.message,
            //       style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
            //     ),
            //   ),
            // );
          }
        });
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
              // if (accountFlow == AccountFlow.LOCATION) {
              //   setState(() {
              //     accountFlow = AccountFlow.CONFIRMATION_CODE;
              //   });
              //   return;
              // }
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
                    ? const SizedBox( height: 24,)
                    : accountFlow == AccountFlow.CONFIRMATION_CODE
                    ? SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                )
                    : const SizedBox(
                  height: 70,
                ),
                Column(
                  children: [
                    ...bottomButton(),
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
        labelText: "Business Name",
        controller: _businessNameController,
        prefix: SvgPicture.asset("assets/svg/profile.svg",color: AppColors.grey500, height: 24),
        validator: textValidator,
        autofocus: false,
      ),
      const SizedBox(height: 24),
      CustomInputField(
        labelText: "Business Email",
        prefix: SvgPicture.asset("assets/svg/message.svg",color: AppColors.grey500, height: 24),
        controller: _emailController,
        validator: emailValidator,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      UploadDialogView(allowCropAndCompress: false, allowMultipleOptions: true, rowLeftWidth: 15.0, uploadMessageText: "Tap to upload company registration \ndocument", onUploadDone: (fileUpload) {
        if(fileUpload.isNotEmpty) {
          businessDocumentsUpload.add(fileUpload);
        }
      }, onClear: (file) {
        if(file.isNotEmpty) {
          businessDocumentsUpload.remove(file);
        }
      },),
      const SizedBox(height: 24),
      UploadDialogView(allowCropAndCompress: false, allowMultipleOptions: true, rowLeftWidth: 15.0, uploadMessageText: "Tap to upload driver's license of company's representative", onUploadDone: (fileUpload) {
        if(fileUpload.isNotEmpty) {
          businessDocumentsUpload.add(fileUpload);
        }
      }, onClear: (file) {
        if(file.isNotEmpty) {
          businessDocumentsUpload.remove(file);
        }
      },),
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

  // List<Widget> passwordLayout(PasswordStrength passwordStrength) {
  //   if (accountFlow != AccountFlow.PASSWORD) {
  //     return [];
  //   }
  //   return [
  //     Text(
  //       "Create Your Password",
  //       style: subHeadingStyle.copyWith(color: AppColors.secondaryBase),
  //     ),
  //     const SizedBox(height: 4),
  //     Text(
  //       "Enter a secure password",
  //       style: bodyStyle.copyWith(color: AppColors.grey600),
  //     ),
  //     const SizedBox(height: 24),
  //     InputField(
  //       labelText: "Password",
  //       controller: _passwordController,
  //       obscureText: true,
  //       validator: newpasswordValidator,
  //     ),
  //     const SizedBox(height: 16),
  //     InputField(
  //       labelText: "Confirm Password",
  //       controller: _confirmPasswordController,
  //       obscureText: true,
  //       validator: newpasswordValidator,
  //     ),
  //     const SizedBox(height: 16),
  //     Row(
  //       children: [
  //         passwordStrength.minimumCharacters
  //             ? const Icon(
  //           Icons.check,
  //           color: Colors.green,
  //         )
  //             : const Icon(
  //           Icons.close,
  //           color: AppColors.errorColor,
  //         ),
  //         const SizedBox(
  //           width: 4,
  //         ),
  //         const Text("Minimum 8 Characters")
  //       ],
  //     ),
  //     const SizedBox(height: 8),
  //     Row(
  //       children: [
  //         passwordStrength.hasNumber
  //             ? const Icon(
  //           Icons.check,
  //           color: Colors.green,
  //         )
  //             : const Icon(
  //           Icons.close,
  //           color: AppColors.errorColor,
  //         ),
  //         const SizedBox(
  //           width: 4,
  //         ),
  //         const Text("At least 1 number (0-9)")
  //       ],
  //     ),
  //     const SizedBox(height: 8),
  //     Row(
  //       children: [
  //         passwordStrength.hasUppercaseLetter
  //             ? const Icon(
  //           Icons.check,
  //           color: Colors.green,
  //         )
  //             : const Icon(
  //           Icons.close,
  //           color: AppColors.errorColor,
  //         ),
  //         const SizedBox(
  //           width: 4,
  //         ),
  //         const Text("At least 1 uppercase letter")
  //       ],
  //     ),
  //     const SizedBox(height: 8),
  //     Row(
  //       children: [
  //         passwordStrength.hasLowercaseLetter
  //             ? const Icon(
  //           Icons.check,
  //           color: Colors.green,
  //         )
  //             : const Icon(
  //           Icons.close,
  //           color: AppColors.errorColor,
  //         ),
  //         const SizedBox(
  //           width: 4,
  //         ),
  //         const Text("At least 1 lowercase letter")
  //       ],
  //     ),
  //   ];
  // }

  List<Widget> bottomButton() {
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
                      text: 'Privacy Policy.',
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
          height: 20,
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

              if(businessDocumentsUpload.isEmpty || businessDocumentsUpload.length != 2) {
                GeneralUtils().displayAlertDialog(context, "Attention", "Please upload the required documents.");
                return;
              }
              setState(() {
                accountFlow = AccountFlow.CONFIRMATION_CODE;
              });
              sendVerificationCode();
            }
          },
        ),
        const SizedBox(
          height: 30,
        ),

      ];
    }
    // if (accountFlow == AccountFlow.CONFIRMATION_CODE) {
    //   return [
    //     ActionButton(
    //       text: "Proceed",
    //       onPressed: () {
    //         if (verificationCode == enteredConfirmationCode) {
    //           enteredConfirmationCode = "";
    //
    //           return;
    //         }
    //         GeneralUtils.showToast("Incorrect verification code");
    //       },
    //     ),
    //     const SizedBox(
    //       height: 20,
    //     ),
    //     // ActionButton(
    //     //   loading: loading,
    //     //   text: "Resend Code",
    //     //   backgroundColor: AppColors.primary50,
    //     //   foregroundColor: AppColors.primaryBase,
    //     //   onPressed: sendVerificationCode,
    //     // ),
    //     // const SizedBox(
    //     //   height: 20,
    //     // ),
    //   ];
    // }
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
            final businessName = _businessNameController.text.trim();
            final email = _emailController.text.trim().toLowerCase();
            final password = _passwordController.text;

            Map<String, dynamic> userData = {
              "firstName": businessName,
              "lastName": "",
              "email": email,
              "password": password,
              "deviceToken": msgId,
              "deviceInfo": _deviceInfo,
              "documents": businessDocumentsUpload,
              "user_type": "club_owner",
            };

            Navigator.of(context).pushNamed("/set_location", arguments: userData);

            // ref.read(authNotifierProvider.notifier).createAccount(
            //     firstName: businessName,
            //     lastName: "",
            //     email: email,
            //     password: password,
            //     deviceToken: msgId,
            //     deviceInfo: _deviceInfo);
          }
        },
      ),
    ];
  }

  Future<void> sendVerificationCode() async {
    generateCode();
    // print("verification code is $verificationCode");
    final res = await GeneralUtils().makeRequest(
        "sendverificationemail",
        {
          "first_name": _businessNameController.text.trim(),
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
