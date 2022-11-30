import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tekk_gram/state/posts/models/post.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class PostImageView extends HookWidget {
  final Post post;
  const PostImageView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    CarouselController controller = CarouselController();
    final currentPos = useState<int>(0);

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        CarouselSlider.builder(
          carouselController: controller,
          itemCount: post.fileUrl.length,
          options: CarouselOptions(
              aspectRatio: 0.85,
              viewportFraction: 1,
              enlargeCenterPage: true,
              autoPlay: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                currentPos.value = index;
              }),
          itemBuilder: (ctx, index, realIdx) {
            return Image.network(
              post.fileUrl[index],
              fit: BoxFit.cover,
              width: Utilities.screenWidth(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: post.fileUrl.map((url) {
            int index = post.fileUrl.indexOf(url);
            return Container(
              alignment: Alignment.bottomCenter,
              width: 10.0,
              height: 10.0,
              margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPos.value == index ? AppColors.loginButtonColor : AppColors.loginButtonTextColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
