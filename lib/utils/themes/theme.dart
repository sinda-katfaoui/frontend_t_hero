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
      primary:   TColors.primary,
      surface:   TColors.cardLight,
      error:     TColors.error,
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
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: const TextStyle(
        fontSize: 12,
        color: TColors.textSecondary,
        fontFamily: 'Poppins',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TColors.light,
      hintStyle: const TextStyle(
        color: TColors.textHint,
        fontSize: 10,
        fontFamily: 'Poppins',
      ),
      labelStyle: const TextStyle(
        color: TColors.textHint,
        fontSize: 10,
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.borderLight, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.borderLight, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 9),
    ),
    cardTheme: CardThemeData(
      color: TColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: TColors.borderLight, width: 0.5),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12, vertical: 2),
      dense: true,
      minLeadingWidth: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: TColors.borderLight,
      thickness: 0.5,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: TColors.cardLight,
      selectedItemColor: TColors.primary,
      unselectedItemColor: TColors.grey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 7,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 7,
        fontFamily: 'Poppins',
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TColors.textPrimary,
      contentTextStyle: const TextStyle(
        color: TColors.white,
        fontSize: 12,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.dark,
    colorScheme: const ColorScheme.dark(
      primary:   TColors.primary,
      surface:   TColors.cardDark,
      error:     TColors.error,
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
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TColors.textWhite,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: const TextStyle(
        fontSize: 12,
        color: TColors.grey,
        fontFamily: 'Poppins',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TColors.darkContainer,
      hintStyle: const TextStyle(
        color: TColors.grey,
        fontSize: 10,
        fontFamily: 'Poppins',
      ),
      labelStyle: const TextStyle(
        color: TColors.grey,
        fontSize: 10,
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.borderDark, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.borderDark, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 9),
    ),
    cardTheme: CardThemeData(
      color: TColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: TColors.borderDark, width: 0.5),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12, vertical: 2),
      dense: true,
      minLeadingWidth: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: TColors.borderDark,
      thickness: 0.5,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: TColors.cardDark,
      selectedItemColor: TColors.primary,
      unselectedItemColor: TColors.grey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 7,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 7,
        fontFamily: 'Poppins',
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TColors.cardDark,
      contentTextStyle: const TextStyle(
        color: TColors.textWhite,
        fontSize: 12,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}