import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:tekk_gram/utils/constants.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class EnlargeImage extends StatelessWidget {
  final String imageUrl;

  const EnlargeImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transformationController = TransformationController();
    TapDownDetails? doubleTapDetails;

    void handleDoubleTapDown(TapDownDetails details) {
      doubleTapDetails = details;
    }

    void handleDoubleTap() {
      if (transformationController.value != Matrix4.identity()) {
        transformationController.value = Matrix4.identity();
      } else {
        final position = doubleTapDetails?.localPosition;
        transformationController.value = Matrix4.identity()
          ..translate(-position!.dx * 2, -position.dy * 2)
          ..scale(3.0);
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onDoubleTap: handleDoubleTap,
              onDoubleTapDown: handleDoubleTapDown,
              child: InteractiveViewer(
                transformationController: transformationController,
                panEnabled: true, // Set it to false to prevent panning.
                minScale: 1,
                maxScale: 3,
                child: SizedBox(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: CachedNetworkImage(
                    filterQuality: FilterQuality.none,
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Center(child: Image.asset(appLogo)),
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, color: AppColors.loginButtonTextColor, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {
                        Utilities.closeActivity(context);
                      },
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
