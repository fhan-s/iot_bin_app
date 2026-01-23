import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 33, 33, 33),
      foregroundColor: Colors.white,
    ),
  );
  static final titleText = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.white,
  );
  // static final darkThemeMode = ThemeData.dark().copyWith(
  //   scaffoldBackgroundColor: AppColourPalette.backgroundColor,
  // );
}
