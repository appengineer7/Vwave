import 'package:flutter/material.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class MultipleOptionsBottomSheet extends StatelessWidget {
  final String type;
  final bool isHost;
  final double containerHeight;
  MultipleOptionsBottomSheet(this.type, {
    super.key, this.isHost = false, this.containerHeight = 350
  });

  final options = {
    "chat_block": ["Block user", "Report user"],
    "chat_unblock": ["Unblock user", "Report user"],
    "user": ["Report user", "Share profile"],
    "club": ["Report club", "Share club profile"],
    "post": ["Edit post", "Delete post"],
    "post_general": ["Report post", "Share post"],
    "listing": ["Edit listing", "Delete listing"],
    "livestream": ["Club Details", "Report Club", "Copy Link", "Share Livestream"],
    "upload_document": ["Take a picture", "Upload from gallery", "Upload from files"]
  };


  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Options",
                    style: titleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
            const Divider(
              color: AppColors.grey200,
            ),
            ...buildOptions(context),
            // const SizedBox(
            //   height: 16,
            // ),
            // InkWell(
            //   onTap: (){
            //     Navigator.of(context).pop(options[type]![0]);
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 24),
            //     child: Container(
            //       width: double.infinity,
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         border: Border.all(color: AppColors.grey200),
            //       ),
            //       child: Text(options[type]![0]), //"Report user"
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 16,
            // ),
            // InkWell(
            //   onTap: (){
            //     Navigator.of(context).pop(options[type]![1]);
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 24),
            //     child: Container(
            //       width: double.infinity,
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         border: Border.all(color: AppColors.grey200),
            //       ),
            //       child: Text(options[type]![1]), //"Share profile"
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildOptions(BuildContext context) {
    List<String> ops = options[type]!;

    if(type == "livestream" && isHost) {
      List<String> getOptions = options[type]!;
      ops = getOptions.where((op) => op != "Report Club").toList();
    }

    return ops.map((e) {
      return Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).pop(e);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Text(e), //"Share profile"
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
