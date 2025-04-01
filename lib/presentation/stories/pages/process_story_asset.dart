
import 'dart:convert';
import 'dart:io';

import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vwave/utils/general.dart';
import 'package:vwave/widgets/styles/app_colors.dart';
import 'package:vwave/widgets/styles/text_styles.dart';

import '../../../../services/image_upload.dart';
import '../../../../utils/storage.dart';
import '../../../../widgets/image_display_widget.dart';
import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/video_display_widget.dart';
import '../models/story.dart';

class ProcessStoryPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> storyAsset;
  const ProcessStoryPage(this.storyAsset, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProcessStoryPageState();
}

class _ProcessStoryPageState extends ConsumerState<ProcessStoryPage> {

  // Inialize controllers within the state
  // FlutterStoryEditorController controller = FlutterStoryEditorController();
  // final TextEditingController _captionController = TextEditingController();
  StorageSystem ss = StorageSystem();
  late VideoPlayerController _videoPlayerController;

  late String filePath;

  bool isVideoCompressing = false;
  bool isUploadingStory = false;

  // MediaInfo? mediaInfo;
  final videoInfo = FlutterVideoInfo();
  VideoData? mediaInfo;

  late Map<String, dynamic> userData;

  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    filePath = widget.storyAsset["file"];
    getUserData();
    if(widget.storyAsset["type"] == "video") {
      setState(() {
        isVideoCompressing = true;
      });
      compressVideo();
      return;
    }
  }

  Future<void> getUserData() async {
    String? user = await ss.getItem("user");
    if (user == null) {
      return;
    }
    userData = jsonDecode(user);
  }

  Future<void> compressVideo() async {
    // mediaInfo = await VideoCompress.compressVideo(
    //   widget.storyAsset["file"],
    //   quality: VideoQuality.DefaultQuality,
    //   deleteOrigin: false, // It's false by default
    // );
    // if(mediaInfo == null) {
    //   return;
    // }
    // if(mediaInfo?.path == null) {
    //   return;
    // }
    // print("start time = ${DateTime.now().toString()}");
    mediaInfo = await videoInfo.getVideoInfo(widget.storyAsset["file"]);
    // print("end time = ${DateTime.now().toString()} ${mediaInfo?.duration}");
    setState(() {
      filePath = widget.storyAsset["file"]; //mediaInfo!.path!;
      isVideoCompressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Padding(padding: const EdgeInsets.only(left: 24), child: NavBackButton(
          color: Colors.white,
          icon: const Icon(Icons.close_rounded, color: Colors.white,),
          onPress: () {
            Navigator.of(context).pop();
          },
        ),),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 24), child: FilledButton(onPressed: sendStory, style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), shape:
          WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
                side: const BorderSide(color: Colors.white)
            ),
          ),), child: Text("Send", style: bodyStyle.copyWith(color: Colors.white),),),)
        ],
      ),
      body: (isVideoCompressing) ? const Center(child: CircularProgressIndicator(backgroundColor: AppColors.grey50, valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),),) :
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            (widget.storyAsset["type"] == "video") ? VideoDisplayWidget(filePath, onVideoPlayerController: (controller) { //aspectRatio: mediaInfo!.width! / mediaInfo!.height!
              _videoPlayerController = controller;
            },) :
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.file(File(filePath), fit: BoxFit.contain,),
            ),
            showOverlayProgressBar()
          ],
        ),
      )
    );
  }

  Widget showOverlayProgressBar() {
    if(!isUploadingStory) {
      return const SizedBox();
    }
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5)
          ),
        ),
        Center(
          // alignment: Alignment.center,
          child: Stack(
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: (uploadProgress == 0) ? const CircularProgressIndicator(
                  backgroundColor: AppColors.grey50,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
                ) : CircleProgressBar(
                  foregroundColor: AppColors.secondaryBase,
                  backgroundColor: AppColors.grey50,
                  value: uploadProgress,
                  child: AnimatedCount(
                    count: uploadProgress,
                    duration: const Duration(milliseconds: 500),
                    unit: '',
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 18,
                child: Text("${(uploadProgress * 100).ceil()}%", style: captionStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<String> uploadVideoThumbnail() async {
    GeneralUtils.showToast("Preparing upload...");
    // get thumbnail image from video
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: filePath,
        imageFormat: ImageFormat.PNG,
        quality: 100
    );
    if(thumbnailPath == null) {
      return "";
    }
    String thumbnailUrl = await ref.read(imageUploadService).uploadFileToStorage(File(thumbnailPath), folder: "thumbnail-images");
    return thumbnailUrl;
  }

  Future<void> sendStory() async {
    try {
      if(widget.storyAsset["type"] == "video") {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
        }
      }

      setState(() {
        isUploadingStory = true;
      });

      // check if user has already uploaded a story
      final checkStory = await FirebaseFirestore.instance.collection("stories")
          .doc(GeneralUtils().userUid)
          .get();

      if (checkStory.exists) {
        final storyFeed = StoryFeed.fromDocument(checkStory);
        final today = DateTime.now(); //.toString().split(" ").first;
        // final storyCreatedDate = storyFeed.createdDate!.split(" ").first;
        final lastStoryCreatedDate = DateTime.parse(storyFeed.files.last["created_date"]);
        final difference = today.difference(lastStoryCreatedDate).inHours;
        // if(today == storyCreatedDate) {
        if(difference < 24) {
          await updateStory(storyFeed);
        } else {
          await uploadStory();
        }
        return;
      }
      await uploadStory();
    } catch(e) {
      setState(() {
        isUploadingStory = false;
      });
      final snackBar = SnackBar(
        content: Text("Could not upload story. Please try again.", style: titleStyle.copyWith(color: Colors.white),),
        duration: const Duration(seconds: 5),
        backgroundColor: AppColors.secondaryBase,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

  Future<void> uploadStory() async {

    String thumbnailUrl = "";

    if(widget.storyAsset["type"] == "video") {
      thumbnailUrl = await uploadVideoThumbnail();
    }

    String url = await ref.read(imageUploadService).uploadFileToStorage(File(filePath), folder: "stories", onUploading: (progress) {
      setState(() {
        uploadProgress = progress / 100;
      });
    });

    final userLocationDetails = GeneralUtils().getLocationDetailsData(userData["location_details"]);

    String timeZone = await GeneralUtils().currentTimeZone();

    String fileId = FirebaseFirestore.instance.collection("stories").doc().id;

    final story = StoryFeed(
        id: GeneralUtils().userUid,
        userUid: GeneralUtils().userUid ?? "",
        firstName: userData["first_name"],
        lastName: userData["last_name"],
        previewTitle: {
          "en": userData["first_name"]
        },
        previewImage: userData["picture"],
        files: [
          {
            "id": fileId,
            "created_date": DateTime.now().toString(),
            "duration": widget.storyAsset["type"] == "image" ? 0 : (mediaInfo == null) ? 0 : mediaInfo!.duration!.ceil(),
            "file_caption": {
              "en": ""
            },
            "filetype": widget.storyAsset["type"],
            "url": url,
            "thumbnailUrl": thumbnailUrl
          }
        ],
        locationDetails: userLocationDetails,
        otherDetails: {
          "allow_conversations": userData["allow_conversations"] ?? "allow",
        },
        viewsCount: {
          fileId: 0,
        },
        timeZone: timeZone,
        storyPrivacy: userData["story_privacy"] ?? "everyone",
        allowedUid: [],
        timestamp: FieldValue.serverTimestamp(),
        createdDate: DateTime.now().toString(),
        modifiedDate: DateTime.now().toString(),
    );

    await FirebaseFirestore.instance.collection("stories").doc(GeneralUtils().userUid).set(story.toJson());

    leavePage();
  }

  Future<void> updateStory(StoryFeed storyFeed) async {

    String timeZone = await GeneralUtils().currentTimeZone();

    String thumbnailUrl = "";

    if(widget.storyAsset["type"] == "video") {
      thumbnailUrl = await uploadVideoThumbnail();
    }

    String url = await ref.read(imageUploadService).uploadFileToStorage(File(filePath), folder: "stories", onUploading: (progress) {
      if(progress < 0 || progress.isNaN) {
        return;
      }
      setState(() {
        uploadProgress = progress / 100;
      });
    });

    String fileId = FirebaseFirestore.instance.collection("stories").doc().id;

    final storyFile = {
      "id": fileId,
      "created_date": DateTime.now().toString(),
      "duration": widget.storyAsset["type"] == "image" ? 0 : (mediaInfo == null) ? 0 : mediaInfo!.duration!.ceil(),
      "file_caption": {
        "en": ""
      },
      "filetype": widget.storyAsset["type"],
      "url": url,
      "thumbnailUrl": thumbnailUrl
    };

    await FirebaseFirestore.instance.collection("stories").doc(GeneralUtils().userUid).update({
      "timestamp": FieldValue.serverTimestamp(),
      "story_privacy": userData["story_privacy"] ?? "everyone",
      "modified_date": DateTime.now().toString(),
      "first_name": userData["first_name"],
      "last_name": userData["last_name"],
      "preview_title": {
        "en": userData["first_name"]
      },
      "preview_image": userData["picture"],
      "other_details": {
        "allow_conversations": userData["allow_conversations"] ?? "allow",
      },
      "views_count.$fileId": 0,
      "time_zone": timeZone,
      "files": FieldValue.arrayUnion([storyFile])
    });

    // delete old ones
    List<Map<String, dynamic>> filesToDelete = [];

    for(var sf in storyFeed.files) {
      final createdDate = DateTime.parse(sf["created_date"]);
      final today = DateTime.now();
      final difference = today.difference(createdDate).inHours;
      if(difference >= 24) {
        filesToDelete.add(sf);
      }
    }

    if(filesToDelete.isNotEmpty) {
      await FirebaseFirestore.instance.collection("stories").doc(GeneralUtils().userUid).update({
        "files": FieldValue.arrayRemove(filesToDelete)
      });
    }

    leavePage();
  }

  void leavePage() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Story uploaded successfully.", style: titleStyle.copyWith(color: Colors.white),),
          duration: const Duration(seconds: 5),
          backgroundColor: AppColors.green,
        )
    );
  }
}