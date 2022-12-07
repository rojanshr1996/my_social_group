import 'package:tekk_gram/views/components/animations/lottie_animation_view.dart';
import 'package:tekk_gram/views/components/animations/models/lottie_animation.dart';

class EmptySearchAnimationView extends LottieAnimationView {
  const EmptySearchAnimationView({super.key})
      : super(
          animation: LottieAnimation.emptySearch,
        );
}
