// ============================================================
// TElevatedButtonTheme — Global ElevatedButton Styling
// ============================================================
// Full width, 46px height, 14px radius, red background.
// Used for primary actions: login, submit, etc.
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.white,
      backgroundColor: TColors.primary,
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.lightContainer,
      minimumSize: const Size(double.infinity, 46),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.white,
      backgroundColor: TColors.primary,
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.darkContainer,
      minimumSize: const Size(double.infinity, 46),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}