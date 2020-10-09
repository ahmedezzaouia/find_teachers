import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<PickedFile> getImageFromLibrary({bool fromCamera = false}) async {
    return ImagePicker().getImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
  }
}
