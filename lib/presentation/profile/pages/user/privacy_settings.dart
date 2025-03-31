
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';

import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {

  StorageSystem ss = StorageSystem();
  bool allowSearchVisibility = true;

  String allowConversations = "allow";
  // String defaultAllowConversations = "Allow";

  String storyPrivacyOption = "everyone";
  // String defaultStoryPrivacyOption = "Everyone";

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    userData = jsonDecode(user);
    if (!mounted) return;
    setState(() {
      allowSearchVisibility = userData["allow_search_visibility"] ?? true;
      allowConversations = userData["allow_conversations"] ?? "allow";
      storyPrivacyOption = userData["story_privacy"] ?? "everyone";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text("Privacy Settings", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text("Allow Search Visibility", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
                  subtitle: Text("Allow other users on this app to search for you?", style: captionStyle.copyWith(color: AppColors.grey900,),),
                  value: allowSearchVisibility, onChanged: (val) {
                  setState(() {
                    allowSearchVisibility = val ??= false;
                  });
                  updatePrivacySettings();
                },
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 0.5,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    title: Text("Allow Conversations", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
                    subtitle: Text("Set which users can message you.", style: captionStyle.copyWith(color: AppColors.grey900,),),
                    contentPadding: EdgeInsets.zero,
                    trailing: SizedBox(
                      width: 160,
                      child: DropdownButton<String>(items: [
                        DropdownMenuItem(value: "allow",child: Text("Everyone", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                        DropdownMenuItem(value: "not_allow",child: Text("Nobody", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                        DropdownMenuItem(value: "follows_me",child: Text("Anyone who follows me", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                        DropdownMenuItem(value: "i_follow",child: Text("Anyone I follow", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                      ], onChanged: (val){
                        setState(() {
                          allowConversations = val ??= "allow";
                        });
                        updatePrivacySettings();
                      },
                        underline: const SizedBox(),
                        value: allowConversations,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                const Divider(height: 0.5,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    title: Text("Story Privacy", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
                    subtitle: Text("Set who views your story.", style: captionStyle.copyWith(color: AppColors.grey900,),),
                    contentPadding: EdgeInsets.zero,
                    trailing: SizedBox(
                      width: 160,
                      child: DropdownButton<String>(items: [
                        DropdownMenuItem(value: "everyone",child: Text("Everyone", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                        DropdownMenuItem(value: "follows_me",child: Text("Anyone who follows me", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                        DropdownMenuItem(value: "i_follow",child: Text("Anyone I follow", style: captionStyle.copyWith(color: AppColors.grey900,)),),
                      ], onChanged: (val){
                        setState(() {
                          storyPrivacyOption = val ??= "everyone";
                        });
                        updatePrivacySettings();
                      },
                        underline: const SizedBox(),
                        value: storyPrivacyOption,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                const Divider(height: 0.5,),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   child: Row(
                //     mainAxisSize: MainAxisSize.max,
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         width: MediaQuery.of(context).size.width,
                //         child: ,
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updatePrivacySettings() async {
    userData["allow_search_visibility"] = allowSearchVisibility;
    userData["allow_conversations"] = allowConversations;
    userData["story_privacy"] = storyPrivacyOption;
    await ss.setPrefItem("user", jsonEncode(userData));
    await FirebaseFirestore.instance.collection("users").doc(GeneralUtils().userUid).update(
        {
          "allow_search_visibility": allowSearchVisibility,
          "allow_conversations": allowConversations,
          "story_privacy": storyPrivacyOption,
        }
    );
    GeneralUtils.showToast("Settings saved");
  }
}