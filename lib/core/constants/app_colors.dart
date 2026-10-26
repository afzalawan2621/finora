import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Ocean Blue
  static const Color primary = Color(0xFF0284C7);
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0C4A6E);

  // Accent — Teal
  static const Color accent = Color(0xFF14B8A6);
  static const Color accentLight = Color(0xFF2DD4BF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Income / Expense / Profit
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color profit = Color(0xFF0284C7);

  // Backgrounds
  static const Color background = Color(0xFFF5FAFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFDEEAF2);

  // Text
  static const Color textPrimary = Color(0xFF0B1F2A);
  static const Color textSecondary = Color(0xFF5A6F7B);
  static const Color textHint = Color(0xFF8CA0AB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Input
  static const Color inputFill = Color(0xFFEBF3F9);
  static const Color inputBorder = Color(0xFFDEEAF2);

  // Shadows
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark
  static const Color darkBg = Color(0xFF0B1F2A);
  static const Color darkSurface = Color(0xFF142F3D);
}