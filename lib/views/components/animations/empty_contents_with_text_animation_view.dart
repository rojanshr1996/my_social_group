import 'package:flutter/material.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_animation_view.dart';

class EmptyContentsWithTextAnimationView extends StatelessWidget {
  final String text;
  const EmptyContentsWithTextAnimationView({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const EmptyContentsAnimationView(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
