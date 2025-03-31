
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:vwave/utils/general.dart';

import '../../../../widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';

class AddToStoryPage extends ConsumerStatefulWidget {
  const AddToStoryPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddToStoryPageState();
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

List<CameraDescription> _cameras = <CameraDescription>[];

class _AddToStoryPageState extends ConsumerState<AddToStoryPage> with WidgetsBindingObserver, TickerProviderStateMixin {

  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;

  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  late CameraDescription selectedCamera;

  bool isVideoRecording = false;

  double containerCircleButtonSize = 80;
  double containerInnerCircleButtonSize = 65;
  double containerProgressCircleButtonSize = 80;
  double videoRecordingProgress = 0;
  int maxVideoRecordingDuration = 15999;

  late Timer recordingTimer;

  final videoInfo = FlutterVideoInfo();

  bool isCameraInactive = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async {
      await requestPermission();
      remoteConfigInit();
    });
  }

  Future<void> initControllers() async {
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _cameras = await availableCameras();
    selectedCamera = _cameras[1];
    // selectedCamera = _cameras.firstWhere(
    //       (element) => element.lensDirection == (frontCamera ? CameraLensDirection.front : CameraLensDirection.back),
    // );
    await onNewCameraSelected(selectedCamera);
    onSetFlashModeButtonPressed(FlashMode.off);
  }

  Future<void> requestPermission() async {
    final ph = await [Permission.microphone, Permission.camera].request();
    if(ph[Permission.microphone] == PermissionStatus.denied) {
      Navigator.of(context).pop();
      GeneralUtils.showToast("Permission is required");
      return;
    }
    if(ph[Permission.camera] == PermissionStatus.denied) {
      Navigator.of(context).pop();
      GeneralUtils.showToast("Permission is required");
      return;
    }
    await initControllers();
  }

  Future<void> remoteConfigInit() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'max_video_story_recording_duration_inMilliseconds': 15999,
      });
      await remoteConfig.fetchAndActivate();
      final current = remoteConfig.getInt("max_video_story_recording_duration_inMilliseconds");
      setState(() {
        maxVideoRecordingDuration = current;
      });
    } catch (e, _) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    if(controller != null){
      controller?.dispose();
    }
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null) {
      return;
    }

    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      isCameraInactive = true;
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      isCameraInactive = false;
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            (controller == null) ? const SizedBox() : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: !controller!.value.isInitialized || isCameraInactive ? const SizedBox() : AspectRatio(aspectRatio: controller!.value.aspectRatio, child: CameraPreview(controller!),),
            ),
            // Visibility(visible: false, child: Column(
            //   children: [
            //     Expanded(
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.black,
            //           border: Border.all(
            //             color:
            //             controller != null && controller!.value.isRecordingVideo
            //                 ? Colors.redAccent
            //                 : Colors.grey,
            //             width: 3.0,
            //           ),
            //         ),
            //         child: Padding(
            //           padding: const EdgeInsets.all(1.0),
            //           child: Center(
            //             child: _cameraPreviewWidget(),
            //           ),
            //         ),
            //       ),
            //     ),
            //     _captureControlRowWidget(),
            //     _modeControlRowWidget(),
            //     Padding(
            //       padding: const EdgeInsets.all(5.0),
            //       child: Row(
            //         children: <Widget>[
            //           _cameraTogglesRowWidget(),
            //           _thumbnailWidget(),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 24, top: 20, right: 24),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  NavBackButton(
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded, color: Colors.white,),
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // controller != null ? onFlashModeButtonPressed : null
                      if(controller == null) {
                        return;
                      }
                      onFlashModeButtonPressed();
                      if(controller?.value.flashMode == FlashMode.off) {
                        onSetFlashModeButtonPressed(FlashMode.auto);
                      }
                      if(controller?.value.flashMode == FlashMode.auto) {
                        onSetFlashModeButtonPressed(FlashMode.always);
                      }
                      if(controller?.value.flashMode == FlashMode.always) {
                        onSetFlashModeButtonPressed(FlashMode.off);
                      }
                    },
                    child: controller?.value.flashMode == FlashMode.always ? const Icon(Icons.flash_on, color: Colors.white,) :
                    controller?.value.flashMode == FlashMode.auto ? const Icon(Icons.flash_auto, color: Colors.white) : const Icon(Icons.flash_off, color: Colors.white,),
                  ),
                  GestureDetector(
                    onTap: () {
                      if(controller == null) {
                        return;
                      }
                      if(selectedCamera == _cameras.first) {
                        selectedCamera = _cameras[1];
                        onNewCameraSelected(_cameras[1]);
                      } else {
                        selectedCamera = _cameras.first;
                        onNewCameraSelected(_cameras.first);
                      }

                    },
                    child: const Icon(Icons.cameraswitch_rounded, color: Colors.white,),
                  )
                ],
              )
            ),
            (isVideoRecording) ? const SizedBox() : Positioned(
              bottom: 28,
                left: 20,
                child:
                GestureDetector(
              onTap: pickImageSlashVideo,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 5),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.image_rounded, size: 32, color: Colors.white,),
              ),
            )
            ),
            Positioned(
              bottom: 20,
                left: (MediaQuery.of(context).size.width - 50) / 2,
                child: GestureDetector(
                  onTap: () async {
                    takeStoryPicture();
                    // print("tapped");
              },
              onLongPressStart: (e) {
                // print("long press down");
                // start recording
                startStoryVideoRecording();
              },
              onLongPressEnd: (e) {
                // print("long press end");
                // end recording
                stopStoryVideoRecording();
              },
                  // behavior: HitTestBehavior.opaque,
                  // onScaleStart: _handleScaleStart,
                  // onScaleUpdate: _handleScaleUpdate,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  (isVideoRecording) ? SizedBox(
                    width: containerProgressCircleButtonSize,
                    height: containerProgressCircleButtonSize,
                    child: CircleProgressBar(
                      foregroundColor: AppColors.secondaryBase,
                      value: videoRecordingProgress,
                      child: AnimatedCount(
                        count: videoRecordingProgress,
                        duration: const Duration(milliseconds: 500),
                        unit: '',
                      ),
                    ),
                    // TweenAnimationBuilder<double>(
                    //     tween: Tween<double>(begin: 0.0, end: 1),
                    //     duration: const Duration(milliseconds: 500),
                    //     builder: (context, value, _) => CircularProgressIndicator(
                    //   strokeWidth: 6,
                    //   // color: AppColors.secondaryBase,
                    //   valueColor: const AlwaysStoppedAnimation(AppColors.secondaryBase),
                    //   value: videoRecordingProgress,
                    // )),
                  ) : const SizedBox(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  width: containerCircleButtonSize,
                  height: containerCircleButtonSize,
                  child: Icon(
                    Icons.circle,
                    color: isVideoRecording
                        ? Colors.white
                        : Colors.white38,
                    size: containerCircleButtonSize,
                  ),),
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      width: containerInnerCircleButtonSize,
                      height: containerInnerCircleButtonSize,
                      child: Icon(
                    Icons.circle,
                    color: isVideoRecording
                        ? Colors.red
                        : Colors.white,
                    size: containerInnerCircleButtonSize,
                  )),
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }

  Future<void> pickImageSlashVideo() async {
    final ImagePicker picker = ImagePicker();
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: "jpg,jpeg,gif,png,mp4,mov,avi".split(","),
    // );
    final XFile? result = await picker.pickMedia(
      imageQuality: 100,
    );
    if(result != null) {
      File file = File(result.path);
      final extension = result.path.split("/").last.split(".").last;

      if(!"mp4,mov,avi,jpeg,jpg,png,gif".split(",").contains(extension)) {
        GeneralUtils.showToast("Invalid media extension");
        return;
      }

      // process for video
      if(extension == "mp4" || extension == "mov" || extension == "avi") {
        GeneralUtils.showToast("Analysing video...");
        final info = await videoInfo.getVideoInfo(file.path);
        if(info == null) {
          GeneralUtils.showToast("Cannot upload video");
          return;
        }
        double videoDuration = info.duration ?? 0;
        if(videoDuration > maxVideoRecordingDuration.toDouble() || videoDuration == 0) {
          GeneralUtils.showToast("Video cannot be more than ${(maxVideoRecordingDuration/1000).ceil()} seconds");
          return;
        }

        Navigator.of(context).pushNamed("/process_story", arguments: {"type": "video", "file": file.path});
        return;
      }

      // process for image
      cropImageFileAndCompress(file);

    }
  }

  Future<void> cropImageFileAndCompress(File file) async {
    final croppedFile = (await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatioPresets: CropAspectRatioPreset.values,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Edit Image",
              toolbarColor: AppColors.primaryBase,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              hideBottomControls: false,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            title: "Edit Image",
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

    Navigator.of(context).pushNamed("/process_story", arguments: {"type": "image", "file": mFile.path});
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

  Future<void> takeStoryPicture() async {
    Future.delayed(Duration.zero, () async {
      if(isVideoRecording) {
        return;
      }
      // print("tapped");
      final CameraController? cameraController = controller;
      if(cameraController == null) {
        return;
      }
      if(cameraController.value.isInitialized && cameraController.value.isRecordingVideo) {
        return;
      }
      await onTakePictureButtonPressed();
      if(imageFile != null) {
        cropImageFileAndCompress(File(imageFile!.path));
      }
    });
  }

  Future<void> startStoryVideoRecording() async {
    setState(() {
      isVideoRecording = true;
      containerCircleButtonSize = 100;
      containerInnerCircleButtonSize = 80;
      containerProgressCircleButtonSize = 100;
    });

    await startVideoRecording();

    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int stopTime = (maxVideoRecordingDuration.toDouble() / 1000).ceil();
      // print("============================${timer.tick}====================================");
      setState(() {
        videoRecordingProgress = timer.tick == 0 ? 0 : timer.tick / stopTime;
      });
      if(timer.tick == stopTime) {
        timer.cancel();
        stopStoryVideoRecording();
      }
      // print("============================$videoRecordingProgress====================================");
    });
  }

  Future<void> stopStoryVideoRecording() async {
    if(recordingTimer.isActive) {
      recordingTimer.cancel();
    }
    setState(() {
      videoRecordingProgress = 0;
      isVideoRecording = false;
      containerCircleButtonSize = 80;
      containerInnerCircleButtonSize = 65;
      containerProgressCircleButtonSize = 80;
    });

    videoFile = await stopVideoRecording();

    if(videoFile != null) {
      Navigator.of(context).pushNamed("/process_story", arguments: {"type": "video", "file": videoFile?.path});
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (TapDownDetails details) =>
                      onViewFinderTap(details, constraints),
                );
              }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (localVideoController == null && imageFile == null)
              Container()
            else
              SizedBox(
                width: 64.0,
                height: 64.0,
                child: (localVideoController == null)
                    ? (
                    // The captured image on the web contains a network-accessible URL
                    // pointing to a location within the browser. It may be displayed
                    // either with Image.network or Image.memory after loading the image
                    // bytes to memory.
                    kIsWeb
                        ? Image.network(imageFile!.path)
                        : Image.file(File(imageFile!.path)))
                    : Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.pink)),
                  child: Center(
                    child: AspectRatio(
                        aspectRatio:
                        localVideoController.value.aspectRatio,
                        child: VideoPlayer(localVideoController)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_on),
              color: Colors.blue,
              onPressed: controller != null ? onFlashModeButtonPressed : null,
            ),
            // The exposure and focus mode are currently not supported on the web.
            ...!kIsWeb
                ? <Widget>[
              IconButton(
                icon: const Icon(Icons.exposure),
                color: Colors.blue,
                onPressed: controller != null
                    ? onExposureModeButtonPressed
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.filter_center_focus),
                color: Colors.blue,
                onPressed:
                controller != null ? onFocusModeButtonPressed : null,
              )
            ]
                : <Widget>[],
            IconButton(
              icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
              color: Colors.blue,
              onPressed: controller != null ? onAudioModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation),
              color: Colors.blue,
              onPressed: controller != null
                  ? onCaptureOrientationLockButtonPressed
                  : null,
            ),
          ],
        ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_off),
              color: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.flash_auto),
              color: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              color: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.highlight),
              color: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: ColoredBox(
          color: Colors.grey.shade50,
          child: Column(
            children: <Widget>[
              const Center(
                child: Text('Exposure Mode'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                        onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                    child: const Text('AUTO'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                        onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                    child: const Text('LOCKED'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller!.setExposureOffset(0.0)
                        : null,
                    child: const Text('RESET OFFSET'),
                  ),
                ],
              ),
              const Center(
                child: Text('Exposure Offset'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                        _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: ColoredBox(
          color: Colors.grey.shade50,
          child: Column(
            children: <Widget>[
              const Center(
                child: Text('Focus Mode'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setFocusPoint(null);
                      }
                      showInSnackBar('Resetting focus point');
                    },
                    child: const Text('AUTO'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                    child: const Text('LOCKED'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: cameraController != null &&
              cameraController.value.isRecordingPaused
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
          color: Colors.blue,
          onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              cameraController.value.isRecordingVideo
              ? (cameraController.value.isRecordingPaused)
              ? onResumeButtonPressed
              : onPauseButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              cameraController.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.pause_presentation),
          color:
          cameraController != null && cameraController.value.isPreviewPaused
              ? Colors.red
              : Colors.blue,
          onPressed:
          cameraController == null ? null : onPausePreviewButtonPressed,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (_cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in _cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.ultraHigh,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {
        });
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
          cameraController.getMinExposureOffset().then(
                  (double value) => _minAvailableExposureOffset = value),
          cameraController
              .getMaxExposureOffset()
              .then((double value) => _maxAvailableExposureOffset = value)
        ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
        // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onTakePictureButtonPressed() async {
    XFile? file = await takePicture();
    if (mounted) {
      setState(() {
        imageFile = file;
        videoController?.dispose();
        videoController = null;
      });
      if (file != null) {
        showInSnackBar('Picture saved to ${file.path}');
      }
    }
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    print("stoppping video =============================");
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      print("stop video");
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print("error here");
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path))
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

}