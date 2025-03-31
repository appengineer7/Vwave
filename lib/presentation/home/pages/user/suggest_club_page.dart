import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vwave_new/widgets/custom_input_field.dart';

import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../utils/validators.dart';
import '../../../../widgets/action_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';

class ClubSuggestionPage extends StatefulWidget {
  const ClubSuggestionPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClubSuggestionPageState();
}

class _ClubSuggestionPageState extends State<ClubSuggestionPage> {
  final _formKey = GlobalKey<FormState>();
  StorageSystem ss = StorageSystem();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubAddressController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool isLoading = false;
  bool makeAnon = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubAddressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Suggest a Club",
          style: titleStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 0),
                          Text(
                            "We need your Suggestions",
                            style: bodyStyle.copyWith(
                                color: AppColors.grey900,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "Let us know your favorite clubs that you want to see on the VWave app. We will contact them and get them signed up.",
                            style: bodyStyle.copyWith(color: AppColors.grey900),
                          ),
                          const SizedBox(height: 24),
                          CustomInputField(
                            labelText: "Club name",
                            controller: _clubNameController,
                            validator: textValidator,
                            autofocus: false,
                          ),
                          const SizedBox(height: 24),
                          CustomInputField(
                            labelText: "Club address",
                            controller: _clubAddressController,
                            validator: textValidator,
                            autofocus: false,
                          ),
                          const SizedBox(height: 24),
                          CustomInputField(
                            maxLines: 6,
                            labelText: "Other information",
                            controller: _messageController,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Make Anonymous?",
                                style: bodyStyle,
                              ),
                              Switch(
                                inactiveTrackColor: AppColors.grey200,
                                inactiveThumbColor: AppColors.white,
                                trackOutlineColor:
                                WidgetStateProperty.all<Color>(
                                    Colors.transparent),
                                activeColor: AppColors.primaryBase,
                                value: makeAnon,
                                onChanged: (bool value) {
                                  setState(() {
                                    makeAnon = value;
                                  });
                                },
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          ActionButton(
                              text: "Send",
                              loading: isLoading,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final clubName = _clubNameController.text.trim();
                                  final clubAddress = _clubAddressController.text.trim();
                                  final message = _messageController.text;

                                  final id = FirebaseFirestore.instance.collection("club_suggestions").doc().id;

                                  Map<String, dynamic> feedbackData = {};
                                  feedbackData["id"] = id;
                                  feedbackData["club_name"] = clubName;
                                  feedbackData["club_address"] = clubAddress;
                                  feedbackData["message"] = message;
                                  feedbackData["created_date"] = DateTime.now().toString();
                                  feedbackData["timestamp"] = FieldValue.serverTimestamp();

                                  if(!makeAnon) {
                                    String  getUser = (await ss.getItem("user"))!;
                                    dynamic user = jsonDecode(getUser);
                                    feedbackData["email"] = user["email"];
                                    feedbackData["picture"] = user["picture"];
                                    feedbackData["name"] = "${user["first_name"]} ${user["last_name"]}";
                                  }

                                  setState(() {
                                    isLoading = true;
                                  });

                                  await FirebaseFirestore.instance.collection("club_suggestions").doc(id).set(feedbackData);

                                  setState(() {
                                    isLoading = true;
                                  });
                                  GeneralUtils.showToast("Suggestion submitted");
                                  Navigator.of(context).pop();
                                }
                              })
                        ],
                      ))))),
    );
  }
}
