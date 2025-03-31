
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/firebase.dart';
import '../../../services/dynamic_link.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../utils/validators.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../../widgets/upload_dialog_view.dart';
import '../../club/models/club.dart';
import '../../livestream/models/livestream.dart';

class StartLivestreamBottomSheet extends ConsumerStatefulWidget{
  final PersistentBottomSheetController bottomSheetController;
  const StartLivestreamBottomSheet(this.bottomSheetController, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StartLivestreamBottomSheet();
}

class _StartLivestreamBottomSheet extends ConsumerState<StartLivestreamBottomSheet> {


  bool loading = false;
  Map<String, dynamic> livestreamImage = {};
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  String? userLocation;
  String clubName = "";
  Map<String, dynamic> userLocationDetails = {};

  StorageSystem ss = StorageSystem();
  List<dynamic> coverImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getUserClubData();
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    String? club = await ss.getItem("club");
    if (user == null) {
      return;
    }
    if (club == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    Map<String, dynamic> clubData = jsonDecode(club);
    if (!mounted) return;
    setState(() {
      clubName = clubData["club_name"] ?? "";
      if(userData["location_details"] != null) {
        if(userData["location_details"]["address"] == null) {
          return;
        }
        userLocation = userData["location"];
        userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);
      }
    });
    // print("Club name is $clubName");
  }

  Future<void> getUserClubData() async {
    String? getUserClub = (await ss.getItem("club"));
    if (getUserClub == null) {
      return;
    }
    Map<String, dynamic> clubDetails = jsonDecode(getUserClub);
    clubDetails["user_uid"] = GeneralUtils().userUid;
    clubDetails["total_reviews"] = 0;
    clubDetails["rating_count"] = 0;
    final club = Club.fromJson(clubDetails);
    coverImages = club.coverImages;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 500,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)
            ),
            boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 3, blurRadius: 5)]
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12)
                ),
              ),
              const SizedBox(height: 20,),
              Text(
                "New Livestream",
                style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
              ),
              const SizedBox(height: 10,),
              const Divider(color: AppColors.grey200,),
              const SizedBox(height: 20,),
              CustomInputField(
                labelText: "Title",
                controller: _titleController,
                validator: textValidator,
                autofocus: false,
              ),
              const SizedBox(height: 20,),
              UploadDialogView(
                  uploadMessageText: "Tap to upload an image (optional)",
                  uploadMessageBodyText: "PNG, JPG, or JPEG (max. 1920x1080px)",
                  allowedExtensions: "jpg,jpeg,png",
                  allowCropAndCompress: true,
                  folderName: "livestream-images",
                  onUploadDone: (fileUpload) {
                    if(fileUpload.isNotEmpty) {
                      livestreamImage = fileUpload;
                    }
                  }),
              const SizedBox(height: 20,),
              ActionButton(
                text: "Go live",
                loading: loading,
                onPressed: goLive,
              ),
              const SizedBox(height: 24,),
              ActionButton(
                text: "Cancel",
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBase,
                borderSide: const BorderSide(color: AppColors.primaryBase),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> goLive() async {
    try {
      if (_formKey.currentState!.validate()) {
        if(coverImages.isEmpty){
          if(livestreamImage.isEmpty) {
            GeneralUtils.showToast("Upload the livestream image");
            return;
          }
        }
        widget.bottomSheetController.setState!(() {
          loading = true;
        });
        String key = ref.read(firebaseFirestoreProvider).collection("livestreams").doc().id;
        Map<String, dynamic> ld = {
          "address": userLocationDetails["address"] ?? "",
          "latitude": userLocationDetails["latitude"] ?? 0,
          "longitude": userLocationDetails["longitude"] ?? 0,
        };
        final lv = {
          "id": key,
          "user_uid": GeneralUtils().userUid ?? "",
          "title": _titleController.text.trim(),
          "club_name": clubName,
          "link": "",
          "duration": 0,
          "views": 0,
          "has_ended": false,
          "timestamp": "",
          "location_details": ld,
          "images": [livestreamImage.isEmpty ? coverImages.first : livestreamImage],
          "created_date": DateTime.now().toString(),
          "modified_date": DateTime.now().toString(),
        };

        // create dynamic link
        final dynamicLinkData = GeneralUtils().encodeValue(jsonEncode(lv));
        String dynamicLink = await WaveDynamicLink.createDynamicLink(
            key,
            _titleController.text,
            "Join $clubName livestream now on the VWave app.",
            (livestreamImage.isEmpty ? coverImages.first["url"] : livestreamImage["url"]), "livestream", dynamicLinkData);

        final livestream = Livestream(userUid: GeneralUtils().userUid ?? "", channelName: key.toLowerCase(), title: _titleController.text, clubName: clubName, duration: 0, views: 0, liveViews: 0, hasEnded: false, id: key, timestamp: FieldValue.serverTimestamp(), images: [livestreamImage.isEmpty ? coverImages.first : livestreamImage], createdDate: DateTime.now().toString(), modifiedDate: DateTime.now().toString(), locationDetails: userLocationDetails, link: dynamicLink);
        await ref.read(firebaseFirestoreProvider).collection("livestreams").doc(key).set(livestream.toJson());
        widget.bottomSheetController.setState!(() {
          loading = false;
        });
        Navigator.of(context).pop();
        // open livestream
        Navigator.of(context).pushNamed("/livestream_view", arguments: livestream);
      }
    } catch(e) {
      widget.bottomSheetController.setState!(() {
        loading = false;
      });
      GeneralUtils().displayAlertDialog(context, "Attention", "Could not start livestream. Please try again");
    }
  }
}