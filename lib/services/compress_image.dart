// compress image to reduce the size and kepp the quality
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

Future<File> compressImage(File pickedImage, String postId,
    {bool isImageForProfile = false}) async {
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image imageFile = Im.decodeImage(pickedImage.readAsBytesSync());
  final compressedImageFile = File('$path/img_$postId.jpg')
    ..writeAsBytesSync(Im.encodeJpg(
      imageFile,
      quality: isImageForProfile ? 9 : 13,
    ));

  return compressedImageFile;
}
