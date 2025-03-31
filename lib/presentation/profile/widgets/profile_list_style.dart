// import 'package:flutter/material.dart';

// import '../../../widgets/styles/app_colors.dart';
// import '../../../widgets/styles/text_styles.dart';

// class SettingsListTile extends StatelessWidget {
//   const SettingsListTile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppColors.grey200,
//         ),
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             backgroundColor: AppColors.grey50,
//             radius: 20,
//             child: Icon(
//               Icons.person_3_outlined,
//               color: AppColors.primaryBase,
//               size: 20,
//             ),
//           ),
//           const SizedBox(
//             width: 12,
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Personal Details",
//                   style: bodyStyle.copyWith(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 2,
//                 ),
//                 const Text(
//                   "Your account information",
//                   style: captionStyle,
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(
//             width: 12,
//           ),
//           const Icon(
//             Icons.chevron_right,
//             color: AppColors.grey400,
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class ProfileListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leading;
  final Widget? leadingChild;
  final Widget? trailingChild;
  final String page;
  final Color tileColor;
  final Color textColor;
  final Color borderColor;
  final bool showTrailing;
  final Function()? onPress;
  final Function()? onCallback;

  const ProfileListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.page,
    this.leadingChild,
    this.trailingChild,
    this.showTrailing = true,
    this.tileColor = Colors.transparent,
    this.textColor = AppColors.grey900,
    this.borderColor = AppColors.grey200,
    this.onPress,
    this.onCallback
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress ?? () async {
        if(trailingChild != null) {
          return;
        }
        await Navigator.of(context).pushNamed(page);
        if(onCallback != null) {
          onCallback!();
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      tileColor: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      leading: leadingChild ?? CircleAvatar(
        backgroundColor: AppColors.grey50,
        radius: 20,
        child: Icon(
          leading,
          color: AppColors.primaryBase,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: titleStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor
        ),
      ),
      subtitle: subtitle.isEmpty ? null : Text(
        subtitle,
        style: captionStyle,
      ),
      trailing: trailingChild ?? trailingWidget(),
    );
  }

  Widget trailingWidget() {
    if(showTrailing) {
      // return const Icon(
      //   Icons.chevron_right,
      //   color: AppColors.grey400,
      // );
      return SvgPicture.asset("assets/svg/arrow_forward.svg");
    }
    return const SizedBox();
  }
}
