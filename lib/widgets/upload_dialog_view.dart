
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';

import 'multiple_options_bottom_sheet.dart';

class UploadDialogView extends StatefulWidget {
  final Function(Map<String, dynamic> fileUpload) onUploadDone;
  final Function(Map<String, dynamic> fileUpload)? onClear;
  final String uploadMessageText, uploadMessageBodyText, allowedExtensions, folderName;
  final bool allowCropAndCompress, autoRestart, allowImagesAndVideos;
  final double rowLeftWidth;
  final bool allowMultipleOptions;
  const UploadDialogView({super.key, required this.onUploadDone, this.onClear, this.uploadMessageText = "Tap to upload license document", this.uploadMessageBodyText = "PDF, DOC, PNG, or JPG", this.allowedExtensions = "jpg,pdf,doc,png", required this.allowCropAndCompress, this.allowImagesAndVideos = false, this.allowMultipleOptions = false, this.folderName = "business-documents", this.autoRestart = false, this.rowLeftWidth = 0});

  @override
  State<StatefulWidget> createState() => _UploadDialogView();
}

enum UploadFlow { EMPTY, PREPARING, PROGRESS, DONE }

class _UploadDialogView extends State<UploadDialogView> {

  UploadFlow uploadFlow = UploadFlow.EMPTY;

  File? postFile;
  int progressPercentage = 0;
  late String fileDownloadURL;

  final videoInfo = FlutterVideoInfo();
  // final MediaInfo _mediaInfo = MediaInfo();

  int maxVideoDuration = 0;

