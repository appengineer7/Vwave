
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:vwave_new/presentation/club/repositories/club_repository.dart';

import '../../../constants.dart';
import '../../../library/google_autocomplete_places.dart';
import '../../../utils/storage.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../models/club.dart';
import '../providers/club_notifier_provider.dart';
import '../providers/club_state.dart';
import '../widgets/club_vertical_display.dart';

class AllClubsPage extends ConsumerStatefulWidget {
  final List<Club> clubs;
  const AllClubsPage(this.clubs, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllClubsPageState();
}

class _AllClubsPageState extends ConsumerState<AllClubsPage> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        title: Text("Recommended Clubs", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 4.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
                itemCount: widget.clubs.length, itemBuilder: (context, index) {
                  return ClubVerticalDisplay(widget.clubs[index], showReviews: true, width: 0, marginRight: 0,);
                },
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}