import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TDialogTheme {
  TDialogTheme._();

  static DialogTheme lightDialogTheme = DialogTheme(
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
  );

  static DialogTheme darkDialogTheme = DialogTheme(
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
  );
}