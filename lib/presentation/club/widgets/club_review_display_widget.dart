
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave/presentation/club/models/review.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';
import 'package:vwave/widgets/user_avatar.dart';

class ClubReviewWidget extends StatefulWidget {
  final Review review;
  const ClubReviewWidget(this.review, {super.key});

  @override
  State<StatefulWidget> createState() => _ClubReviewWidget();
}

class _ClubReviewWidget extends State<ClubReviewWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: GeneralUserAvatar(30, avatarData: widget.review.image, clickable: false, userUid: widget.review.userUid)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.review.name, style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
                  const SizedBox(width: 5,),
                  SvgPicture.asset("assets/svg/star.svg"),
                  const SizedBox(width: 5,),
                  Text("${widget.review.rating}", style: bodyStyle.copyWith(color: AppColors.grey900),),
                ],
              ),
              subtitle: Text(widget.review.date.split(" ").first, style: captionStyle.copyWith(color: AppColors.grey600),),
            ),
            Text(widget.review.body, style: captionStyle.copyWith(color: AppColors.grey600),)
          ],
        )
    );
  }
}