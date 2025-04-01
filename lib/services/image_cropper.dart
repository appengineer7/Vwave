import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:vwave/common/providers/firebase.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/styles/app_colors.dart';

class Cropper {
  final ImageCropper cropper = ImageCropper();

  final Ref ref;

  Cropper(this.ref);

  Future<File> cropImage(File file) async {
    final croppedImage = await cropper.cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Fixed square aspect ratio

      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarColor: AppColors.primaryBase,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: "Crop Image",
        )
      ],
      compressQuality: 50,
    );

    return File(croppedImage!.path);
  }

  Future<File> compressImage(File file) async {
    final cropped = await cropImage(file);

    String? key = ref.read(firebaseDatabaseProvider).ref().push().key;

    File tempFile = File('${(await getTemporaryDirectory()).path}/$key.jpeg');

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      cropped.absolute.path,
      tempFile.path,
      quality: 60,
    );
    return File(result!.path);
  }
}

final imageCropperProvider = Provider<Cropper>((ref) => Cropper(ref));
