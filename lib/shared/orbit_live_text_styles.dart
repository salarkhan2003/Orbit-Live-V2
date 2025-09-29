import 'package:flutter/material.dart';
import 'orbit_live_colors.dart';

/// Typography specifications for the Orbit Live design system
class OrbitLiveTextStyles {
  // Header styles
  static const TextStyle headerTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  // Card styles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle cardDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white60,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.2,
  );
  
  // Form styles
  static const TextStyle formLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.darkGray,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  static const TextStyle formInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.black,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  static const TextStyle formHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.mediumGray,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  static const TextStyle formError = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.error,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.black,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.black,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.darkGray,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  // Caption and overline styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.darkGray,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.darkGray,
    letterSpacing: 1.5,
    height: 1.6,
  );
  
  // Navigation styles
  static const TextStyle navigationActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: OrbitLiveColors.primaryTeal,
    letterSpacing: 0.25,
    height: 1.2,
  );
  
  static const TextStyle navigationInactive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: OrbitLiveColors.darkGray,
    letterSpacing: 0.25,
    height: 1.2,
  );
  
  // Status text styles
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.success,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.warning,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.error,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: OrbitLiveColors.info,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  // Private constructor to prevent instantiation
  OrbitLiveTextStyles._();
}