// ============================================================
// TTextButtonTheme — Global TextButton Styling
// ============================================================
// Minimal button — used for links and secondary text actions.
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TTextButtonTheme {
  TTextButtonTheme._();

  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: TColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 8, vertical: 4),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: TColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 8, vertical: 4),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    ),
  );
}