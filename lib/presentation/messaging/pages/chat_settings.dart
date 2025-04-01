
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';

import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class ChatSettingsPage extends ConsumerStatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends ConsumerState<ChatSettingsPage> {

  StorageSystem ss = StorageSystem();
  bool displayCountry = false;
  Map<String, dynamic> userLocationDetails = {};
  late String userLocation;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()async {
      String? allowCountry = await ss.getItem("allow_display_country");
      if(allowCountry == null) return;
      setState(() {
        displayCountry = allowCountry == "true";
      });
    });
    getUserData();
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    if (!mounted) return;
    setState(() {
      if(userData["location_details"] != null) {
        if(userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
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
        title: Text("Chat Settings", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text("Display Country", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
                  subtitle: Text("Allow users to see your country?", style: captionStyle.copyWith(color: AppColors.grey900,),),
                    value: displayCountry, onChanged: (val) {
                  setState(() {
                    displayCountry = val ??= false;
                  });
                  updateChatSettings();
                },
                  contentPadding: EdgeInsets.zero,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateChatSettings() async {
    final address = userLocationDetails["address"] as String;
    await ss.setPrefItem("allow_display_country", "$displayCountry", isStoreOnline: true);
    await FirebaseFirestore.instance.collection("users").doc(GeneralUtils().userUid).collection("settings").doc("chat").set(
        {
          "display_country": displayCountry,
          "country_name": address.split(",").last.trim(),
        }
    );
    GeneralUtils.showToast("Settings saved");
  }
}