import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextStyle kAppBarStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 26,
  );

  static TextStyle kLabelStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  static TextStyle kPrimaryStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle kHintStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  static TextStyle kButtonStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle kSocialTextStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 18.75 / 16,
  );

  static TextStyle dmTextStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  static TextStyle kChatStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  static TextStyle displayStyle(
    TextStyle? base, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      textStyle: base,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle bodyStyle(
    TextStyle? base, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      textStyle: base,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle captionStyle(
    TextStyle? base, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      textStyle: base,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme lightTextTheme = const TextTheme();
  static TextTheme darkTextTheme = const TextTheme();
}
