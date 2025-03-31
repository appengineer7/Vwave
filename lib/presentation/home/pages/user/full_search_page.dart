
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave/widgets/action_button.dart';

import '../../../../utils/general.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../../widgets/user_avatar.dart';
import '../../../club/models/club.dart';
import '../../../club/providers/club_notifier_provider.dart';
import '../../../club/widgets/club_horizontal_display.dart';
import '../../../club/widgets/club_vertical_display.dart';

class FullSearchPage extends ConsumerStatefulWidget {
  const FullSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FullSearchPageState();
}

class _FullSearchPageState extends ConsumerState<FullSearchPage> {

  final dio = Dio();
  List<dynamic> searchUsers = [];
  final TextEditingController _controller = TextEditingController(text: "");
  bool isLoading = false;

  List<Club> clubs = [];
  String selectedLayout = "horizontal";
  String selectedOption = "Users";

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if(selectedOption == "Clubs") {
        searchClubsOnline(_controller.text);
        return;
      }
      searchUsersOnline(_controller.text);
    });
    searchClubsOnline("");
  }

  @override
  Widget build(BuildContext context) {
    // final clubState = ref.watch(clubNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: SearchFieldWidget(_controller),
        toolbarHeight: 100,
      ),
      body: GestureDetector(
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        searchOptionBuilder("Users"),
                        const SizedBox(width: 5,),
                        searchOptionBuilder("Clubs"),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(getSearchHeaderText(), style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500),),
                        (selectedOption == "Users") ? const SizedBox() : const SizedBox(width: 10,),
                        (selectedOption == "Users") ? const SizedBox() : GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedLayout = "horizontal";
                            });
                          },
                          child: (selectedLayout == "horizontal") ? SvgPicture.asset("assets/svg/horizontal_list_selected.svg") : SvgPicture.asset("assets/svg/horizontal_list.svg"),
                        ),
                        (selectedOption == "Users") ? const SizedBox() : const SizedBox(width: 10,),
                        (selectedOption == "Users") ? const SizedBox() : GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedLayout = "vertical";
                            });
                          },
                          child: (selectedLayout == "vertical") ? SvgPicture.asset("assets/svg/vertical_list_selected.svg") : SvgPicture.asset("assets/svg/vertical_list.svg"),
                        )
                      ],
                    )
                  ],
                ),
                isLoading ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/2,
                    child: const Center(
                  child: CircularProgressIndicator(),
                )) : (searchUsers.isEmpty && selectedOption == "Users") ? emptySearchResult() : (clubs.isEmpty && selectedOption == "Clubs") ? emptySearchResult() : const SizedBox(),
                if(selectedOption == "Clubs")
                  ...displaySearchResultForClubs(),
                if(selectedOption == "Users")
                  ...displaySearchResultsForUsers()
                // SizedBox(height: suggestedUsers.isNotEmpty ? 20 : 0,),
                // (suggestedUsers.isEmpty && searchUsers.isEmpty && !isLoading) ? EmptyScreen("No followers found", height: 400, imageHeight: 200, textStyle: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),) : const SizedBox(),
                // ...displaySearchResults(),
                // !isLoading ? const SizedBox() : const Center(
                //   child: CircularProgressIndicator(),
                // )
              ],
            ),
          ),
        ),
      )),
    );
  }

  String getSearchHeaderText() {
    if(selectedOption == "Clubs") {
      return "${clubs.length} ${clubs.length <= 1 ? "club" : "clubs"} found";
    }
    return "${searchUsers.length} ${searchUsers.length <= 1 ? "user" : "users"} found";
  }

  Widget searchOptionBuilder(String title) {
    return SizedBox(
      width: 80,
      height: 40,
      child: ActionButton(
        text: title,
        onPressed: (){
          setState(() {
            selectedOption = title;
          });
          if(_controller.text.length < 3) {
            return;
          }
        },
        backgroundColor: Colors.transparent,
        foregroundColor: selectedOption == title ? AppColors.primaryBase : AppColors.grey900,
        borderSide: BorderSide(color: selectedOption == title ? AppColors.primaryBase : AppColors.grey200),
        borderRadius: 100,
        padding: const EdgeInsets.all(5),
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
          Text("Not Found", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          Text("Sorry, the keyword you entered cannot be found, please check again or search with another keyword.", textAlign: TextAlign.center, style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
          // GestureDetector(
          //   onTap: (){
          //     Navigator.of(context)
          //         .pushReplacementNamed("/clubs_near", arguments: clubState.clubs);
          //   },
          //   child: Text(" Tap here to change location",
          //     style: bodyStyle.copyWith(
          //         color: AppColors.primaryBase, fontWeight: FontWeight.w700),
          //   ),
          // )
        ],
      ),
    );
  }

  List<Widget> displaySearchResultForClubs() {
    if(selectedLayout == "vertical") {
      return [GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 4.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
        itemCount: clubs.length, itemBuilder: (context, index) {
          return ClubVerticalDisplay(clubs[index], showReviews: true, width: 0, marginRight: 0,);
        },
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
      )];
    }
    return clubs.map((club) => ClubHorizontalDisplay(club, showReviews: true, width: MediaQuery.of(context).size.width,)).toList();
  }

  List<Widget> displaySearchResultsForUsers() {
    if(isLoading) {
      return [];
    }

    List<dynamic> users = searchUsers;

    return users.map((user) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        leading:
        SizedBox(
          width: 40,
          height: 40,
          child: GeneralUserAvatar(
            40.0,
            avatarData: user["picture"],
            userUid: user["id"],
            clickable: false,
          ),
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
        },
      );
    }).toList();
  }

  Future<void> searchClubsOnline(String q) async {
    final getClubs = ref.read(clubNotifierProvider).clubs;
    if(q.isEmpty) {
      setState(() {
        clubs = getClubs;
      });
      return;
    }
    if(_controller.text.length < 3) {
      return;
    }
    final findLocally = clubs = getClubs.where((club) => club.clubName.toLowerCase().contains(q.toLowerCase())).toList();
    if(findLocally.isNotEmpty) {
      setState(() {
        clubs = findLocally;
      });
      return;
    }
    // setState(() {
    //   clubs = getClubs.where((club) => club.clubName.toLowerCase().contains(q.toLowerCase())).toList();
    // });
    setState(() {
      isLoading = true;
    });

    String url = "https://${dotenv.env['AGOLIA_APP_ID']}-dsn.algolia.net/1/indexes/${dotenv.env['AGOLIA_CLUB_INDEX']}/query";

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
      // GeneralUtils.showToast("No clubs found");
      return;
    }

    final resp = res.data;

    if(resp["hits"] == null) {
      setState(() {
        isLoading = false;
      });
      // GeneralUtils.showToast("No clubs found");
      return;
    }

    List<dynamic> data = resp["hits"];

    if(!mounted) return;
    setState(() {
      clubs = data.where((c) => c["verified"]).map((d) => Club.fromJson(d)).toList();
      isLoading = false;
    });
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
      // GeneralUtils.showToast("No users found");
      return;
    }

    final resp = res.data;

    if(resp["hits"] == null) {
      setState(() {
        isLoading = false;
      });
      // GeneralUtils.showToast("No users found");
      return;
    }

    List<dynamic> data = resp["hits"];

    List<dynamic> sortedUser = [];
    for (var d in data) {
      bool allowSearchVisibility = d["allow_search_visibility"] ?? true;
      String userType = d["user_type"] as String;
      String uid = d["id"] as String;
      if(allowSearchVisibility) {
        if(userType == "user" && uid != GeneralUtils().userUid) {
          sortedUser.add(d);
        }
      }
    }

    if(!mounted) return;
    setState(() {
      searchUsers = sortedUser; //data.where((d) => d["allow_search_visibility"] ??= true && d["user_type"] == "user" && d["id"] != GeneralUtils().userUid).map((e) => e).toList();
      isLoading = false;
    });

    // if(searchUsers.isEmpty) {
    //   GeneralUtils.showToast("No user found");
    // }
  }

}