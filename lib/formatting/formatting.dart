// formatting.dart

import 'package:flutter/material.dart';

// Formatting class
class Formatting {
  // Colors
  static const Color primary = Color.fromRGBO(80, 141, 78, 1);
  static const Color darkerGreen = Color.fromRGBO(26, 83, 25, 1);
  static const Color white = Color.fromRGBO(242, 242, 242, 1);
  static const Color black = Color.fromRGBO(27, 28, 30, 1);
  static const Color red = Color.fromRGBO(217, 30, 24, 1);

  static const String fontFamily = 'Poppins';

  // Font weights
  static const FontWeight fontWeightItalic = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Text styles
  static TextStyle get regularStyle => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeightRegular,
      );

  static TextStyle get mediumStyle => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeightMedium,
      );

  static TextStyle get semiBoldStyle => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeightSemiBold,
      );

  static TextStyle get boldStyle => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeightBold,
      );
  static TextStyle get italicStyle => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeightRegular,
        fontStyle: FontStyle.italic,
      );
}
