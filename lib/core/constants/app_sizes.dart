import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // Screen size helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive padding
  static double paddingHorizontal(BuildContext context) =>
      screenWidth(context) * 0.04;

  static double paddingVertical(BuildContext context) =>
      screenHeight(context) * 0.02;

  // Fixed spacings
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCircle = 999.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // Button height
  static const double buttonHeight = 52.0;

  // App bar height
  static const double appBarHeight = 56.0;
}