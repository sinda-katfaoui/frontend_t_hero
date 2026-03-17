import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/appbar_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/bottom_sheet_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/checkbox_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/chip_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/elevated_button_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/outlined_button_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/text_button_theme.dart';
import 'package:frontend_t_hero/utils/themes/custom_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.light,
    colorScheme: const ColorScheme.light(
      primary: TColors.primary,
      surface: TColors.cardLight,
      error:   TColors.error,
    ),
    textTheme:           TTextTheme.lightTextTheme,
    appBarTheme:         TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme:    TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme:       TCheckboxTheme.lightCheckboxTheme,
    chipTheme:           TChipTheme.lightChipTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme:     TTextButtonTheme.lightTextButtonTheme,
    dialogTheme: DialogThemeData(
      backgroundColor: TColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: const TextStyle(
        fontSize: 13,
        color: TColors.textSecondary,
        fontFamily: 'Poppins',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TColors.white,
      hintStyle: const TextStyle(color: TColors.textHint, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderLight, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderLight, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: TColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: TColors.borderLight, width: 0.5),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.dark,
    colorScheme: const ColorScheme.dark(
      primary: TColors.primary,
      surface: TColors.cardDark,
      error:   TColors.error,
    ),
    textTheme:           TTextTheme.darkTextTheme,
    appBarTheme:         TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme:    TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme:       TCheckboxTheme.darkCheckboxTheme,
    chipTheme:           TChipTheme.darkChipTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme:     TTextButtonTheme.darkTextButtonTheme,
    dialogTheme: DialogThemeData(
      backgroundColor: TColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TColors.textWhite,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: const TextStyle(
        fontSize: 13,
        color: TColors.grey,
        fontFamily: 'Poppins',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TColors.cardDark,
      hintStyle: const TextStyle(color: TColors.grey, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderDark, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.borderDark, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: TColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: TColors.borderDark, width: 0.5),
      ),
    ),
  );
}