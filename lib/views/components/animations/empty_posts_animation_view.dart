import 'package:tekk_gram/views/components/animations/lottie_animation_view.dart';
import 'package:tekk_gram/views/components/animations/models/lottie_animation.dart';

class EmptyPostsAnimationView extends LottieAnimationView {
  const EmptyPostsAnimationView({super.key})
      : super(
          animation: LottieAnimation.emptyPosts,
        );
}
