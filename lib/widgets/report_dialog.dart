
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

import '../../../size_config.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/styles/app_colors.dart';

class ReportDialog {

  final TextEditingController _controller = TextEditingController(text: "");

  StorageSystem ss = StorageSystem();

  String? type = "", post_id = "";

  ReportDialog(String? _post_id, String _type) {
    post_id = _post_id;
    type = _type;
  }

  Future<Null> displayReportDialog(
      BuildContext context, String title, String body) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(
              color: AppColors.titleTextColor,
              fontSize: getProportionateScreenWidth(20),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  height: getProportionateScreenHeight(50),
                  width: getProportionateScreenWidth(50),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6F9),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 30.0),
                    child: Column(
                      children: [
                        const YourReportText(),
                        SizedBox(height: getProportionateScreenHeight(5)),
                        yourReportField(),
                      ],
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: bodyStyle.copyWith(color: AppColors.errorColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Report",
                style: bodyStyle.copyWith(color: AppColors.primaryBase),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitReport();
              },
            ),
          ],
        );
      },
    );
  }

  Widget yourReportField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border.all(
          color: AppColors.primaryBase,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLines: 1,
        obscureText: false,
        controller: _controller,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          //hintText: '',
        ),
      ),
    );
  }

  submitReport() async {
    if(_controller.text.isEmpty) {
      GeneralUtils.showToast("Enter a reason for this report");
      return;
    }
    String? key = FirebaseDatabase.instance.ref().push().key;

    //get user data
    String user = (await ss.getItem('user'))!;
    Map<String, dynamic> userData = jsonDecode(user);

    //get username
    String username = "${userData["first_name"]} ${userData["last_name"]}";

    final report = {
      "id": key,
      "post_id": post_id,
      "user_uid": userData["uid"],
      "username": username,
      "avatar": userData["picture"],
      "reason": _controller.text,
      "type": type,
      "created_date": DateTime.now().toString(),
      "timestamp": FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection("reports")
        .doc(key)
        .set(report);

    GeneralUtils.showToast("Report submitted");
  }
}

class YourReportText extends StatelessWidget {
  const YourReportText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Reason for this report",
          style: bodyStyle.copyWith(color: AppColors.titleTextColor),
        ),
        const Spacer(),
      ],
    );
  }
}
