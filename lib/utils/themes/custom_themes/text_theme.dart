// ============================================================
// TTextTheme — Global Text Style Definitions
// ============================================================
// Defines all text styles used across the app.
// Font sizes kept compact (8-14px) to match no-scroll design.
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    headlineMedium: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    headlineSmall: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    titleLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    titleMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    titleSmall: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600,
      color: TColors.textSecondary, fontFamily: 'Poppins'),
    bodyLarge: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    bodyMedium: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: TColors.textSecondary, fontFamily: 'Poppins'),
    bodySmall: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w400,
      color: TColors.textHint, fontFamily: 'Poppins'),
    labelLarge: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      color: TColors.textPrimary, fontFamily: 'Poppins'),
    labelMedium: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w400,
      color: TColors.textHint, fontFamily: 'Poppins'),
    labelSmall: TextStyle(
      fontSize: 9, fontWeight: FontWeight.w400,
      color: TColors.textHint, fontFamily: 'Poppins'),
  );

  static TextTheme darkTextTheme = const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    headlineMedium: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    headlineSmall: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    titleLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    titleMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    titleSmall: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600,
      color: TColors.grey, fontFamily: 'Poppins'),
    bodyLarge: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    bodyMedium: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: TColors.grey, fontFamily: 'Poppins'),
    bodySmall: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w400,
      color: TColors.grey, fontFamily: 'Poppins'),
    labelLarge: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      color: TColors.textWhite, fontFamily: 'Poppins'),
    labelMedium: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w400,
      color: TColors.grey, fontFamily: 'Poppins'),
    labelSmall: TextStyle(
      fontSize: 9, fontWeight: FontWeight.w400,
      color: TColors.grey, fontFamily: 'Poppins'),
  );
}