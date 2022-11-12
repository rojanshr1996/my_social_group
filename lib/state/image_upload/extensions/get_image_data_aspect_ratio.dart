import 'package:flutter/material.dart' as material show Image, ImageConfiguration, ImageStreamListener;
import 'package:flutter/services.dart';
import 'package:tekk_gram/state/image_upload/extensions/get_image_aspect_ratio.dart';

extension GetImageDataAspectRatio on Uint8List {
  Future<double> getAspectRatio() async {
    final image = material.Image.memory(this);
    return image.getAspectRatio();
  }
}
