
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/providers/auth_state_notifier.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPage();
}

class _DeleteAccountPage extends ConsumerState<DeleteAccountPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Delete Account",
          style: titleStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "We are sad to see you go 😔",
                style: subHeadingStyle.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Text(
                """We are sorry to hear that you're considering deleting your account and data from the VWave application. If you've made this decision, we are sad to see you go.

We are truly sorry to hear that you're thinking about deleting your account and data from the VWave application. We can only imagine that this must be a difficult decision for you. Please know that we support whatever choice you make and we are here to support any issues you might be having. If there's anything we can do to assist you in this process, please don't hesitate to reach out. Your feelings and privacy are important, and we are here to support you during this time.
                """,
                style: titleStyle.copyWith(
                  color: AppColors.grey900,),
              ),
              const SizedBox(
                height: 50,
              ),
              ActionButton(text: "Delete Account", onPressed: () async {
                await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheetMultipleResponses(
                          imageName: "",
                          title: "Attention",
                          subtitle: "Please confirm you want to proceed with the account deletion.",
                          buttonTitle: "Proceed",
                          cancelTitle: "Cancel",
                          onPress: () async {
                            await ref.read(authNotifierProvider.notifier).deleteAccount();
                          },
                          titleStyle: subHeadingStyle.copyWith(
                              fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
                    },
                    isDismissible: false,
                    showDragHandle: true,
                    enableDrag: false);
              })
            ],
          ),
        ),
      ),
    );
  }
}