  Future<void> remoteConfigInit() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'max_video_duration_inMilliseconds': 15999,
      });
      await remoteConfig.fetchAndActivate();
      final current = remoteConfig.getInt("max_video_duration_inMilliseconds");
      setState(() {
        maxVideoDuration = current;
      });
    } catch (e, _) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
  }

  @override
  Widget build(BuildContext context) {
    if(uploadFlow == UploadFlow.EMPTY) {
      return emptyView();
    }
    if(uploadFlow == UploadFlow.PREPARING) {
      return preparingView();
    }
    if(uploadFlow == UploadFlow.PROGRESS) {
      return progressView();
    }
    if(uploadFlow == UploadFlow.DONE) {
      return doneView();
    }
    return emptyView();
  }

  Widget emptyView() {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();

        if(widget.allowMultipleOptions) {
          isAllowMultipleOptionsFunction(picker);
          return;
        }

        if(widget.allowImagesAndVideos) {
          isAllowImagesAndVideosFunction(picker);
          return;
        }

        if(widget.allowCropAndCompress) {
          isAllowCropAndCompressFunction(picker);
          return;
        }

        isPickFileFunction();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey400)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: widget.rowLeftWidth),
                SvgPicture.asset("assets/svg/cloud_upload.svg"),
                const SizedBox(width: 10.0,),
                Expanded(
                  child: Text(widget.uploadMessageText, textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500),),
                )
              ],
            ),
            const SizedBox(height: 10.0,),
            Text(widget.uploadMessageBodyText, textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500))
          ],
        ),
      ),
    );
  }

  Future<void> isAllowMultipleOptionsFunction(ImagePicker picker) async {
    final res = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return MultipleOptionsBottomSheet("upload_document", isHost: false);
      },
    );

    if(res == "Take a picture") {
      isAllowCropAndCompressFunction(picker, imageSource: ImageSource.camera);
      return;
    }

    if(res == "Upload from gallery") {
      isAllowCropAndCompressFunction(picker);
      return;
    }

    if(res == "Upload from files") {
      isPickFileFunction();
      return;
    }
  }

  Future<void> isAllowImagesAndVideosFunction(ImagePicker picker) async {
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: widget.allowedExtensions.split(","),
    // );
    final XFile? result = await picker.pickMedia(
      imageQuality: 90,
    );
    if (result != null) {
      File file = File(result.path);
      String extension = file.path.split("/").last.split(".").last;

      if(!widget.allowedExtensions.split(",").contains(extension)) {
        GeneralUtils.showToast("Invalid media extension");
        return;
      }

      if(extension == "mp4" || extension == "mov" || extension == "avi") {
        // check video length
        // final info = await _mediaInfo.getMediaInfo(file.path); // videoInfo.getVideoInfo(file.path);
        final info = await videoInfo.getVideoInfo(file.path);
        if(info == null) {
          GeneralUtils.showToast("Cannot upload video");
          return;
        }

        double videoDuration = info.duration ?? 0.0;
        if(videoDuration > maxVideoDuration.toDouble() || videoDuration == 0) {
          GeneralUtils.showToast("Video cannot be more than 15 seconds");
          return;
        }

        // get thumbnail image from video
        final uInt8list = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.PNG,
            quality: 100
        );

        if(uInt8list == null) {
          GeneralUtils.showToast("Cannot upload video");
          return;
        }

        // upload thumbnail image
        setState(() {
          postFile = file;
          uploadFlow = UploadFlow.PREPARING;
        });
        String thumbnailUrl = await uploadThumbnailImageToStorage(uInt8list);

        // upload video
        setState(() {
          postFile = file;
          uploadFlow = UploadFlow.PROGRESS;
        });
        uploadFileToStorage(file, fileType: "video", thumbnailURL: thumbnailUrl);
        return;
      }
      cropImageFileAndCompress(file);
    }
  }

  Future<void> isAllowCropAndCompressFunction(ImagePicker picker, {ImageSource imageSource = ImageSource.gallery}) async {
    final XFile? image = await picker.pickImage(
      source: imageSource,
      imageQuality: 100,
    );
    if(image != null) {
      File file = File(image.path);
      cropImageFileAndCompress(file);
    }
  }

  Future<void> isPickFileFunction() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions.split(","),
    );

    if (result != null) {
      String extension = result.files.single.extension ?? "";
      if(!widget.allowedExtensions.split(",").contains(extension)) {
        GeneralUtils.showToast("Invalid media extension");
        return;
      }
      File file = File(result.files.single.path!);
      if(widget.allowCropAndCompress) {
        cropImageFileAndCompress(file);
        return;
      }
      setState(() {
        postFile = file;
        uploadFlow = UploadFlow.PROGRESS;
      });
      uploadFileToStorage(file);
    }
  }

  String getFileName() {
    if(postFile == null) {
      return "";
    }
    final fileNameWithExtension = postFile!.path.split("/").last.split(".");
    String fileName = fileNameWithExtension.first;
    if(fileName.length > 20) {
      fileName = "${fileName.substring(0, 19)}.${fileNameWithExtension.last}";
    } else {
      fileName = fileNameWithExtension.join(".");
    }
    return fileName;
  }

  Widget preparingView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey400)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_file_rounded, size: 48, color: AppColors.primaryBase,),
          // (postFile!.path.split("/").last.contains(".mp4")) ? const Icon(Icons.video_file, size: 48, color: AppColors.primaryBase,) : const SizedBox(),
          // (widget.allowedExtensions.contains("pdf")) ? Image.asset("assets/images/pdf.png", height: 48,) : const SizedBox(),
          const SizedBox(width: 5.0,),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: LinearProgressIndicator(backgroundColor: AppColors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(8), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBase),),
          ),
          const SizedBox(width: 10.0,),
          Text("Processing video...", textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700)),
          const SizedBox(width: 5.0,),
          Text(getFileName(), textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget progressView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey400)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (widget.allowedExtensions.contains("pdf")) ? Image.asset("assets/images/pdf.png", height: 48,) : (postFile!.path.split("/").last.contains(".mp4")) ? const Icon(Icons.video_file_rounded, size: 48, color: AppColors.primaryBase,) : const Icon(Icons.image_rounded, size: 48, color: AppColors.primaryBase,),
          const SizedBox(width: 5.0,),
          Text("$progressPercentage%", textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w700),),
          const SizedBox(width: 5.0,),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: LinearProgressIndicator(backgroundColor: AppColors.green.withOpacity(0.3), value: progressPercentage / 100, borderRadius: BorderRadius.circular(8), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),),
          ),
          const SizedBox(width: 10.0,),
          Text("Uploading file...", textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700)),
          const SizedBox(width: 5.0,),
          Text(getFileName(), textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget doneView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey400)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/svg/success.svg", height: 48,),
          const SizedBox(width: 5.0,),
          Text("Uploaded file", textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700)),
          const SizedBox(width: 5.0,),
          Text(getFileName(), textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.grey500)),
          GestureDetector(
            onTap: (){
              setState(() {
                uploadFlow = UploadFlow.EMPTY;
                progressPercentage = 0;
              });
              widget.onUploadDone({});
              if(widget.onClear != null) {
                Map<String, dynamic> mediaInfo = {};
                mediaInfo["fileType"] = widget.allowCropAndCompress ? "image" : "file";
                mediaInfo["url"] = fileDownloadURL;
                mediaInfo["thumbnailUrl"] = "";
                widget.onClear!(mediaInfo);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/svg/delete.svg",),
                const SizedBox(width: 10.0,),
                Text("Clear Upload", textAlign: TextAlign.center, style: bodyStyle.copyWith(color: AppColors.secondaryBase, fontWeight: FontWeight.w700),)
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> cropImageFileAndCompress(File file) async {
    final croppedFile = (await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Fixed square aspect ratio

        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Crop Image",
              toolbarColor: AppColors.primaryBase,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            title: "Crop Image",
          )
        ]));

    if(croppedFile == null) {
      return;
    }

    //compress image
    final mFile = await compressAndGetFile(File(croppedFile.path));
    if(mFile == null) {
      return;
    }

    setState(() {
      postFile = mFile;
      uploadFlow = UploadFlow.PROGRESS;
    });
    uploadFileToStorage(mFile);
  }

  Future<File?> compressAndGetFile(File file) async {
    String? key = FirebaseDatabase.instance.ref().push().key;
    File tempFile = File('${(await getTemporaryDirectory()).path}/$key.jpeg');
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempFile.path,
      quality: 100,
    );
    File fl = File(result!.path);
    return fl;
  }

  Future<String> uploadFileToStorage(File file, {String? fileType, String? thumbnailURL}) async {
    final String? key = FirebaseDatabase.instance.ref().push().key;

    String fileExt = file.path.substring(file.path.lastIndexOf(".") + 1);

    final reference = FirebaseStorage.instance
        .ref()
        .child(widget.folderName)
        .child('$key.$fileExt');

    final UploadTask uploadTask = reference.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          // print("Upload is ${progress.ceil()}% complete.");
          setState(() {
            progressPercentage = progress.ceil();
          });
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          break;
        case TaskState.success:
        // Handle successful uploads on complete
        // ...
          break;
      }
    });

    final String downloadUrl = await uploadTask.then(
          (snapShot) => snapShot.ref.getDownloadURL(),
    );

    fileDownloadURL = downloadUrl;

    setState(() {
      uploadFlow = UploadFlow.DONE;
    });

    Map<String, dynamic> mediaInfo = {};
    mediaInfo["fileType"] = fileType ??= widget.allowCropAndCompress ? "image" : "file";
    mediaInfo["url"] = downloadUrl;
    mediaInfo["thumbnailUrl"] = thumbnailURL ??= "";

    widget.onUploadDone(mediaInfo);

    if(widget.autoRestart) {
      Timer(const Duration(seconds: 2), () {
        setState(() {
          uploadFlow = UploadFlow.EMPTY;
          postFile = null;
          progressPercentage = 0;
        });
      });
    }

    return downloadUrl;
  }

  Future<String> uploadThumbnailImageToStorage(Uint8List file) async {
    final String? key = FirebaseDatabase.instance.ref().push().key;

    // String fileExt = file.path.substring(file.path.lastIndexOf(".") + 1);

    final reference = FirebaseStorage.instance
        .ref()
        .child("thumbnail-images")
        .child('$key.png');

    final UploadTask uploadTask = reference.putData(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          print("Upload is running.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          break;
        case TaskState.success:
        // Handle successful uploads on complete
        // ...
          break;
      }
    });

    final String downloadUrl = await uploadTask.then(
          (snapShot) => snapShot.ref.getDownloadURL(),
    );

    return downloadUrl;
  }
}