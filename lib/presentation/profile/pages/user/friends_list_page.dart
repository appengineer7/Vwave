
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/profile/repositories/profile_repository.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../../utils/general.dart';
import '../../../../utils/storage.dart';
import '../../../../widgets/empty_screen.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../../widgets/user_avatar.dart';
import '../../providers/profile_notifier_provider.dart';

class FriendsListPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> friendListType;
  const FriendsListPage(this.friendListType, {super.key});

  @override
  ConsumerState<FriendsListPage> createState() =>
      _FriendsListPageState();
}

class _FriendsListPageState extends ConsumerState<FriendsListPage> {

  StorageSystem ss = StorageSystem();
  List<dynamic> suggestedUsers = [];
  List<dynamic> searchUsers = [];

  final TextEditingController _controller = TextEditingController(text: "");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await searchUsersOnline("", isSuggestions: true);
    });

    _controller.addListener(() {
      searchUsersOnline(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        title: Text(widget.friendListType["type"], style: titleStyle.copyWith(fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SearchFieldWidget(_controller),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(searchUsers.isNotEmpty ? "Found ${searchUsers.length} ${searchUsers.length <= 1 ? "user" : "users"}" : suggestedUsers.isEmpty ? "" : "Suggestions", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500),),
                  ],
                ),
                SizedBox(height: suggestedUsers.isNotEmpty ? 20 : 0,),
                (suggestedUsers.isEmpty && searchUsers.isEmpty && !isLoading) ? EmptyScreen("No user found", height: 400, imageHeight: 200, textStyle: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),) : const SizedBox(),
                ...displaySearchResults(),
                !isLoading ? const SizedBox() : const Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> displaySearchResults() {
    if(isLoading) {
      return [];
    }

    List<dynamic> users = searchUsers.isNotEmpty ? searchUsers : suggestedUsers;
    // users.add(users[0]);

    // if(widget.friendListType == "Followers") {
    //   return users.map((user) {
    //     return ListTile();
    //   }).toList();
    // }

    return users.map((user) {
      // user["isFollowing"] = true;
      // bool isFollowing = (widget.friendListType == "Following") ? true : user["is_mutual"] ?? (widget.friendListType == "Followers") ? false : true;
      return Padding(padding: const EdgeInsets.only(bottom: 40),child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          GeneralUserAvatar(
            60.0,
            avatarData: user["picture"],
            userUid: user["id"],
            clickable: false,
          ),
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${user["first_name"]} ${user["last_name"]}", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
              Container(
                width: 100,
                height: 35,
                margin: const EdgeInsets.only(top: 15),
                child: ActionButton(
                  width: 100,
                  text: user["isFollowing"] ? "Unfollow" : "Follow",
                  padding: const EdgeInsets.all(5),
                  textStyle: captionStyle,
                  borderRadius: 10,
                  backgroundColor: user["isFollowing"] ? AppColors.grey50 : AppColors.primaryBase,
                  foregroundColor: user["isFollowing"] ? AppColors.grey500 : Colors.white,
                  onPressed: () async {
                    bool isFF = user["isFollowing"];
                    setState(() {
                      user["isFollowing"] = !user["isFollowing"];
                    });
                    // print("hello = $isFollowing");
                    await ref.read(profileNotifierProvider.notifier).performFriendRequest(isFF, user["id"]);
                    // print("hello = $isFollowing");
                  },
                ),
              )
            ],
          )
        ],
      ));
    }).toList();
  }

  Future<void> followUser() async {

  }

  Future<void> searchUsersOnline(String query, {bool isSuggestions = false}) async {
    if(!isSuggestions) {
      if(_controller.text.isEmpty) {
        return;
      }

      if(_controller.text.length < 3) {
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    String getType = widget.friendListType["type"] == "Followers" ? "getfollowers" : "getfollowing";

    String url = "$getType?user_uid=${widget.friendListType["uid"]}&user_type=user&q=${_controller.text}"; // GeneralUtils().userUid

    if(isSuggestions) {
      url = "$getType?user_uid=${widget.friendListType["uid"]}&user_type=user"; // GeneralUtils().userUid
    }

    if(widget.friendListType["uid"] != GeneralUtils().userUid) {
      url += "&current_user_uid=${GeneralUtils().userUid}";
    }

    final res = await GeneralUtils().makeRequest(url, {}, method: "get");

    if(res.statusCode != 200) {
      setState(() {
        isLoading = false;
      });
      GeneralUtils.showToast("No user found");
      return;
    }

    final body = jsonDecode(res.body);

    List<dynamic> data = body["data"];


    if(!mounted) return;
    setState(() {
      if(isSuggestions) {
        suggestedUsers = data.map((e) { // (widget.friendListType["type"] == "Following") ? true :
          e["isFollowing"] = e["is_mutual"] ??= (widget.friendListType["type"] == "Followers") ? false : true;
          return e;
        }).toList();
      } else {
        searchUsers = data.map((e) { // (widget.friendListType["type"] == "Following") ? true :
          e["isFollowing"] = e["is_mutual"] ??= (widget.friendListType["type"] == "Followers") ? false : true;
          return e;
        }).toList();
      }
      isLoading = false;
    });

    if(searchUsers.isEmpty && !isSuggestions) {
      GeneralUtils.showToast("No user found");
    }
  }
}