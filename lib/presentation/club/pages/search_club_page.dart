
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vwave/presentation/club/providers/club_notifier_provider.dart';

import '../../../widgets/nav_back_button.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';
import '../models/club.dart';
import '../widgets/club_horizontal_display.dart';
import '../widgets/club_vertical_display.dart';

class SearchClubPage extends ConsumerStatefulWidget{
  final String searchQuery;
  const SearchClubPage(this.searchQuery, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchClubPageState();
}

class _SearchClubPageState extends ConsumerState<SearchClubPage> {

  final TextEditingController _controller = TextEditingController(text: "");

  List<Club> clubs = [];
  String selectedLayout = "horizontal";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _controller.text = widget.searchQuery;
    });

    searchClubs(widget.searchQuery);

    _controller.addListener(() {
      searchClubs(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubNotifierProvider);
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
        title: SearchFieldWidget(_controller),
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // SearchFieldWidget(_controller),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${clubs.length} ${clubs.length <= 1 ? "club" : "clubs"} found", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w500),),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedLayout = "horizontal";
                            });
                          },
                          child: (selectedLayout == "horizontal") ? SvgPicture.asset("assets/svg/horizontal_list_selected.svg") : SvgPicture.asset("assets/svg/horizontal_list.svg"),
                        ),
                        const SizedBox(width: 10,),
                        GestureDetector(
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
                (clubs.isEmpty) ? emptySearchResult(clubState) : const SizedBox(),
                ...displaySearchResult()
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
      ),
    );
  }

  Widget emptySearchResult(clubState) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60,),
          Image.asset("assets/images/empty_livestream.png", height: MediaQuery.of(context).size.height / 2.5,),
          Text("Not Found", style: subHeadingStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          Text("Sorry, the keyword you entered cannot be found, please check again or search with another keyword.", textAlign: TextAlign.center, style: titleStyle.copyWith(color: AppColors.grey700, fontWeight: FontWeight.w400),),
          GestureDetector(
            onTap: (){
              Navigator.of(context)
                  .pushReplacementNamed("/clubs_near", arguments: clubState.clubs);
            },
            child: Text(" Tap here to change location",
              style: bodyStyle.copyWith(
                  color: AppColors.primaryBase, fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> displaySearchResult() {
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

  void searchClubs(String q) {
    final getClubs = ref.read(clubNotifierProvider).clubs;
    if(q.isEmpty) {
      setState(() {
        clubs = getClubs;
      });
      return;
    }
    setState(() {
      clubs = getClubs.where((club) => club.clubName.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }
}