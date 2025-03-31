
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/club/models/review.dart';

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
import '../../livestream/models/livestream.dart';
import '../models/club.dart';

class CreateNewReviewBottomSheet extends ConsumerStatefulWidget{
  final Club club;
  const CreateNewReviewBottomSheet(this.club, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateNewReviewBottomSheet();
}

class _CreateNewReviewBottomSheet extends ConsumerState<CreateNewReviewBottomSheet> {


  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bodyController = TextEditingController();

  StorageSystem ss = StorageSystem();

  Map<String, dynamic> userProfile = {};

  int rating = 0;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    Map<String, dynamic> userData = jsonDecode(user);
    if (!mounted) return;
    userProfile = userData;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.6,
        snapAnimationDuration: const Duration(milliseconds: 400),
        snap: true,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
      return GestureDetector(
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), topRight: Radius.circular(40)
                ),
                // boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 3, blurRadius: 5)]
              ),
              child: SingleChildScrollView(
                controller: scrollController,
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
                      "Leave Review",
                      style: subHeadingStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(color: AppColors.grey200,),
                    const SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.grey400,
                          )),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _bodyController,
                        validator: textValidator,
                        maxLines: 10,
                        minLines: 3,
                        maxLength: 600,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (t) {
                          setState(() {});
                        },
                        maxLengthEnforcement:
                        MaxLengthEnforcement.truncateAfterCompositionEnds,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Write your review",
                          hintStyle: titleStyle.copyWith(
                              color: AppColors.grey400,
                              fontWeight: FontWeight.w400),
                          labelStyle: titleStyle.copyWith(
                            color: AppColors.titleTextColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),),

                    const SizedBox(height: 20,),
                    showStars(),
                    const SizedBox(height: 20,),
                    ActionButton(
                      text: "Submit",
                      loading: loading,
                      onPressed: submitReview,
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
          ));
    });
  }

  Widget showStars() {
    final list = [1,2,3,4,5];
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list.map((e) => GestureDetector(
        onTap: (){
          setState(() {
            rating = e;
          });
        },
        child: SvgPicture.asset("assets/svg/star.svg", height: 24, color: e <= rating ? AppColors.starColor : AppColors.grey500,),
      )).toList(),
    );
  }

  Future<void> submitReview() async {
    try {
      if (_formKey.currentState!.validate()) {
        if(rating == 0) {
          GeneralUtils.showToast("Select rating");
          return;
        }
        setState(() {
          loading = true;
        });

        String key = ref.read(firebaseFirestoreProvider).collection("reviews").doc().id;

        final review = Review(id: key, clubId: widget.club.id ?? "", userUid: GeneralUtils().userUid ?? "", image: userProfile["picture"], name: "${userProfile["first_name"]} ${userProfile["last_name"]}", rating: rating, body: _bodyController.text.trim(), date: DateTime.now().toString(), timestamp: FieldValue.serverTimestamp());

        await ref.read(firebaseFirestoreProvider).collection("reviews").doc(key).set(review.toJson());

        setState(() {
          loading = false;
        });

        GeneralUtils.showToast("Review submitted");

        Navigator.of(context).pop();
      }
    } catch(e) {
      setState(() {
        loading = false;
      });
      GeneralUtils().displayAlertDialog(context, "Attention", "Could not submit the review. Please try again");
    }
  }
}