import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';
import 'package:tekk_gram/state/image_upload/extensions/to_file.dart';

@immutable
class ImagePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImageFromGallery() =>
      _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 35).toFile();

  static Future<File?> picImageFromCamera() =>
      _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 35).toFile();

  static Future<List<File>> pickMultiImageFromGallery() async {
    final imageList = await _imagePicker.pickMultiImage(imageQuality: 35);
    log("$imageList");

    return imageList.map<File>((xfile) => File(xfile.path)).take(4).toList();
  }

  static Future<File?> pickVideoFromGallery() => _imagePicker.pickVideo(source: ImageSource.gallery).toFile();

  static Future<File?> pickVideoFromCamera() => _imagePicker.pickVideo(source: ImageSource.camera).toFile();
}
