import 'package:flutter/material.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_animation_view.dart';

class EmptyContentsWithTextAnimationView extends StatelessWidget {
  final String text;
  const EmptyContentsWithTextAnimationView({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Utilities.screenHeight(context) - 100,
      child: Column(
        children: [
          const Expanded(
            flex: 3,
            child: EmptyContentsAnimationView(),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
