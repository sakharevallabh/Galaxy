import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static Future<Uint8List?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? await pickedFile.readAsBytes() : null;
  }
}
