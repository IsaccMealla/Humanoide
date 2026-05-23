import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF6B00),
      secondary: Color(0xFFFF8C42),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    useMaterial3: true,
  );
}
