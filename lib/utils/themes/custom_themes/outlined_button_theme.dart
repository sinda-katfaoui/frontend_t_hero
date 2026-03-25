// ============================================================
// TOutlinedButtonTheme — Global OutlinedButton Styling
// ============================================================
// Full width, 44px height, 14px radius, transparent background.
// Used for secondary actions: register, cancel, etc.
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.textPrimary,
      minimumSize: const Size(double.infinity, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      side: const BorderSide(
        color: TColors.borderLight, width: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.textWhite,
      minimumSize: const Size(double.infinity, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      side: const BorderSide(
        color: TColors.borderDark, width: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}