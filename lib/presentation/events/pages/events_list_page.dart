import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/utils/general.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../providers/club_event_notifier_provider.dart';
import '../widgets/club_event_cardview.dart';

class EventListPage extends ConsumerStatefulWidget {
  const EventListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventListPageState();
}

class _EventListPageState extends ConsumerState<EventListPage> {

  bool isAccountSetup = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool acctSetup = await GeneralUtils().isClubOwnerAccountSetupComplete();
      setState(() {
        isAccountSetup = acctSetup;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubEventNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Events",
          style: titleStyle.copyWith(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
                onTap: () {
                  if(!isAccountSetup) {
                    setupAccount();
                    return;
                  }
                  Navigator.of(context).pushNamed("/create_event");
                }, child: SvgPicture.asset("assets/svg/add.svg")),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: state.clubEvents.isEmpty
              ? emptyLivestream()
              : SingleChildScrollView(
                  child: Column(
                    children: state.clubEvents
                        .map((e) => ClubEventCardViewDisplay(e, viewWidth: MediaQuery.of(context).size.width, isInit: state.upcomingEvents.indexOf(e) == 0, userType: "club_owner", locationDetails: const {}, allowRightMargin: false,))
                        .toList(),
                  ),
                ),
        ),
      ),
    );
  }

  Widget emptyLivestream() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 60,
          ),
          Image.asset(
            "assets/images/empty_livestream.png",
            height: MediaQuery.of(context).size.height / 2.5,
          ),
          Text(
            "Empty",
            style: subHeadingStyle.copyWith(
                color: AppColors.grey900, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "You have not created any events",
            style: titleStyle.copyWith(
                color: AppColors.grey700, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tap on the ",
                style: titleStyle.copyWith(
                    color: AppColors.grey700, fontWeight: FontWeight.w400),
              ),
              SvgPicture.asset("assets/svg/add.svg"),
              Text(
                " icon to create an event",
                style: titleStyle.copyWith(
                    color: AppColors.grey700, fontWeight: FontWeight.w400),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> setupAccount() async {
    await GeneralUtils().showResponseBottomSheet(context, "warning", "Account Setup", "You need to complete your account setup", "Proceed", (){
      Navigator.of(context).pop();
    });
    await Navigator.of(context).pushNamed("/club_owner_account_setup");
    bool acctSetup = await GeneralUtils().isClubOwnerAccountSetupComplete();
    setState(() {
      isAccountSetup = acctSetup;
    });
  }
}
