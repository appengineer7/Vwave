
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vwave/presentation/stories/models/story.dart';
import 'package:vwave/presentation/stories/providers/story_notifier_provider.dart';
import 'package:vwave/widgets/user_avatar.dart';

import '../../../widgets/styles/app_colors.dart';
import '../../../widgets/styles/text_styles.dart';

class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      if(!mounted) return;
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final storyState = ref.watch(storyNotifierProvider);

    return (storyState.loading || storyState.storyFeed.isEmpty) ? const SizedBox() :
    (prefs == null) ? const SizedBox() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24,
          ),
          Text("Stories 📸", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 110,
            child: ListView.builder(
                itemCount: storyState.storyFeed.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  StoryFeed storyFeed = storyState.storyFeed[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.of(context).pushNamed("/view_story", arguments: storyFeed);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: checkStoryViewed(storyFeed) ? AppColors.grey600 : AppColors.secondaryBase, width: 3)
                                ),
                              ),
                              Center(
                                // alignment: Alignment.center,
                                child: GeneralUserAvatar(60, avatarData: storyFeed.previewImage,),
                              )
                            ],
                          ),
                        ),
                        Center(child: Text(storyFeed.previewTitle["en"], textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.titleTextColor),),)
                      ],
                    ),
                  );
                }),
          ),
        ],
      );
    // );
  }

  bool checkStoryViewed(StoryFeed story) {
    List<bool> listViewedMedia = [];
    for (var file in story.files) {
      bool getViewed = hasViewedStory(story.id!, file["id"]);
      listViewedMedia.add(getViewed);
    }
    return !listViewedMedia.contains(false);
  }

  bool hasViewedStory(String storyId, String mediaId) {
    return prefs!.getBool("$storyId/$mediaId") ?? false;
  }
}