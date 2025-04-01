
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:vwave/presentation/stories/pages/view_story_page.dart';

import '../models/story.dart';
import '../providers/story_notifier_provider.dart';

class StoriesSwipeViewPage extends ConsumerStatefulWidget {
  final StoryFeed storyFeed;
  const StoriesSwipeViewPage(this.storyFeed, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoriesSwipeViewPageState();
}

class _StoriesSwipeViewPageState extends ConsumerState<StoriesSwipeViewPage> {

  StoryFeed? storyFeed;
  int currentStoryFeedIndex = 0;

  List<StoryFeed> stories = [];
  bool initializedState = false;

  PageController? _pageController;
  // VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    setState(() {
      storyFeed = widget.storyFeed;
    });
  }

  @override
  void dispose() {
    // if(videoController != null) {
    //   print("destroyed ==========================2222222222222222222222222222");
    //   videoController!.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyNotifierProvider);
    if(!initializedState) {
      initializedState = true;
      stories = storyState.storyFeed;
      currentStoryFeedIndex = stories.indexOf(storyFeed!);
      _pageController = PageController(initialPage: currentStoryFeedIndex);
      // print("cs is $currentStoryFeedIndex");
    }
    // print("currentStoryFeedIndex is $currentStoryFeedIndex");
    // return Dismissible(
    //     key: const Key("swipe_view"),
    //     // direction: DismissDirection.down,
    //     onDismissed: (direction) {
    //       print(direction.name);
    //       if(direction == DismissDirection.startToEnd) {
    //         // previous story
    //         if(currentStoryFeedIndex == 0 || (currentStoryFeedIndex - 1) < 0) {
    //           Navigator.of(context).pop();
    //           return;
    //         }
    //         setState(() {
    //           storyFeed = stories[currentStoryFeedIndex - 1];
    //           currentStoryFeedIndex--;
    //         });
    //       } else if ( direction == DismissDirection.endToStart) {
    //         // next story
    //         if(currentStoryFeedIndex == (stories.length - 1) || (currentStoryFeedIndex + 1) > (stories.length -1)) {
    //           Navigator.of(context).pop();
    //           return;
    //         }
    //         storyFeed = stories[currentStoryFeedIndex + 1];
    //         currentStoryFeedIndex++;
    //       } else if(direction == DismissDirection.up) {
    //         // next
    //       } else if(direction == DismissDirection.down) {
    //         // previous story
    //
    //       }
    //     },
    //     child: Scaffold(
    //       body: storyFeed == null ? const SizedBox() : ViewStoryPage(storyFeed!),
    //     )
    // );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _pageController == null ? const SizedBox() : PageView.builder(
            controller: _pageController,
            itemCount: stories.length,
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            onPageChanged: (i) {
              // if(videoController != null) {
              //   videoController!.dispose();
              // }
              setState(() {
                currentStoryFeedIndex = i;
              });
            },
            itemBuilder: (context, index) {
              return SizedBox(
                key: UniqueKey(),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ViewStoryPage(
                    key: UniqueKey(), stories[index], onStoryViewEnded: (){
                      if(!mounted) return;
                      if(index == stories.length - 1) {
                        Navigator.of(context).pop();
                        return;
                      }
                      setState(() {
                        _pageController?.jumpToPage(index + 1);
                      });
                }, onVideoInitialized: (controller) {
                  // if(videoController != null) {
                  //   print("destroyed ==========================33333333333333");
                  //   videoController!.dispose();
                  // }
                  // videoController = controller;
                },),
              );
            }),
      ),
    );
  }
}