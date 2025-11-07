import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Brand color palette (from your uploaded design)
  static const Color primary = Color(0xFFFF9A2E); // warm orange
  static const Color topOrange = Color(0xFFFFA84D);
  static const Color midOrange = Color(0xFFFF7A00);
  static const Color deepPurple = Color(0xFF2B1055); // deep purple
  static const Color darkBg = Color(0xFF0A0520);
  static const Color cardBg = Color(0xFF14102A);
  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color lightCard = Color(0xFFFFFFFF);

  // 🌙 DARK THEME
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        background: darkBg,
        surface: cardBg,
      ),
      cardColor: cardBg,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ☀️ LIGHT THEME
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.black87),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        background: lightBg,
        surface: lightCard,
      ),
      cardColor: lightCard,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
