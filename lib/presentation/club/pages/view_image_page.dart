import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:vwave/widgets/nav_back_button.dart';

import '../../../widgets/styles/app_colors.dart';

class ViewImagePage extends StatefulWidget {
  final Map<String, dynamic> galleryData;
  const ViewImagePage(this.galleryData, {super.key});

  @override
  State<StatefulWidget> createState() => _ViewImagePage();
}

class _ViewImagePage extends State<ViewImagePage> {
  // final _key = GlobalKey();
  // bool isVideoView = true;

  VideoPlayerController? _videoPlayerController;
  // bool isPlaying = false;
  // late ChewieController _chewieController;

  // int count = 0;

  // final MediaInfo _mediaInfo = MediaInfo();

  List<dynamic> galleryMedia = [];
  late PageController pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        pageController =
            PageController(initialPage: widget.galleryData["index"]);
        galleryMedia = widget.galleryData["media"];
        currentIndex = widget.galleryData["index"];
      });
      if (galleryMedia[currentIndex]["fileType"] == "video") {
        initVideo();
      }
    });
    // double? aspectRatio = _key.currentContext?.size?.aspectRatio;
    // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.galleryData["url"]));
    // _chewieController = ChewieController(
    //     videoPlayerController: _videoPlayerController,
    //     aspectRatio: aspectRatio,
    //     autoInitialize: true,
    //     autoPlay: false,
    //     looping: false,
    //     allowMuting: true,
    //     showControls: false,
    //     showControlsOnInitialize: false,
    //     allowedScreenSleep: true,
    //     placeholder: const Center(
    //       child: CircularProgressIndicator(),
    //     )
    //     // errorBuilder: (context, errorMessage) {
    //     //   return ImageDisplayWidget(widget.galleryData["thumbnailUrl", null);
    //     // }
    //     );
  }

  Future<void> initVideo() async {
    if (_videoPlayerController != null) {
      _videoPlayerController?.dispose();
      setState(() {
        _videoPlayerController = null;
      });
    }
    // final storage = GetStorage('cached_video_player');
    // await storage.initStorage;

    String url =
        galleryMedia[currentIndex]["url"]; // widget.galleryData["url"];
    String fileName = url.split("?").first.split("%2F").last;

    var fileInfo = await FirebaseCacheManager().getSingleFile("/gallery/$fileName");
    _videoPlayerController = VideoPlayerController.file(File(fileInfo.path));

    // check for compressed video file
    // final videoLocalFile = storage.read(fileName);

    // if (videoLocalFile == null) {
    //   var fileInfo = await FirebaseCacheManager().getSingleFile("/gallery/$fileName");
    //   _videoPlayerController = VideoPlayerController.file(File(fileInfo.path));
    //   storage.write(fileName, fileInfo.path);
    //   // if(Platform.isAndroid) {
    //   //   final mediaInfo = await VideoCompress.compressVideo(
    //   //     fileInfo.path,
    //   //     quality: VideoQuality.DefaultQuality,
    //   //     deleteOrigin: false, // It's false by default
    //   //   );
    //   //   print("compressed video path is ${mediaInfo!.path!}");
    //   //   _videoPlayerController = VideoPlayerController.file(File(mediaInfo.path!));
    //   //   storage.write(fileName, mediaInfo.path!);
    //   // }
    //   // if(Platform.isIOS) {
    //   //   final videoFile = File.fromUri(uri);
    //   //   final value = await videoFile.readAsBytes();
    //   //   final bytes = Uint8List.fromList(value);
    //   //   String pathToFile = fileInfo.path.replaceAll(".bin", "-VIDEO_${DateTime.now().millisecondsSinceEpoch}.mp4");
    //   //   var savedVideoFile = await FirebaseCacheManager().putFile(pathToFile, bytes, fileExtension: "mp4");
    //   //   print("compressed video path is $pathToFile");
    //   //   _videoPlayerController = VideoPlayerController.file(savedVideoFile);
    //   //   storage.write(fileName, pathToFile);
    //   // }
    // } else {
    //   _videoPlayerController = VideoPlayerController.file(File(videoLocalFile));
    // }

    _videoPlayerController!.addListener(() async {
      if (!mounted) return;
      setState(() {});
    });

    _videoPlayerController!.setLooping(true);
    _videoPlayerController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
    _videoPlayerController!.play();
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController?.dispose();
    }
    // _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsets.only(left: 24),
            child: NavBackButton(
              color: Colors.white,
            ),
          )),
      body: SafeArea(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: galleryMedia.isEmpty
                ? const SizedBox()
                : PageView.builder(
                itemCount: galleryMedia.length,
                controller: pageController,
                scrollDirection: Axis.vertical,
                pageSnapping: true,
                onPageChanged: (i) {
                  setState(() {
                    currentIndex = i;
                  });
                  if (galleryMedia[currentIndex]["fileType"] == "video") {
                    initVideo();
                    return;
                  }
                  if (_videoPlayerController != null) {
                    _videoPlayerController?.dispose();
                    setState(() {
                      _videoPlayerController = null;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return displayView();
                })
          // Center(
          //   child: Stack(
          //     children: [
          //       ,
          //       // (widget.galleryData["fileType"] == "video") ? GestureDetector(
          //       //   onTap: () {
          //       //     setState(() {
          //       //       isVideoView = true;
          //       //       _chewieController.play();
          //       //       // if(count > 0){
          //       //       //
          //       //       // }
          //       //       count++;
          //       //     });
          //       //   },
          //       //   child: const Align(
          //       //     alignment: Alignment.center,
          //       //     child: Icon(Icons.play_arrow_rounded, size: 128, color: AppColors.primaryBase, shadows: [Shadow(color: Colors.white, blurRadius: 10.5, offset: Offset(0, 0))],),
          //       //   ),
          //       // ) : const SizedBox(),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }

  Widget displayView() {
    if (galleryMedia[currentIndex]["fileType"] == "video") {
      if (_videoPlayerController == null) {
        return loadingVideoView();
      }
      if (_videoPlayerController!.value.isInitialized) {
        return GestureDetector(
          onTap: () {
            if (_videoPlayerController!.value.isPlaying) {
              _videoPlayerController!.pause();
            } else {
              _videoPlayerController!.play();
            }
          },
          child: AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          ),
        );
      }
      return loadingVideoView();
      // return const Center(child: CircularProgressIndicator(),);
    }
    // widget.galleryData["fileType"] == "video" ? widget.galleryData["thumbnailUrl"] :
    return CachedNetworkImage(
      fit: BoxFit.contain,
      imageUrl: galleryMedia[currentIndex]["url"],
      placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
        backgroundColor: AppColors.grey50,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
      )),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget loadingVideoView() {
    return Stack(
      children: [
        CachedNetworkImage(
          fit: BoxFit.contain,
          imageUrl: galleryMedia[currentIndex]["thumbnailUrl"],
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        const Center(
          child: CircularProgressIndicator(
            backgroundColor: AppColors.grey50,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
          ),
        )
      ],
    );
  }
}
