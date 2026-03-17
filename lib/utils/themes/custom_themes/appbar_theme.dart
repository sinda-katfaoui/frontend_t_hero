import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.primary,
    foregroundColor: TColors.white,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: TColors.white,
      fontFamily: 'Poppins',
    ),
    iconTheme: IconThemeData(color: TColors.white, size: 22),
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.black,
    foregroundColor: TColors.white,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: TColors.white,
      fontFamily: 'Poppins',
    ),
    iconTheme: IconThemeData(color: TColors.white, size: 22),
  );
}