import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/common/providers/firebase.dart';

class ImageUpload {
  final Ref ref;

  ImageUpload(this.ref);

  Future<String> uploadFileToStorage(File file, {String folder = "product-images", Function(double progress)? onUploading}) async {
    final String? key = ref.read(firebaseDatabaseProvider).ref().push().key;

    String fileExt = file.path.substring(file.path.lastIndexOf(".") + 1);

    final reference = ref
        .read(firebaseStorageProvider)
        .ref()
        .child(folder)
        .child('$key.$fileExt');

    final UploadTask uploadTask = reference.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          // print("Upload is ${progress.ceil()}% complete.");
          if(onUploading != null) {
            onUploading(progress);
          }
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

    // String? key = FirebaseDatabase.instance.ref().push().key;
    // String fileExt = _file.path.substring(_file.path.lastIndexOf(".") + 1);
    // // print(fileExt);
    // final Reference ref = FirebaseStorage.instance
    //     .ref()
    //     .child('community-files')
    //     .child('$key.$fileExt');
    // final UploadTask uploadTask = ref.putFile(_file);
    // await uploadTask.whenComplete(() {});
    // TaskSnapshot storageTaskSnapshot = uploadTask.snapshot;
    // return await storageTaskSnapshot.ref.getDownloadURL();
  }
}

final imageUploadService = Provider<ImageUpload>((ref) => ImageUpload(ref));
