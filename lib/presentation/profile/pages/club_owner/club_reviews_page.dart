import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/utils.dart';
import 'package:vwave/presentation/club/models/club.dart';
import 'package:vwave/utils/general.dart';

import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../club/models/review.dart';
import '../../../club/widgets/club_review_display_widget.dart';

class ClubReviewsPage extends ConsumerStatefulWidget {
  const ClubReviewsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClubReviewsPage();
}

class _ClubReviewsPage extends ConsumerState<ClubReviewsPage> {
  
  Club? club;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final getClub = await FirebaseFirestore.instance.collection("clubs").doc(GeneralUtils().userUid).get();
      setState(() {
        club = Club.fromDocument(getClub);
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
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
          title: Text(
            "Reviews Overview",
            style: titleStyle.copyWith(
                color: AppColors.grey900, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(24),
                child: club == null ? const Center(
                  child: CircularProgressIndicator(),
                ) : SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(double.parse("${club!.totalRating ?? 0.0}").toStringAsFixed(1),
                              textAlign: TextAlign.start,
                              style: subHeadingStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                  fontSize: 24
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset("assets/svg/star.svg"),
                                    const SizedBox(width: 5,),
                                    SvgPicture.asset("assets/svg/star.svg"),
                                    const SizedBox(width: 5,),
                                    SvgPicture.asset("assets/svg/star.svg"),
                                    const SizedBox(width: 5,),
                                    SvgPicture.asset("assets/svg/star.svg"),
                                    const SizedBox(width: 5,),
                                    SvgPicture.asset("assets/svg/star.svg"),
                                    const SizedBox(width: 5,),
                                  ],
                                ),
                                Text("Based on ${club!.totalReviews} review(s)", style: captionStyle.copyWith(color: AppColors.grey600),),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10,),
                        buildRatingBreakdownLayout("5", AppColors.green),
                        buildRatingBreakdownLayout("4", AppColors.primaryBase),
                        buildRatingBreakdownLayout("3", AppColors.alertWarningTextColor),
                        buildRatingBreakdownLayout("2", AppColors.alertDangerBackgroundColors),
                        buildRatingBreakdownLayout(" 1", AppColors.secondaryBase),
                        ...displayRecentReviews(),
                      ],
                )))));
  }

  Widget buildRatingBreakdownLayout(String rating, Color valueColor) {
    final ratingCount = club!.ratingCountObject == null ? 0 : club!.ratingCountObject[rating.trim()] ?? 0;
    double progressPercentage = 0;
    if(ratingCount == 0 && club!.totalReviews == 0) {
      progressPercentage = 0;
    } else if(ratingCount > 0 && club!.totalReviews == 0) {
      progressPercentage = 0;
    } else {
      progressPercentage = (ratingCount / club!.totalReviews) * 100;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(rating, style: bodyStyle.copyWith(color: AppColors.grey900),),
              const SizedBox(width: 5,),
              SvgPicture.asset("assets/svg/star.svg"),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.35,
            child: LinearProgressIndicator(backgroundColor: AppColors.grayNeutral, value: progressPercentage / 100, borderRadius: BorderRadius.circular(8), valueColor: AlwaysStoppedAnimation<Color>(valueColor),),
          ),
        ],
      ),
    );
  }

  List<Widget> displayRecentReviews() {
    if(club!.recentReviews.isEmpty) {
      return [
        const SizedBox(height: 30,),
      ];
    }
    return [
      const SizedBox(height: 30,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Reviews", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
          (club!.totalReviews <= 2) ? const SizedBox() : GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed("/club_reviews", arguments: club);
            },
            child: Text("View All", style: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),),
          ),
        ],
      ),
      Column(
        children: club!.recentReviews.map((e) {
          Review review = Review.fromJson(e);
          return ClubReviewWidget(review);
        }).toList(),
      ),
      const SizedBox(height: 60,),
    ];
  }
}
