import 'package:flutter/material.dart';

class RemoveFocus extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const RemoveFocus({Key? key, this.onTap, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
