import 'package:flutter/material.dart';

class AppTheme {
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3F51B5),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF9FA8DA),
    onPrimaryContainer: Colors.black,
    secondary: Color(0xFF00897B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF80CBC4),
    onSecondaryContainer: Colors.black,
    tertiary: Color(0xFFFBB13C),
    onTertiary: Colors.black,
    tertiaryContainer: Color(0xFFFFDD8A),
    onTertiaryContainer: Colors.black,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    background: Color(0xFFFFFFFF),
    onBackground: Colors.black,
    surface: Color(0xFFECEFF1),
    onSurface: Colors.black,
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9FA8DA),
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF3F51B5),
    onPrimaryContainer: Colors.white,
    secondary: Color(0xFF80CBC4),
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF00897B),
    onSecondaryContainer: Colors.white,
    tertiary: Color(0xFFFFDD8A),
    onTertiary: Colors.black,
    tertiaryContainer: Color(0xFFFBB13C),
    onTertiaryContainer: Colors.black,
    error: Color(0xFFCF6679),
    onError: Colors.black,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF232323),
    onSurface: Colors.white,
  );

  static final lightTheme = ThemeData.from(colorScheme: _lightColorScheme);
  static final darkTheme = ThemeData.from(colorScheme: _darkColorScheme);
}