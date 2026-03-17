import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return TColors.white;
      return TColors.textPrimary;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return TColors.primary;
      return Colors.transparent;
    }),
    side: const BorderSide(color: TColors.borderLight, width: 1.5),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return TColors.white;
      return TColors.white;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return TColors.primary;
      return Colors.transparent;
    }),
    side: const BorderSide(color: TColors.borderDark, width: 1.5),
  );
}