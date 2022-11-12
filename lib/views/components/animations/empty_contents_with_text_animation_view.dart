import 'package:flutter/material.dart';

class EmptyContentsWithTextAnimationView extends StatelessWidget {
  final String text;
  const EmptyContentsWithTextAnimationView({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // const EmptyContentsAnimationView(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
