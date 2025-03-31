import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vwave/utils/validators.dart';
import 'package:vwave/widgets/action_button.dart';
import 'package:vwave/widgets/input_field.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

import '../../../widgets/styles/app_colors.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _password2Controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("VWave"),
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
                    const Text(
                      "Create Your Password",
                      style: subHeadingStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter a secure password",
                      style: bodyStyle.copyWith(color: AppColors.grey600),
                    ),
                    const SizedBox(height: 24),
                    InputField(
                      labelText: "Password",
                      controller: _passwordController,
                      obscureText: true,
                      validator: newpasswordValidator,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      labelText: "Confirm Password",
                      controller: _password2Controller,
                      obscureText: true,
                    ),
                  ],
                ),
                Column(
                  children: [
                    ActionButton(
                      text: "Let's go",
                      onPressed: () {},
                    ),
                    const SizedBox(
                      height: 27,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: bodyStyle.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: bodyStyle.copyWith(
                              color: AppColors.primaryBase,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
