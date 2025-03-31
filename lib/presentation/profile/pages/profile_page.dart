import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave_new/common/providers/firebase.dart';
import 'package:vwave_new/presentation/profile/widgets/profile_list_style.dart';

import '../../../constants.dart';
import '../../../services/dynamic_link.dart';
import '../../../services/image_cropper.dart';
import '../../../services/image_picker.dart';
import '../../../utils/general.dart';
import '../../../utils/storage.dart';
import '../../../widgets/bottom_sheet_multiple_responses.dart';
import '../../../widgets/nav_back_button.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../../auth/providers/auth_state.dart';
import '../../auth/providers/auth_state_notifier.dart';
import '../../club/providers/club_notifier_provider.dart';
import '../../club/providers/club_state.dart';
import '../providers/profile_notifier_provider.dart';
import '../providers/update_profile_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  StorageSystem ss = StorageSystem();

  String imageURL = "";
  bool uploadInProgress = false;

  Map<String, dynamic> userData = {};
  String? userType;

  int followersCount = 0;
  int followingCount = 0;
  int favouritesCount = 0;

  int livestreamsCount = 0;
  double duration = 0;
  double views = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        // final ClubState state = ref.read(clubNotifierProvider);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          userType = prefs.getString("user_type");
          // favouritesCount = state.savedClubs.length;
        });
        await getProfileDetails();
        if(userType == "club_owner") {
          fetchLivestreamsData();
        }
        if(userType == "user") {
          fetchFriendsCount(forceRefresh: false);
          // fetchFavouritesCount(forceRefresh: false);
        }
      },
    );
  }

  Future<void> getProfileDetails() async {
    String getUser = (await ss.getItem('user'))!;
    if(!mounted) return;
    setState(() {
      userData = jsonDecode(getUser);
      imageURL = userData["picture"] ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchLivestreamsData() async {
    String? getClubProfileSettingsData = await ss.getItem("clubProfileSettingsData");
    if(getClubProfileSettingsData != null) {
      final sd = jsonDecode(getClubProfileSettingsData);
      if(!mounted) return;
      setState(() {
        livestreamsCount = sd["livestreamsCount"] ??= 0;
        duration = sd["duration"] ??= 0;
        views = sd["views"] ??= 0;
      });
      return;
    }

    if(GeneralUtils().userUid == null) return;
    final liveData = await ref.read(firebaseFirestoreProvider).collection("livestreams").where("user_uid", isEqualTo: GeneralUtils().userUid).aggregate(count(), sum("views"), sum("duration")).get();
    if(!mounted) return;
    setState(() {
      livestreamsCount = liveData.count ?? 0;
      duration = liveData.getSum("duration") ?? 0;
      views = liveData.getSum("views") ?? 0;
    });

    // store locally
    final clubProfileSettingsData = {
      "livestreamsCount": livestreamsCount,
      "duration": duration,
      "views": views,
    };
    await ss.setPrefItem("clubProfileSettingsData", jsonEncode(clubProfileSettingsData));
  }

  Future<void> fetchFriendsCount({bool forceRefresh = false}) async {
    try {
      if(!forceRefresh) {
        String? getUserProfileSettingsData = await ss.getItem("userProfileSettingsData");
        if(getUserProfileSettingsData != null) {
          final sd = jsonDecode(getUserProfileSettingsData);
          if(!mounted) return;
          setState(() {
            followersCount = sd["followersCount"] ??= 0;
            followingCount = sd["followingCount"] ??= 0;
          });
          fetchFavouritesCount(forceRefresh: forceRefresh);
          return;
        }
      }

      final res = await GeneralUtils().makeRequest("getfriendscount?uid=${GeneralUtils().userUid}", {}, method: "get");
      if(res.statusCode != 200) {
        return;
      }
      final resp = jsonDecode(res.body);
      if(!mounted) return;
      setState(() {
        followersCount = resp["followers_count"];
        followingCount = resp["following_count"];
      });

      // store locally
      final userProfileSettingsData = {
        "followersCount": followersCount,
        "followingCount": followingCount,
        "favouritesCount": favouritesCount,
      };
      await ss.setPrefItem("userProfileSettingsData", jsonEncode(userProfileSettingsData));
      fetchFavouritesCount(forceRefresh: forceRefresh);
    } catch(e) {}
  }

  Future<void> fetchFavouritesCount({bool forceRefresh = false}) async {
    try {
      // if(!forceRefresh) {
      //   String? getUserProfileSettingsData = await ss.getItem("userProfileSettingsData");
      //   if(getUserProfileSettingsData != null) {
      //     final sd = jsonDecode(getUserProfileSettingsData);
      //     if(!mounted) return;
      //     setState(() {
      //       favouritesCount = sd["favouritesCount"] ??= 0;
      //     });
      //     fetchFriendsCount(forceRefresh: forceRefresh);
      //     return;
      //   }
      // }

      final res = await FirebaseFirestore.instance.collection("saved-clubs").where("item_uid", isEqualTo: GeneralUtils().userUid).count().get();
      if(!mounted) return;
      setState(() {
        favouritesCount = res.count ?? 0;
      });
      // fetchFriendsCount(forceRefresh: forceRefresh);
    } catch(e) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider,
        (AuthState? previousState, AuthState newState) {
      if (newState is UnauthenticatedState) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (newState is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 4,
            backgroundColor: Colors.red,
            content: Text(
              newState.message,
              style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    });
    return Scaffold(
      appBar: userType == "club_owner" ? null : AppBar(
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
        title: Text("Profile", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: userType == "club_owner" ? 48: 0),
              Stack(
                children: [
                  imageURL.isEmpty ? const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/images/default_avatar.png")
                  ) :
                  CachedNetworkImage(imageUrl: imageURL, fit: BoxFit.contain, imageBuilder: (c, i) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: i,
                    );
                  },),
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundImage: imageURL.isEmpty
                  //       ? const AssetImage("assets/images/default_avatar.png")
                  //       : NetworkImage(
                  //           imageURL,
                  //         ) as ImageProvider<Object>,
                  // ),
                  uploadInProgress ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(115)),
                    child: const CircularProgressIndicator(
                      color: AppColors.primaryBase,
                    ),
                  ) : Positioned(
                    top: 72,
                    left: 70,
                    child: GestureDetector(
                      child: SvgPicture.asset("assets/svg/edit_square.svg"),
                      onTap: () {
                        selectImage(userData["uid"] ?? "");
                      },
                    ),
                  ),
                  // Container(
                  //   height: 100,
                  //   width: 100,
                  //   decoration: BoxDecoration(
                  //       color: Colors.black.withOpacity(0.5),
                  //       borderRadius: BorderRadius.circular(115)),
                  //   child: uploadInProgress
                  //       ? const CircularProgressIndicator(
                  //           color: AppColors.primaryBase,
                  //         )
                  //       : SizedBox(),
                  // )
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "${userData["first_name"]} ${userData["last_name"]}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 18),
              ),
              const SizedBox(height: 24),
              profileDetails(),
              const SizedBox(height: 24),
              ...profileMenuItems(),
            ],
          ))),
    );
  }

  List<Widget> profileMenuItems() {
    if(userType == "club_owner") {
      return [
        ProfileListTile(
          title: "Account Setup",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/account_setup.svg"),
          leading: Icons.phonelink_setup_outlined,
          showTrailing: true,
          page: "/club_owner_account_setup",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Top Followers",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/top_follower.svg"),
          leading: Icons.people,
          showTrailing: true,
          page: "/top_followers",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        const ProfileListTile(
          title: "Reviews",
          subtitle: "",
          leadingChild: null, // SvgPicture.asset("assets/svg/top_follower.svg"),
          leading: Icons.rate_review_outlined,
          showTrailing: true,
          page: "/club_reviews_overview",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Account Settings",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/settings.svg"),
          leading: Icons.settings,
          showTrailing: true,
          page: "/change_password",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Privacy Policy",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/privacy_policy.svg"),
          leading: Icons.privacy_tip_rounded,
          showTrailing: true,
          page: "/privacy_policy",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Delete Account",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/delete_account.svg"),
          leading: Icons.delete,
          showTrailing: true,
          page: "/delete_account",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
            title: "Log out",
            subtitle: "",
            leadingChild: SvgPicture.asset("assets/svg/logout.svg"),
            leading: Icons.logout_outlined,
            showTrailing: true,
            page: "/donation",
            onPress: logout,
            tileColor: Colors.white,
            borderColor: Colors.white,
            textColor: AppColors.secondaryBase),
      ];
    }
    if(userType == "user") {
      return [
        ProfileListTile(
          title: "Edit Profile",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/edit_profile.svg"),
          leading: Icons.edit,
          showTrailing: true,
          page: "/edit_profile",
          tileColor: Colors.white,
          borderColor: Colors.white,
          onCallback: () {
            getProfileDetails();
          },
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Favorites ($favouritesCount)",
          subtitle: "",
          leadingChild: null, //SvgPicture.asset("assets/svg/favorites.svg"),
          leading: Icons.favorite_outline_rounded,
          showTrailing: true,
          page: "/favourites",
          onPress: () async {
            await Navigator.of(context).pushNamed("/favourites");
            fetchFavouritesCount(forceRefresh: true);
          },
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Account Settings",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/settings.svg"),
          leading: Icons.settings,
          showTrailing: true,
          page: "/change_password",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Invite Friends",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/invite_friends.svg"),
          leading: Icons.people,
          showTrailing: true,
          page: "/invite_friends",
          // onPress: inviteFriends,
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        const ProfileListTile(
          title: "Privacy Settings",
          subtitle: "",
          leadingChild: null,
          leading: Icons.privacy_tip_outlined,
          showTrailing: true,
          page: "/privacy_settings",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Privacy Policy",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/privacy_policy.svg"),
          leading: Icons.privacy_tip_rounded,
          showTrailing: true,
          page: "/privacy_policy",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
          title: "Delete Account",
          subtitle: "",
          leadingChild: SvgPicture.asset("assets/svg/delete_account.svg"),
          leading: Icons.delete,
          showTrailing: true,
          page: "/delete_account",
          tileColor: Colors.white,
          borderColor: Colors.white,
        ),
        const SizedBox(height: 10),
        ProfileListTile(
            title: "Log out",
            subtitle: "",
            leadingChild: SvgPicture.asset("assets/svg/logout.svg"),
            leading: Icons.logout,
            showTrailing: true,
            page: "/donation",
            onPress: logout,
            tileColor: Colors.white,
            borderColor: Colors.white,
            textColor: AppColors.secondaryBase),
      ];
    }
    return [];
  }

  Widget profileDetails() {
    if(userType == "club_owner") {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                livestreamsCount.toString(),
                textAlign: TextAlign.center,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Livestreams",
                textAlign: TextAlign.center,
                style: bodyStyle.copyWith(
                    fontWeight: FontWeight.w400, color: AppColors.grey600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                GeneralUtils().returnFormattedDateDuration(duration.ceil()),
                textAlign: TextAlign.center,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Duration",
                textAlign: TextAlign.center,
                style: bodyStyle.copyWith(
                    fontWeight: FontWeight.w400, color: AppColors.grey600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                GeneralUtils().shortenLargeNumber(num: views),
                textAlign: TextAlign.center,
                style: subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Total Viewers",
                textAlign: TextAlign.center,
                style: bodyStyle.copyWith(
                    fontWeight: FontWeight.w400, color: AppColors.grey600),
              ),
            ],
          ),
        ],
      );
    }
    if(userType == "user") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed("/friends_list", arguments: {"type": "Followers", "uid": GeneralUtils().userUid});
                // fetchFavouritesCount(forceRefresh: true);
                fetchFriendsCount(forceRefresh: true);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    GeneralUtils().shortenLargeNumber(num: followersCount.toDouble()),
                    textAlign: TextAlign.center,
                    style: subHeadingStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "FOLLOWERS",
                        textAlign: TextAlign.center,
                        style: bodyStyle.copyWith(
                            fontWeight: FontWeight.w400, color: AppColors.grey600),
                      ),
                      const Icon(Icons.arrow_right_rounded, color: AppColors.primaryBase,)
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed("/friends_list", arguments: {"type": "Following", "uid": GeneralUtils().userUid});
                  // fetchFavouritesCount(forceRefresh: true);
                  fetchFriendsCount(forceRefresh: true);
                },
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  GeneralUtils().shortenLargeNumber(num: followingCount.toDouble()),
                  textAlign: TextAlign.center,
                  style: subHeadingStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                      fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "FOLLOWING",
                      textAlign: TextAlign.center,
                      style: bodyStyle.copyWith(
                          fontWeight: FontWeight.w400, color: AppColors.grey600),
                    ),
                    const Icon(Icons.arrow_right_rounded, color: AppColors.primaryBase,)
                  ],
                )
              ],
            )),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Future<void> selectImage(String userId) async {
    String  getUser = (await ss.getItem("user"))!;
    dynamic user = jsonDecode(getUser);
    final image = await ref.read(picker).pickImage(ImageSource.gallery);

    if (image != null) {
      File imageFile = await ref.read(imageCropperProvider).compressImage(File(image.path),);
      setState(() {
        uploadInProgress = true;
      });
      String fileUrl = await ref
          .read(profileNotifierProvider.notifier)
          .uploadImage(imageFile, folder: "profile-images");
      setState(() {
        uploadInProgress = false;
        imageURL = fileUrl;
      });
      // saveUserProfile(userId);
      user["picture"] = fileUrl;
      await ss.setPrefItem("user", jsonEncode(user));

      Map<String, dynamic> mUserData = {};
      mUserData["picture"] = fileUrl;
      mUserData["id"] = userId;
      await ref
          .read(updateProfileNotifier.notifier)
          .updateProfile(
          userData: mUserData
      );
    }
  }

  Future<void> logout() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheetMultipleResponses(
              imageName: "",
              title: "Log out",
              subtitle: "Are you sure you want to log out?",
              buttonTitle: "Yes, Log out",
              cancelTitle: "No",
              onPress: () async {
                try {
                  await StorageSystem().clearPref();
                  await ref.read(authNotifierProvider.notifier).signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                } catch(e) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              titleStyle: subHeadingStyle.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.secondaryBase));
        },
        isDismissible: false,
        showDragHandle: true,
        enableDrag: false);
  }
}
