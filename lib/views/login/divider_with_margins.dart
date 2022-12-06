import 'package:flutter/material.dart';

class DividerWithMargins extends StatelessWidget {
  final double? margin;
  const DividerWithMargins({super.key, this.margin = 40.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: margin),
        const Divider(),
        SizedBox(height: margin),
      ],
    );
  }
}
