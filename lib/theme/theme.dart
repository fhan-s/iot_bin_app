import 'package:flutter/material.dart';
import 'app_colour_palette.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColourPalette.backgroundColor,
    //add more here to change buttons, text, etc as needed
  );
  // static final darkThemeMode = ThemeData.dark().copyWith(
  //   scaffoldBackgroundColor: AppColourPalette.backgroundColor,
  // );
}
