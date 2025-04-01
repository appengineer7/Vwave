
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/presentation/livestream/models/livestream.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../home/widgets/start_livestream_bottom_sheet.dart';
import '../providers/livestream_notifier_provider.dart';
import '../widgets/livestream_horizontal_display.dart';

class LivestreamPage extends ConsumerStatefulWidget {
  // final List<Livestream> livestreams;
  const LivestreamPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LivestreamPage();
}

class _LivestreamPage extends ConsumerState<LivestreamPage> {


  late PersistentBottomSheetController _bottomSheetController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isAccountSetup = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      bool acctSetup = await GeneralUtils().isClubOwnerAccountSetupComplete();
      setState(() {
        isAccountSetup = acctSetup;
      });
      // await searchUsersOnline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livestreamNotifierProvider);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Livestreams", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 24), child: GestureDetector(onTap: startLivestream, child: SvgPicture.asset("assets/svg/add.svg")
          ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: state.recentLivestreams.isEmpty ? emptyLivestream() : ListView(
            children: state.recentLivestreams.map((e) => LivestreamHorizontalDisplay(e)).toList(),
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
          const SizedBox(height: 60,),
          Image.asset("assets/images/empty_livestream.png", height: MediaQuery.of(context).size.height / 2.5,),
          Text("Empty", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          Text("You have not created any livestream", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tap on the ", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
              SvgPicture.asset("assets/svg/add.svg"),
              Text(" icon to start a livestream", style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
            ],
          )

        ],
      ),
    );
  }

  Future<void> startLivestream() async {
    if(!isAccountSetup) {
      setupAccount();
      return;
    }
    final isVerified = await GeneralUtils().isClubOwnerAccountVerified();
    if(!isVerified) {
      await GeneralUtils().showResponseBottomSheet(context, "warning", "Account Verification", "Your account has not yet been verified. Please check back again.", "Ok", (){
        Navigator.of(context).pop();
      });
      return;
    }
    _bottomSheetController = _scaffoldKey.currentState!.showBottomSheet((context) {
      return StartLivestreamBottomSheet(_bottomSheetController);
    },
        backgroundColor: Colors.white,

        // isDismissible: false,
        // showDragHandle: true,
        enableDrag: false);
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