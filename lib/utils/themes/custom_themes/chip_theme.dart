import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: TColors.borderLight,
    labelStyle: const TextStyle(
      color: TColors.textPrimary,
      fontSize: 12,
      fontFamily: 'Poppins',
    ),
    selectedColor: TColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    backgroundColor: TColors.light,
    side: const BorderSide(color: TColors.borderLight, width: 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    checkmarkColor: TColors.white,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: TColors.borderDark,
    labelStyle: const TextStyle(
      color: TColors.textWhite,
      fontSize: 12,
      fontFamily: 'Poppins',
    ),
    selectedColor: TColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    backgroundColor: TColors.cardDark,
    side: const BorderSide(color: TColors.borderDark, width: 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    checkmarkColor: TColors.white,
  );
}