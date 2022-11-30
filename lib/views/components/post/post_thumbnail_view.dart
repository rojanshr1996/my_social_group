import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/state/image_upload/models/file_type.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostThumbnailView extends StatelessWidget {
  final VoidCallback onTapped;
  final Post post;
  const PostThumbnailView({super.key, required this.onTapped, required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onTapped,
          child: Image.network(
            post.thumbnailUrl.first,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      post.fileType == FileType.image ? Icons.photo : Icons.video_camera_back,
                      size: 14,
                      color: Colors.white70,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        post.fileType == FileType.image
            ? Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.images,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${post.fileUrl.length}",
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
