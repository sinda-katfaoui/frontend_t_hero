// ============================================================
// TAppBarTheme — Global AppBar Styling
// ============================================================
// Defines AppBar appearance for light and dark modes.
// Used across all screens that use the default AppBar.
// Custom AppBars (red ones) override this per screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.cardLight,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.textPrimary, size: 20),
    actionsIconTheme: IconThemeData(color: TColors.textPrimary, size: 20),
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      fontFamily: 'Poppins',
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.cardDark,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.textWhite, size: 20),
    actionsIconTheme: IconThemeData(color: TColors.textWhite, size: 20),
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: TColors.textWhite,
      fontFamily: 'Poppins',
    ),
  );
}