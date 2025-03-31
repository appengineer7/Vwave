import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:vwave_new/presentation/stories/providers/story_notifier_provider.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';

class VideoDisplayWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final String type;
  final Function(VideoPlayerController controller) onVideoPlayerController;

  const VideoDisplayWidget(this.videoUrl,
      {super.key,
      this.thumbnailUrl = "",
      this.type = "file",
      required this.onVideoPlayerController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoDisplayWidget();
}

class _VideoDisplayWidget extends ConsumerState<VideoDisplayWidget> {
  VideoPlayerController? _videoPlayerController;

  // bool isPlaying = false;

  // late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // print(widget.aspectRatio);
    // print(16/9);
    if (widget.type == "file") {
      _videoPlayerController =
          VideoPlayerController.file(File(widget.videoUrl));
      afterVideoInitialized();
    } else {
      Future.delayed(Duration.zero, () async {
        final fileInfo = await ref
            .read(storyNotifierProvider.notifier)
            .fetchCachedFile(widget.videoUrl);
        if (fileInfo == null) {
          print("fileInfo.file.path is null");
          _videoPlayerController =
              VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
          print(widget.videoUrl);
          // compute(initializeCacheDownloader, widget.videoUrl);
        } else {
          print(fileInfo.file.path);
          _videoPlayerController =
              VideoPlayerController.contentUri(Uri.file(fileInfo.file.path));
        }
        afterVideoInitialized();
      });
    }

    // _chewieController = ChewieController(
    //     videoPlayerController: _videoPlayerController,
    //     autoInitialize: false,
    //     autoPlay: false,
    //     looping: false,
    //     allowMuting: true,
    //     showControls: false,
    //     showControlsOnInitialize: false,
    //     allowedScreenSleep: true,
    //     fullScreenByDefault: false,
    //     allowFullScreen: true,
    //     // errorBuilder: (context, errorMessage) {
    //     //   return ImageDisplayWidget(widget.thumbImage, null);
    //     // }
    //     );

    // widget.onVideoPlayerController(_videoPlayerController);
    //
    // _videoPlayerController.addListener(() {
    //   if (!mounted) return;
    //   setState(() {});
    // });
    // _videoPlayerController.setLooping(true);
    // _videoPlayerController.initialize().then((_) {
    //   if (!mounted) return;
    //   setState(() {});
    // });
    // if (widget.type == "file") {
    //   _videoPlayerController.play();
    // }

    // Future.delayed(const Duration(seconds: 1), () {
    // _chewieController.enterFullScreen();
    // _chewieController.exitFullScreen();
    // if(!_videoPlayerController.value.isPlaying) {
    //   _videoPlayerController.play();
    // }
    // _chewieController.notifyListeners();
    // _chewieController.enterFullScreen();
    // _chewieController.exitFullScreen();
    // });
    // _videoPlayerController.addListener(() async {
    //   if(_videoPlayerController.value.isPlaying) {
    //     await _videoPlayerController.pause();
    //     await _videoPlayerController.play();
    //     setState(() {
    //
    //     });
    //   }
    // });
  }

  void afterVideoInitialized() {
    if (_videoPlayerController == null) {
      return;
    }
    // widget.onVideoPlayerController(_videoPlayerController!);

    _videoPlayerController!.addListener(() {
      if (!mounted) return;
      setState(() {});
      // if(widget.type == "network") {
      //   if(_videoPlayerController!.value.isInitialized) {
      //     if(_videoPlayerController!.value.position.inMilliseconds == _videoPlayerController!.value.duration.inMilliseconds) {
      //       _videoPlayerController!.dispose();
      //     }
      //   }
      // }
    });
    if(widget.type == "file") {
      _videoPlayerController!.setLooping(true);
    }
    _videoPlayerController!.initialize().then((_) {
      widget.onVideoPlayerController(_videoPlayerController!);
      if (!mounted) return;
      setState(() {});
    });
    if (widget.type == "file") {
      _videoPlayerController!.play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    // _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () {
          if (widget.type == "network") {
            return;
          }
          if (_videoPlayerController!.value.isPlaying) {
            _videoPlayerController!.pause();
          } else {
            _videoPlayerController!.play();
          }
        },
        child: displayView(),
        // (_videoPlayerController == null)
        //     ? const SizedBox()
        //     : (_videoPlayerController!.value.isInitialized)
        //         ? AspectRatio(
        //             aspectRatio: _videoPlayerController!.value.aspectRatio,
        //             child: VideoPlayer(_videoPlayerController!))
        //         : Stack(children: [
        //             (widget.thumbnailUrl.isNotEmpty)
        //                 ? CachedNetworkImage(
        //                     fit: BoxFit.contain,
        //                     imageUrl: widget.thumbnailUrl,
        //                     errorWidget: (context, url, error) =>
        //                         const Icon(Icons.error),
        //                   )
        //                 : const SizedBox(),
        //             const Center(
        //                 child: CircularProgressIndicator(
        //               backgroundColor: AppColors.grey50,
        //               valueColor: AlwaysStoppedAnimation<Color>(
        //                   AppColors.secondaryBase),
        //             ))
        //           ]),
      ),
    );
  }

  Widget displayView() {
    if (_videoPlayerController == null) {
      return const SizedBox();
    }

    if (_videoPlayerController!.value.isInitialized) {
      return AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController!));
    }

    return Stack(
      children: [
        (widget.thumbnailUrl.isNotEmpty)
            ? CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: widget.thumbnailUrl,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const SizedBox(),
        const Center(
            child: CircularProgressIndicator(
          backgroundColor: AppColors.grey50,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
        ))
      ],
    );
  }
}
