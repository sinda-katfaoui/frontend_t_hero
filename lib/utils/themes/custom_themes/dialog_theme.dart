// ============================================================
// TDialogTheme — Global Dialog Styling
// ============================================================
// Already handled in theme.dart — this file kept for structure.
// ============================================================
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TDialogTheme {
  TDialogTheme._();

  static DialogThemeData lightDialogTheme = DialogThemeData(
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
  );

  static DialogThemeData darkDialogTheme = DialogThemeData(
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
  );
}