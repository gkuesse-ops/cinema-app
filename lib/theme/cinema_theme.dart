import 'package:flutter/material.dart';

class CinemaTheme {
  // Couleurs principales
  static const Color bg = Color(0xFF0A0A0F);
  static const Color bg2 = Color(0xFF13131A);
  static const Color bg3 = Color(0xFF1C1C26);
  static const Color accent = Color(0xFFE8C56D);
  static const Color accent2 = Color(0xFFC9773A);
  static const Color textPrimary = Color(0xFFF0EDE8);
  static const Color textMuted = Color(0xFF6B6880);
  static const Color border = Color(0x12FFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent2,
        surface: bg2,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'BebasNeue',
          color: textPrimary,
          letterSpacing: 2,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}
