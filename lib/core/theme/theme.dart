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
    surface: Color(0xFFFFFFFF),
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
    surface: Color(0xFF121212),
    onSurface: Colors.white,
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    fontFamily: 'Nunito',
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: _lightColorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _lightColorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: _lightColorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: _lightColorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _lightColorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: _lightColorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: _lightColorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _lightColorScheme.onPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _lightColorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: _lightColorScheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: _lightColorScheme.surface,
      surfaceTintColor: _lightColorScheme.primary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _lightColorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
      toolbarTextStyle: TextStyle(color: _lightColorScheme.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest.withValues(
        alpha: 0.1,
      ),
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _lightColorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _lightColorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: _lightColorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
      errorStyle: TextStyle(color: _lightColorScheme.error),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    fontFamily: 'Nunito',
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: _darkColorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: _darkColorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: _darkColorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: _darkColorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _darkColorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: _darkColorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: _darkColorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _darkColorScheme.onPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _darkColorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: _darkColorScheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: _darkColorScheme.surface,
      surfaceTintColor: _darkColorScheme.primary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _darkColorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: _darkColorScheme.onSurface),
      toolbarTextStyle: TextStyle(color: _darkColorScheme.onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _darkColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _darkColorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _darkColorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: _darkColorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
      errorStyle: TextStyle(color: _darkColorScheme.error),
    ),
  );
}
