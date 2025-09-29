import 'package:flutter/material.dart';

/// Color palette and gradient definitions for the Orbit Live design system
class OrbitLiveColors {
  // Primary brand colors
  static const Color primaryTeal = Color(0xFF00D4AA);
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryBlue = Color(0xFF4A90E2);
  
  // Secondary colors
  static const Color darkTeal = Color(0xFF00B894);
  static const Color lightOrange = Color(0xFFFF8A50);
  static const Color lightBlue = Color(0xFF74B9FF);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);
  static const Color black = Color(0xFF212529);
  
  // Status colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Gradient definitions
  static const List<Color> tealGradient = [
    Color(0xFF00D4AA),
    Color(0xFF00B894),
  ];
  
  static const List<Color> orangeGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF8A50),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF8F9FA),
    Color(0xFFE9ECEF),
  ];
  
  static const List<Color> blueGradient = [
    Color(0xFF4A90E2),
    Color(0xFF74B9FF),
  ];
  
  // Card shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  
  // Text colors on gradients
  static const Color textOnTeal = Colors.white;
  static const Color textOnOrange = Colors.white;
  static const Color textOnLight = Color(0xFF212529);
  static const Color textSecondaryOnTeal = Color(0xFFE0F7FA);
  static const Color textSecondaryOnOrange = Color(0xFFFFF3E0);
  
  // Private constructor to prevent instantiation
  OrbitLiveColors._();
}