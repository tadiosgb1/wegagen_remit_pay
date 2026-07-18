


import 'package:flutter/material.dart';

class AppColors {
  // --- PRIMARY BRAND: WEGAGEN ORANGE ---
  static const Color primary =  Color(0xFFFC6B0E); 
  static const Color primaryLight = Color(0xFFFE9015);
  static const Color primaryDark = Color(0xFFFF6B35);
  
  // --- SECONDARY BRAND: WEGAGEN GREEN ---
  static const Color secondary = Color(0xFF04425B);
  static const Color secondaryDark = Color(0xFF04425B);
  
  // --- ACCENT SYSTEM (Based on Primary Orange) ---
  static const Color accent = Color(0xFFFF6B35); 
  static const Color accentLight = Color(0xFFFF9E7A);
  static const Color accentDark = Color(0xFFCC4D1F);
  
  // --- BACKGROUND & SURFACE ---
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  
  // --- TEXT COLORS ---
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on Orange
  
  // --- BORDERS & DIVIDERS (Darker Secondary Green) ---
  static const Color border = Color(0xFF064127); 
  static const Color borderLight = Color(0xFFE0E6ED);
  static const Color divider = Color(0xFFEEEEEE);
  
  // --- STATUS COLORS ---
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // --- GRADIENTS ---
  // Primary (Orange) Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF9E7A)],
  );
  
  // Secondary (Green) Gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFC6B0E), Color(0xFFFC6B0E)],
  );

  // Splash Screen Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFC6B0E), Color(0xFFFC6B0E)],
  );
}


