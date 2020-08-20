import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<PickedFile> getImageFromLibrary() async {
    return ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 150,
    );
  }
}
