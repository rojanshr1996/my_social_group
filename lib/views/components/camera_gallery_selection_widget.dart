import 'package:flutter/material.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class CameraGallerySelectionWidget extends StatelessWidget {
  final VoidCallback? onGallaryTap;
  final VoidCallback? onCameraTap;
  const CameraGallerySelectionWidget({Key? key, this.onGallaryTap, this.onCameraTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: AppColors.loginButtonColor),
                  child: GestureDetector(
                    onTap: onCameraTap,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera, size: 22),
                          SizedBox(width: 6),
                          Text("Camera"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: AppColors.loginButtonColor),
                  child: GestureDetector(
                    onTap: onGallaryTap,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo, size: 22),
                          SizedBox(width: 6),
                          Text("Gallery"),
                        ],
                      ),
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
