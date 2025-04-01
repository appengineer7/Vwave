
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/utils/storage.dart';
import 'package:vwave/widgets/empty_screen.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';

class TopFollowersPage extends ConsumerStatefulWidget {
  final List<dynamic>? suggestedUsers;
  const TopFollowersPage(this.suggestedUsers, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TopFollowersPage();
}

class _TopFollowersPage extends ConsumerState<TopFollowersPage> {

  StorageSystem ss = StorageSystem();
  List<dynamic> suggestedUsers = [];
  List<dynamic> searchUsers = [];

  final TextEditingController _controller = TextEditingController(text: "");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      searchUsersOnline(_controller.text);
    });

    setState(() {
      suggestedUsers = widget.suggestedUsers ?? [];
    });

    if(suggestedUsers.isEmpty) {
      Future.delayed(Duration.zero, () async {
        await searchUsersOnline("", isSuggestions: true);
      });
    }
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
        title: Text("Top Followers", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
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
                (suggestedUsers.isEmpty && searchUsers.isEmpty && !isLoading) ? EmptyScreen("No followers found", height: 400, imageHeight: 200, textStyle: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),) : const SizedBox(),
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

    return users.map((user) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(16)
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          leading:
          GeneralUserAvatar(
            40.0,
            avatarData: user["picture"],
            userUid: user["id"],
            clickable: false,
          ),
          title: Text("${user["first_name"]} ${user["last_name"]}", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
          onTap: () async {
            // final currentUser = await ref.read(profileRepositoryProvider).fetchMe();
            // if(currentUser != null) {
            //   final conversation = await ref
            //       .read(asyncCreateConversationProvider.notifier)
            //       .createOrGetConversation(
            //       currentUser.id!,
            //       user["id"],
            //       '${currentUser.firstName} ${currentUser.lastName}',
            //       "${user["first_name"]} ${user["last_name"]}",
            //       user["picture"]
            //   );
            //   Navigator.of(context).pushNamed('/chat', arguments: conversation);
            // }
          },
        ),
      );
    }).toList();
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

    String url = "getfollowers?user_uid=${GeneralUtils().userUid}&user_type=club&q=${_controller.text}";

    if(isSuggestions) {
      url = "getfollowers?user_uid=${GeneralUtils().userUid}&user_type=club";
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
        suggestedUsers = data.map((e) => e).toList();
      } else {
        searchUsers = data.map((e) => e).toList();
      }
      isLoading = false;
    });

    if(searchUsers.isEmpty && !isSuggestions) {
      GeneralUtils.showToast("No user found");
    }
  }
}