import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Colors;
import 'package:tekk_gram/extensions/string/as_html_to_color.dart';

@immutable
class AppColors {
  static final loginButtonColor = '#de5246'.htmlColorToColor();
  static const loginButtonTextColor = Colors.white;
  static final googleColor = '#ffffff'.htmlColorToColor();
  static final facebookColor = '#3b5998'.htmlColorToColor();
  const AppColors._();
}
