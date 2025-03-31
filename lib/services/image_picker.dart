import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class Picker {
  final ImagePicker picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 60,
    );

    return image;
  }
}

final picker = Provider<Picker>((ref) => Picker());
