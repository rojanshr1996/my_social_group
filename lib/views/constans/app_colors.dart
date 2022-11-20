import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Alignment, Colors, LinearGradient;
import 'package:tekk_gram/extensions/string/as_html_to_color.dart';

@immutable
class AppColors {
  static final loginButtonColor = '#de5246'.htmlColorToColor();
  static const loginButtonTextColor = Colors.white;
  static final googleColor = '#ffffff'.htmlColorToColor();
  static final facebookColor = '#3b5998'.htmlColorToColor();
  static final darkColor = '#000000'.htmlColorToColor();
  static const transparent = Colors.transparent;

  static LinearGradient topDarkGradient = LinearGradient(
    stops: const [0.35, 0.9],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkColor.withOpacity(0.6), transparent],
  );
  const AppColors._();
}
