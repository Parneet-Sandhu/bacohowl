import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE5B7B6); // Soft pink
  static const Color secondaryColor = Color(0xFFA5D6D9); // Soft blue
  static const Color backgroundColor = Color(0xFFF8F3E6); // Cream
  static const Color accentColor = Color(0xFF9DC9AC); // Soft green
  static const Color textColor = Color(0xFF5C4B51); // Warm gray

  static TextStyle get titleStyle => GoogleFonts.kodchasan(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 1.2,
  );

  static TextStyle get bodyStyle => GoogleFonts.kodchasan(
    fontSize: 16,
    color: textColor.withOpacity(0.8),
  );

  static BoxDecoration get playerDecoration => BoxDecoration(
    color: Colors.white,  // Make sure this is solid white
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.2),
        blurRadius: 15,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: secondaryColor.withOpacity(0.2),
        blurRadius: 15,
        spreadRadius: 5,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration get progressBarDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: backgroundColor,
    border: Border.all(
      color: primaryColor.withOpacity(0.3),
      width: 2,
    ),
  );
}
