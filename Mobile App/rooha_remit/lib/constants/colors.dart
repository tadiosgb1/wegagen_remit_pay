import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Updated for Rooha Remit
  static const Color primary = Color(0xFF0b6335); // Main green color
  static const Color primaryLight = Color(0xFF2E8B57); // Lighter shade of green
  static const Color primaryDark = Color(0xFF064127); // Darker shade of green
  
  // Accent Colors
  static const Color accent = Color(0xFFe89010); // Orange accent for borders and highlights
  static const Color accentLight = Color(0xFFFFB84D);
  static const Color accentDark = Color(0xFFCC7A00);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFe89010); // Orange border color as requested
  static const Color borderLight = Color(0xFFE0E6ED);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0b6335),
      Color(0xFF2E8B57),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFe89010),
      Color(0xFFFFB84D),
    ],
  );
  
  // Splash Screen Gradient (updated for Rooha Remit)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0b6335),
      Color(0xFF2E8B57),
      Color(0xFF4CAF50),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}