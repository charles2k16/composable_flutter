import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color blue = Color(0xFF0A84FF);
  static const Color green = Color(0xFF30D158);
  static const Color amber = Color(0xFFFFD60A);
  static const Color red = Color(0xFFFF453A);

  // Dark backgrounds
  static const Color bg900 = Color(0xFF0C0C0F);
  static const Color bg800 = Color(0xFF141418);
  static const Color bg700 = Color(0xFF1C1C22);
  static const Color bg600 = Color(0xFF242429);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xAAFFFFFF);
  static const Color textTertiary = Color(0x55FFFFFF);

  // Border
  static const Color border = Color(0x12FFFFFF);
  static const Color border2 = Color(0x20FFFFFF);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg900,
      colorScheme: const ColorScheme.dark(
        background: bg900,
        surface: bg800,
        primary: blue,
        secondary: green,
        error: red,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400, color: textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(color: textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bg800,
        selectedItemColor: blue,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
    );
  }
}
