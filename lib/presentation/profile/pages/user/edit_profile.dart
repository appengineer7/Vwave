
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vwave/utils/general.dart';

import '../../../../services/image_cropper.dart';
import '../../../../services/image_picker.dart';
import '../../../../utils/storage.dart';
import '../../../../utils/validators.dart';
import '../../../../widgets/action_button.dart';
import '../../../../widgets/custom_input_field.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../providers/profile_notifier_provider.dart';
import '../../providers/update_profile_notifier.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {

  StorageSystem ss = StorageSystem();
  final _formKey = GlobalKey<FormState>();

  String imageURL = "";
  bool uploadInProgress = false;
  bool isLoading = false;

  Map<String, dynamic> userData = {};

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
          () async {
        String getUser = (await ss.getItem('user'))!;
        setState(() {
          userData = jsonDecode(getUser);
          _firstNameController.text = userData["first_name"];
          _lastNameController.text = userData["last_name"];
          _emailController.text = userData["email"];
        });
        setState(() {
          imageURL = userData["picture"] ?? "";
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        title: Text("Edit Profile", style: titleStyle.copyWith(fontWeight: FontWeight.w700),),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      imageURL.isEmpty ? const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/images/default_avatar.png")
                      ) :
                      CachedNetworkImage(imageUrl: imageURL, fit: BoxFit.contain, imageBuilder: (c, i) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: i,
                        );
                      },),
                      // CircleAvatar(
                      //   radius: 50,
                      //   backgroundImage: imageURL.isEmpty
                      //       ? const AssetImage("assets/images/default_avatar.png")
                      //       : NetworkImage(
                      //     imageURL,
                      //   ) as ImageProvider<Object>,
                      // ),
                      uploadInProgress ? Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(115)),
                        child: const CircularProgressIndicator(
                          color: AppColors.primaryBase,
                        ),
                      ) : Positioned(
                        top: 72,
                        left: 70,
                        child: GestureDetector(
                          child: SvgPicture.asset("assets/svg/edit_square.svg"),
                          onTap: () {
                            selectImage(userData["uid"] ?? "");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  CustomInputField(
                    labelText: "First name",
                    prefix: SvgPicture.asset("assets/svg/profile.svg",color: AppColors.grey500, height: 24),
                    controller: _firstNameController,
                    validator: textValidator,
                    autofocus: false,
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    labelText: "Last name",
                    prefix: SvgPicture.asset("assets/svg/profile.svg",color: AppColors.grey500, height: 24),
                    controller: _lastNameController,
                    validator: textValidator,
                    autofocus: false,
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    labelText: "Email",
                    controller: _emailController,
                    prefix: SvgPicture.asset("assets/svg/message.svg",color: AppColors.grey500, height: 24),
                    validator: emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    enableField: false,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 3.5),
                  ActionButton(
                    text: "Save Changes",
                    loading: isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveChanges(userData["uid"] ?? "");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<void> saveChanges(String userId) async {
    String  getUser = (await ss.getItem("user"))!;
    dynamic user = jsonDecode(getUser);

    if(user["first_name"] == _firstNameController.text.trim() && user["last_name"] == _lastNameController.text.trim()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    user["first_name"] = _firstNameController.text.trim();
    user["last_name"] = _lastNameController.text.trim();
    await ss.setPrefItem("user", jsonEncode(user));

    Map<String, dynamic> mUserData = {};
    mUserData["first_name"] = _firstNameController.text.trim();
    mUserData["last_name"] = _lastNameController.text.trim();
    mUserData["id"] = userId;
    await ref
        .read(updateProfileNotifier.notifier)
        .updateProfile(
        userData: mUserData
    );

    setState(() {
      isLoading = false;
    });
    GeneralUtils.showToast("Saved");
  }

  Future<void> selectImage(String userId) async {
    String  getUser = (await ss.getItem("user"))!;
    dynamic user = jsonDecode(getUser);
    final image = await ref.read(picker).pickImage(ImageSource.gallery);

    if (image != null) {
      File imageFile = await ref.read(imageCropperProvider).compressImage(File(image.path),);
      setState(() {
        uploadInProgress = true;
      });
      String fileUrl = await ref
          .read(profileNotifierProvider.notifier)
          .uploadImage(imageFile, folder: "profile-images");
      setState(() {
        uploadInProgress = false;
        imageURL = fileUrl;
      });
      // saveUserProfile(userId);
      user["picture"] = fileUrl;
      await ss.setPrefItem("user", jsonEncode(user));

      Map<String, dynamic> mUserData = {};
      mUserData["picture"] = fileUrl;
      mUserData["id"] = userId;
      await ref
          .read(updateProfileNotifier.notifier)
          .updateProfile(
          userData: mUserData
      );
    }
  }
}