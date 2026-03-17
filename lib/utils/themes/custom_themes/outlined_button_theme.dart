import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static OutlinedButtonThemeData lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.primary,
      minimumSize: const Size(double.infinity, 50),
      side: const BorderSide(color: TColors.primary, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: TColors.primary,
        fontFamily: 'Poppins',
      ),
    ),
  );

  static OutlinedButtonThemeData darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: TColors.primary,
      minimumSize: const Size(double.infinity, 50),
      side: const BorderSide(color: TColors.primary, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: TColors.primary,
        fontFamily: 'Poppins',
      ),
    ),
  );
}