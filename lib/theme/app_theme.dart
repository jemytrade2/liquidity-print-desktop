import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode Gradient (from v14 web app)
  static const bgGradientStart = Color(0xFF061E32);  // #061E32
  static const bgGradientEnd = Color(0xFF000000);    // #000000
  
  // Panel Theme
  static const panelBorder = Color.fromRGBO(30, 58, 138, 0.3);
  static const panelBg = Colors.transparent;
  
  // Neon Accents
  static const neonBlue = Color(0xFF00FFFF);
  static const neonPurple = Color(0xFFFF00FF);
  static const neonGreen = Color(0xFF00FF00);
  static const neonYellow = Color(0xFFFFFF00);
  static const neonRed = Color(0xFFFF0000);
  
  // Text
  static const textPrimary = Color(0xFFEDEDED);
  static const textSecondary = Color(0xFFAAAAAA);
  
  // Chart Colors (from indicators)
  static const deltaPositive = Color(0xFF00FF00);
  static const deltaNegative = Color(0xFFFF0000);
  static const bslColor = Color(0xFF00FFFF);
  static const sslColor = Color(0xFFFF00FF);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bgGradientEnd,
      primaryColor: AppColors.neonBlue,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neonBlue, width: 2),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
