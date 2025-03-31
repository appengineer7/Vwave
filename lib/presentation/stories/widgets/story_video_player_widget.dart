//
// import 'dart:io';
//
// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:vwave/widgets/styles/app_colors.dart';
//
// class StoryVideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//   final String type;
//   final Function(CachedVideoPlayerPlusController controller) onVideoPlayerController;
//
//   const StoryVideoPlayerWidget(this.videoUrl, {super.key, this.type = "file", required this.onVideoPlayerController});
//
//   @override
//   State<StatefulWidget> createState() => _StoryVideoPlayerWidgetState();
// }
//
// class _StoryVideoPlayerWidgetState extends State<StoryVideoPlayerWidget> {
//   // late VideoPlayerController _videoPlayerController;
//   late CachedVideoPlayerPlusController _videoPlayerController;
//
//
//   @override
//   void initState() {
//     super.initState();
//     CachedVideoPlayerPlusController.networkUrl(
//       Uri.parse(
//         widget.videoUrl
//       ),
//       httpHeaders: {
//         'Connection': 'keep-alive',
//       },
//       invalidateCacheIfOlderThan: const Duration(days: 1),
//     );
//     widget.onVideoPlayerController(_videoPlayerController);
//
//     _videoPlayerController.addListener(() {
//       if(!mounted) return;
//       setState(() {});
//     });
//     _videoPlayerController.setLooping(true);
//     _videoPlayerController.initialize().then((_) {
//       if(!mounted) return;
//       setState(() {
//
//       });
//     });
//     _videoPlayerController.play();
//   }
//
//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       key: UniqueKey(),
//       child: (_videoPlayerController.value.isInitialized) ?
//       AspectRatio(
//           aspectRatio: _videoPlayerController.value.aspectRatio,
//           child: CachedVideoPlayerPlus(_videoPlayerController, key: UniqueKey(),)
//       )
//           : const Center(
//           child: CircularProgressIndicator(
//             backgroundColor: AppColors.grey50,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
//           )),
//     );
//   }
//
// }