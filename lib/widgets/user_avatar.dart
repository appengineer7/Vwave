import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vwave/presentation/auth/models/user.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/widgets/styles/app_colors.dart';

import '../../../utils/storage.dart';

class GeneralUserAvatar extends StatefulWidget {
  final double avatarSize;
  final bool? clickable;
  final String? userUid;
  final String? avatarData;

  const GeneralUserAvatar(this.avatarSize,
      {Key? key, this.clickable = false, this.userUid, this.avatarData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GeneralUserAvatar();
}

class _GeneralUserAvatar extends State<GeneralUserAvatar> {
  StorageSystem ss = StorageSystem();
  String? imageData;

  @override
  void initState() {
    super.initState();
    setState(() {
      imageData = widget.avatarData;
    });
    if ((imageData == null || imageData == "") && GeneralUtils().userUid == widget.userUid) {
      getUserImage();
    }
  }

  Future<void> getUserImage() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic>? userData = jsonDecode(user);
    if (userData!["picture"] == null || userData["picture"] == "") {
      return;
    }
    if (!mounted) return;
    setState(() {
      imageData = "${userData["picture"]}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !widget.clickable!
          ? null
          : () async {
              if (widget.userUid == null) return;
              // fetch user
              // if(GeneralUtils().userUid == null || GeneralUtils().userUid != widget.userUid) {
              //   final res = await GeneralUtils().makeRequest("getuserdata", {"user_uid": widget.userUid}, addUserCheck: false);
              //   if(res.statusCode != 200) {
              //     GeneralUtils.showToast("User does not exist");
              //     return;
              //   }
              //   final body = jsonDecode(res.body);
              //   final user = User.fromJson(body["data"]);
              //   Navigator.of(context).pushNamed(
              //       '/seller_profile',
              //       arguments: user);
              //   return;
              // }
              // final getUser = await FirebaseFirestore.instance.collection("users").doc(widget.userUid).get();
              // if(!getUser.exists) {
              //   GeneralUtils.showToast("User does not exist");
              //   return;
              // }
              // final user = User.fromDocument(getUser);
              // Navigator.of(context).pushNamed(
              //     '/seller_profile',
              //     arguments: user);
            },
      child: displayPicture(),
      // CircleAvatar(
      //   backgroundImage: (imageData == null || imageData == "")
      //       ? const AssetImage("assets/images/default_avatar.png")
      //       : NetworkImage(imageData!)
      //           as ImageProvider<Object>, //getImageObject(),
      //   backgroundColor: AppColors.titleTextColor,
      //   radius: widget.avatarSize / 2,
      // ),
    );
  }

  Widget displayPicture() {
    if(imageData == null || imageData == "") {
      return CircleAvatar(
          backgroundImage: const AssetImage("assets/images/default_avatar.png"),
        backgroundColor: AppColors.titleTextColor,
        radius: widget.avatarSize / 2,
      );
    }
    return CachedNetworkImage(
        imageUrl: imageData!,
      fit: BoxFit.contain,
      imageBuilder: (c, i) {
          return CircleAvatar(
            backgroundImage: i,
            backgroundColor: AppColors.titleTextColor,
            radius: widget.avatarSize / 2,
          );
      },
    );
  }
}
