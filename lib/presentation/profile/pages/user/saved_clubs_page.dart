import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave_new/presentation/club/providers/club_notifier_provider.dart';

import '../../../../constants.dart';
import '../../../../utils/general.dart';
import '../../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../../widgets/empty_screen.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../club/providers/club_state.dart';
import '../../../club/widgets/club_vertical_display.dart';

class SavedClubsPage extends ConsumerStatefulWidget {
  const SavedClubsPage({super.key});

  @override
  ConsumerState<SavedClubsPage> createState() => _SavedClubsPageState();
}

class _SavedClubsPageState extends ConsumerState<SavedClubsPage> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      // final ClubState state = ref.read(clubNotifierProvider);
      // if(state.savedClubs.isEmpty) {
      //
      // }
      ref.read(clubNotifierProvider.notifier).getSavedClubs();

      // final prefs = await SharedPreferences.getInstance();
      // final seen = prefs.getBool(PrefKeys.favouritesIntro) ?? false;
      // if(!seen) {
      //   GeneralUtils.showToast("Long press on an item to delete.");
      //   prefs.setBool(PrefKeys.favouritesIntro, true);
      // }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubNotifierProvider);
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
      title: Text("Favorites", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      // actions: [
      //   InkWell(
      //     onTap: () async {
      //       await showModalBottomSheet(context: context, builder: (context) {
      //         return FilterProfileBottomSheet((selection) {
      //           filterSelection(selection, state);
      //         });
      //       }, isDismissible: false, showDragHandle: true, enableDrag: false, backgroundColor: Colors.white);
      //     },
      //     child: Padding(padding: const EdgeInsets.only(right: 24), child: SvgPicture.asset("assets/svg/filter.svg"),),
      //   )
      // ],
    );

    if (state.loading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.error.isNotEmpty) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Text(state.error),
        ),
      );
    }
    if (state.savedClubs.isEmpty) {
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
                "No favourite club data!",
                imageHeight: 150,
                height: 400,
                textStyle: bodyStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w500),
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
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 4.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.savedClubs.length,
              itemBuilder: (context, index) {
                return ClubVerticalDisplay(state.savedClubs[index]["club"], showReviews: true, width: 0, marginRight: 0, showFavIcon: true, onLongPressed: (club) async {
                  await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return BottomSheetMultipleResponses(
                        imageName: "",
                        title: "Remove From Favorites?",
                        subtitle: "Are you sure you want to remove?",
                        buttonTitle: "Yes, Remove",
                        cancelTitle: "Cancel",
                        onPress: () async {
                          await ref.read(clubNotifierProvider.notifier).deleteSavedClub(state.savedClubs[index]["item_id"], club.id!);
                          Navigator.of(context).pop();
                        },
                        titleStyle: subHeadingStyle.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
                  },
                  isDismissible: false,
                  showDragHandle: true,
                  enableDrag: false);
                },);
              },
            ),
          )),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       const SizedBox(
      //         height: 30,
      //       ),
      //       // Expanded(
      //       //   child: ,
      //       // )
      //
      //     ],
      //   ),
      // ),
    );
  }

  void filterSelection(String selection, ClubState state) {
    if(selection.isEmpty) {
      return;
    }
    if(state.savedClubs.isEmpty) {
      return;
    }

    if(selection == "old") {
      setState(() {
        state.savedClubs.sort((a, b) {
          final firstTime = DateTime.parse(a["product"].createdDate).millisecond;
          final secondTime = DateTime.parse(b["product"].createdDate).millisecond;
          return firstTime - secondTime;
        });
      });
      return;
    }

    if(selection == "new") {
      setState(() {
        state.savedClubs.sort((a, b) {
          final firstTime = DateTime.parse(a["product"].createdDate).millisecond;
          final secondTime = DateTime.parse(b["product"].createdDate).millisecond;
          return secondTime - firstTime;
        });
      });
      return;
    }
  }
}
