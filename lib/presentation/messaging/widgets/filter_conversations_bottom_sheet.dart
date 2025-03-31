import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave_new/presentation/notification/models/notification.dart';
import 'package:vwave_new/widgets/action_button.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';
import 'package:intl/intl.dart';

class FilterConversationBottomSheet extends StatefulWidget {

  // final String itemName, location;
  // final dynamic itemPrice;
  // final NotificationModel notificationModel;
  final Function(String selection) onSelection;

  const FilterConversationBottomSheet(this.onSelection,
      {super.key});

  @override
  State<StatefulWidget> createState() => _FilterConversationBottomSheet();
}

class _FilterConversationBottomSheet extends State<FilterConversationBottomSheet> {


  String selection = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 500,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(10), right: Radius.circular(10))),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter",
                    style: titleStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.grey900),
                    textAlign: TextAlign.start,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.grey500,
                      ))
                ],
              ),
            ),
            const Divider(color: AppColors.grey200,),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        selection = "all";
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey200),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child:Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "All Messages",
                              style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.start,
                            ),
                            selection == "all" ? const Icon(Icons.check_circle, color: AppColors.primaryBase,) : const Icon(Icons.circle_outlined, color: AppColors.grey200,)
                          ]
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10.0,
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        selection = "unread";
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey200),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child:Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Unread Messages",
                              style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.start,
                            ),
                            selection == "unread" ? const Icon(Icons.check_circle, color: AppColors.primaryBase,) : const Icon(Icons.circle_outlined, color: AppColors.grey200,)
                          ]
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        selection = "read";
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey200),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child:Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Read Messages",
                              style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.start,
                            ),
                            selection == "read" ? const Icon(Icons.check_circle, color: AppColors.primaryBase,) : const Icon(Icons.circle_outlined, color: AppColors.grey200,)
                          ]
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30.0,
                  ),

                  ActionButton(
                      text: "Done",
                      onPressed: () async {
                        widget.onSelection(selection);
                        Navigator.of(context).pop(false);
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
