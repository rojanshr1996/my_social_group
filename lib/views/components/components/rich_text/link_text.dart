import 'package:flutter/foundation.dart' show immutable, VoidCallback;
import 'package:tekk_gram/views/components/components/rich_text/base_text.dart';

@immutable
class LinkText extends BaseText {
  final VoidCallback onTapped;
  const LinkText({
    required super.text,
    required this.onTapped,
    super.style,
  });
}
