
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';
import 'package:vwave_new/widgets/nav_back_button.dart';
import 'package:vwave_new/widgets/user_avatar.dart';

import '../../../../widgets/empty_screen.dart';
import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';


class SearchEntireUsersPage extends ConsumerStatefulWidget {
  const SearchEntireUsersPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchEntireUsersPage();
}

class _SearchEntireUsersPage extends ConsumerState<SearchEntireUsersPage> {

  final dio = Dio();

  StorageSystem ss = StorageSystem();
  List<dynamic> searchUsers = [];

  final TextEditingController _controller = TextEditingController(text: "");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      searchUsersOnline(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text("Search Users", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
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
                    Text(searchUsers.isNotEmpty ? "Found ${searchUsers.length} ${searchUsers.length <= 1 ? "user" : "users"}" : "", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500),),
                  ],
                ),
                // SizedBox(height: suggestedUsers.isNotEmpty ? 20 : 0,),
                // EmptyScreen("No users found", height: 400, imageHeight: 200, textStyle: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),)
                (searchUsers.isEmpty && !isLoading) ? emptySearchResult() : const SizedBox(),
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

  Widget emptySearchResult() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60,),
          Image.asset("assets/images/empty_livestream.png", height: MediaQuery.of(context).size.height / 2.5,),
          Text("No users found", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          Text("Sorry, the user name you entered cannot be found, please check again or search with another name.", textAlign: TextAlign.center, style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
        ],
      ),
    );
  }

  List<Widget> displaySearchResults() {
    if(isLoading) {
      return [];
    }

    List<dynamic> users = searchUsers;

    return users.map((user) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        leading:
        GeneralUserAvatar(
          40.0,
          avatarData: user["picture"],
          userUid: user["id"],
          clickable: false,
        ),
        title: Text("${user["first_name"]} ${user["last_name"]}", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis,),
        onTap: () async {
          Map<String, dynamic> searchedUserData = {
            "uid": user["id"],
            "first_name": user["first_name"],
            "last_name": user["last_name"],
            "picture": user["picture"],
            "allow_conversations": user["allow_conversations"] ?? "allow",
          };
          Navigator.of(context).pushNamed('/user_profile', arguments: searchedUserData);
          // final allowConversation = await ref.read(profileRepositoryProvider).checkConversationPrivacy(user["allow_conversations"], user["id"]);
          // if(!allowConversation) {
          //   GeneralUtils.showToast("Cannot message this user due to their privacy settings");
          //   return;
          // }
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
          //   Navigator.of(context).pushNamed('/user_profile', arguments: conversation);
          // }
        },
      );
    }).toList();
  }

  Future<void> searchUsersOnline(String query) async {
    if(_controller.text.isEmpty) {
      return;
    }

    if(_controller.text.length < 3) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String url = "https://${dotenv.env['AGOLIA_APP_ID']}-dsn.algolia.net/1/indexes/${dotenv.env['AGOLIA_USER_INDEX']}/query";

    final postBody = {
      "params": "query=${_controller.text.toLowerCase()}&hitsPerPage=50&getRankingInfo=1",
    };

    final postHeaders = {
      "X-Algolia-API-Key": dotenv.env['AGOLIA_API_KEY'] ?? "",
      "X-Algolia-Application-Id": dotenv.env['AGOLIA_APP_ID'] ?? "",
    };

    final res = await dio.post(url, data: postBody, options: Options(headers: postHeaders));

    if(res.statusCode != 200) {
      setState(() {
        isLoading = false;
      });
      GeneralUtils.showToast("No users found");
      return;
    }

    final resp = res.data;

    if(resp["hits"] == null) {
      setState(() {
        isLoading = false;
      });
      GeneralUtils.showToast("No users found");
      return;
    }

    List<dynamic> data = resp["hits"];

    if(!mounted) return;
    setState(() {
      searchUsers = data.where((d) => d["allow_search_visibility"] ??= true && d["user_type"] == "user" && d["id"] != GeneralUtils().userUid).map((e) => e).toList();
      isLoading = false;
    });

    if(searchUsers.isEmpty) {
      GeneralUtils.showToast("No user found");
    }
  }
}