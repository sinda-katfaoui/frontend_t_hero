// ============================================================
// TChipTheme — Global Chip Styling
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: TColors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(
      color: TColors.textPrimary,
      fontSize: 10,
      fontFamily: 'Poppins',
    ),
    selectedColor: TColors.primary,
    checkmarkColor: TColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    backgroundColor: TColors.lightContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: TColors.borderLight, width: 0.5),
    ),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: TColors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(
      color: TColors.textWhite,
      fontSize: 10,
      fontFamily: 'Poppins',
    ),
    selectedColor: TColors.primary,
    checkmarkColor: TColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    backgroundColor: TColors.darkContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: TColors.borderDark, width: 0.5),
    ),
  );
}