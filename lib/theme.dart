import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B4D34),
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.openSans(fontSize: 14),
      ),
    );
  }
}
