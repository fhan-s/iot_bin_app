import 'package:flutter/material.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 235),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 33, 33, 33),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 33, 33, 33),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
    //add more here to change buttons, text, etc as needed
  );
  // static final darkThemeMode = ThemeData.dark().copyWith(
  //   scaffoldBackgroundColor: AppColourPalette.backgroundColor,
  // );
}
