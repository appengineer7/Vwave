import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave/utils/storage.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../club/providers/club_notifier_provider.dart';
import '../../events/pages/events_list_page.dart';
import '../../livestream/pages/livestream_list_page.dart';
import '../../messaging/pages/conversations_page.dart';
import '../../notification/pages/notification_screen.dart';
import '../../profile/pages/profile_page.dart';
import '../../stories/pages/add_to_story.dart';
import '../../stories/providers/story_notifier_provider.dart';
import '../pages/club_owner/club_owner_home.dart';
import '../pages/user/full_search_page.dart';
import '../pages/user/user_home_page.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  final String userType;
  const BottomNavBar(this.userType, {super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBar();
}

class _BottomNavBar extends ConsumerState<BottomNavBar> {

  StorageSystem ss = StorageSystem();

  int index = 0;
  final List<Widget> _userPages = [
    const UserHomePage(),
    const FullSearchPage(),
    // const IntroPage(),
    const AddToStoryPage(),
    const ConversationsPage(),
    const NotificationScreen(),
    // const ProfilePage(),
    // const SegmentedPage(),
    // GeneralUtils().userUid == null || GeneralUtils().userUid == "" ? const NotSignedInUser() : ConversationsPage(),
    // const Scaffold(),
    // GeneralUtils().userUid == null || GeneralUtils().userUid == "" ? const NotSignedInUser() : const NotificationScreen(),
    // GeneralUtils().userUid == null || GeneralUtils().userUid == "" ? const NotSignedInUser() : const UserDashboardPage(), //AccountSettingsPage(),
  ];

  final List<Widget> _clubOwnerPages = [
    const ClubOwnerHomePage(),
    const LivestreamPage(),
    const EventListPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(onPopInvoked: (pop) async {
        exit(0);
      },
          child: widget.userType == "user" ? _userPages[index] : _clubOwnerPages[index]
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (int i) {
          setState(() {
            index = i;
          });
        },
        selectedItemColor: AppColors.primaryBase,
        unselectedItemColor: AppColors.grey500,
        selectedLabelStyle: captionStyle.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: captionStyle,
        type: BottomNavigationBarType.fixed,
        items: widget.userType == "user" ? [
          BottomNavigationBarItem(
            label: 'Home',
            tooltip: 'Home',
            icon: SvgPicture.asset("assets/svg/navigation/home.svg", color: AppColors.grey500,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/home_selected.svg", color: AppColors.primaryBase,),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            tooltip: 'Search',
            icon: SvgPicture.asset("assets/svg/navigation/search.svg", color: AppColors.grey500, height: 24, width: 24,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/search.svg", height: 24, width: 24,),
          ),
          BottomNavigationBarItem(
            tooltip: "Add to story",
            label: '',
            icon: GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed("/add_to_story");
                Future.delayed(const Duration(seconds: 2), () {
                  ref.read(storyNotifierProvider.notifier).getStoryFeeds();
                  // ref.read(clubNotifierProvider.notifier).getClubs();
                });

              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBase,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // BottomNavigationBarItem(
          //   label: '',
          //   icon: GestureDetector(
          //     onTap: () {
          //       print("hello");
          //     },
          //     child: Container(
          //       width: 24,
          //       height: 24,
          //       margin: const EdgeInsets.only(top: 10),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(8),
          //         border: Border.all(color: AppColors.grey500)
          //       ),
          //       child: const Center(
          //         child: Icon(
          //           Icons.add,
          //           color: AppColors.grey500,
          //           size: 18,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          BottomNavigationBarItem(
            label: 'Chat',
            tooltip: 'Chat',
            icon: SvgPicture.asset("assets/svg/navigation/chat.svg", color: AppColors.grey500, height: 24, width: 24,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/chat_selected.svg", height: 24, width: 24,),
          ),
          BottomNavigationBarItem(
            label: 'Notifications',
            tooltip: 'Notifications',
            icon: SvgPicture.asset("assets/svg/navigation/notification.svg", color: AppColors.grey500,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/notification_selected.svg",),
          ),
          // BottomNavigationBarItem(
          //   label: 'Account',
          //   tooltip: 'Account',
          //   icon: SvgPicture.asset("assets/svg/navigation/user.svg", color: AppColors.grey500,),
          //   activeIcon: SvgPicture.asset("assets/svg/navigation/user_selected.svg", color: AppColors.primaryBase,),
          // ),
        ] : [
          BottomNavigationBarItem(
            label: 'Home',
            tooltip: 'Home',
            icon: SvgPicture.asset("assets/svg/navigation/home.svg", color: AppColors.grey500,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/home_selected.svg", color: AppColors.primaryBase,),
          ),
          BottomNavigationBarItem(
            label: 'Livestream',
            tooltip: 'Livestream',
            icon: SvgPicture.asset("assets/svg/navigation/livestream.svg", color: AppColors.grey500,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/livestream.svg", color: AppColors.primaryBase,),
          ),
          BottomNavigationBarItem(
            label: 'Events',
            tooltip: 'Events',
            icon: SvgPicture.asset("assets/svg/navigation/event.svg", color: AppColors.grey500, height: 24, width: 24,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/event.svg", color: AppColors.primaryBase, height: 24, width: 24),
          ),
          BottomNavigationBarItem(
            label: 'Account',
            tooltip: 'Account',
            icon: SvgPicture.asset("assets/svg/navigation/user.svg", color: AppColors.grey500,),
            activeIcon: SvgPicture.asset("assets/svg/navigation/user_selected.svg", color: AppColors.primaryBase,),
          ),
        ],
      ),
    );
  }
}
