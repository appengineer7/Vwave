import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/empty_screen.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../models/club.dart';
import '../models/review.dart';
import '../widgets/club_review_display_widget.dart';

class ReviewsListPage extends StatefulWidget {
  final Club club;
  const ReviewsListPage(this.club, {super.key});

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  bool isLoading = true;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final revs = await FirebaseFirestore.instance.collection("reviews").where("club_id", isEqualTo: widget.club.id).orderBy("timestamp", descending: true).get();
      setState(() {
        reviews = revs.docs.map((e) => Review.fromDocument(e)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
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
        "Reviews",
        style: titleStyle.copyWith(
            color: AppColors.grey900, fontWeight: FontWeight.w700),
      ),
    );

    if (isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviews.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptyScreen(
                "No reviews for this club",
                imageHeight: 150,
                height: 400,
                textStyle: bodyStyle.copyWith(
                    color: AppColors.grey700, fontWeight: FontWeight.w500),
                textColor: AppColors.grey700,
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: appBar,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return ClubReviewWidget(reviews[index]);
                  })),
        ));
  }
}
