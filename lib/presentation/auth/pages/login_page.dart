import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/auth/providers/auth_state_notifier.dart';
import 'package:vwave/utils/validators.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/input_field.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

import '../../../widgets/custom_input_field.dart';
import '../../../widgets/line_divider.dart';
import '../../../widgets/social_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../providers/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String msgId = "", _deviceInfo = "";

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getTokenAndDeviceInfo();
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 24),
        //   child: NavBackButton(
        //     color: AppColors.titleTextColor,
        //     onPress: () {
        //       Navigator.of(context).pushReplacementNamed("/auth_intro");
        //     },
        //   ),
        // ),
        title: SvgPicture.asset(
          "assets/images/logo.svg",
          width: 120,
        ),
      ),
      body: PopScope(canPop: true, onPopInvoked: (pop) {
        Navigator.of(context).pushReplacementNamed("/auth_intro");
      },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello 👋, Welcome Back!",
                          style: subHeadingStyle.copyWith(color: AppColors.grey900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sign in to your account",
                          style: bodyStyle.copyWith(color: AppColors.grey700),
                        ),
                        const SizedBox(height: 24),
                        CustomInputField(
                          labelText: "Email Address",
                          prefix: SvgPicture.asset("assets/svg/message.svg",color: AppColors.grey500, height: 24),
                          controller: _emailController,
                          validator: emailValidator,
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        CustomInputField(
                          labelText: "Password",
                          prefix: SvgPicture.asset("assets/svg/password.svg",color: AppColors.grey500, height: 24),
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () {
                                  Navigator.of(context).pushNamed("/forgot_password");
                                },
                                child: Text("Forgot password?", style: bodyStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.primaryBase),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        ActionButton(
                          loading: loading,
                          text: "Sign in",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text.trim().toLowerCase();
                              final password = _passwordController.text;
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .signIn(email: email, password: password, deviceToken: msgId,
                                  deviceInfo: _deviceInfo);
                            }
                          },
                        ),
                        const SizedBox(height: 40,),
                        const LineDivider(),
                        const SizedBox(height: 40,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (Platform.isAndroid) ? const SizedBox() : const SocialButton("apple", "apple", true),
                            const SocialButton("google", "google", true),
                          ],
                        ),
                        const SizedBox(height: 40,),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: bodyStyle.copyWith(
                                  color: AppColors.grey900,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign up',
                                style: bodyStyle.copyWith(
                                  color: AppColors.primaryBase,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).pushNamed("/auth_intro");
                                    // Navigator.of(context).pushNamed('/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 0,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
