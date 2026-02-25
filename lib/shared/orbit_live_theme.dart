import 'package:flutter/material.dart';
import 'orbit_live_colors.dart';
import 'orbit_live_text_styles.dart';

/// Orbit Live theme configuration
class OrbitLiveTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: OrbitLiveColors.primaryTeal,
      scaffoldBackgroundColor: OrbitLiveColors.lightGray,
      appBarTheme: AppBarTheme(
        backgroundColor: OrbitLiveColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: OrbitLiveTextStyles.headerTitle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OrbitLiveColors.primaryTeal,
          foregroundColor: Colors.white,
          textStyle: OrbitLiveTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: OrbitLiveTextStyles.headerTitle,
        headlineMedium: OrbitLiveTextStyles.cardTitle,
        bodyLarge: OrbitLiveTextStyles.bodyLarge,
        bodyMedium: OrbitLiveTextStyles.bodyMedium,
        bodySmall: OrbitLiveTextStyles.bodySmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.primaryTeal, width: 2),
        ),
        filled: true,
        fillColor: OrbitLiveColors.lightGray,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Extension for responsive design helpers
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  
  EdgeInsets get responsivePadding {
    if (isMobile) return const EdgeInsets.all(16);
    if (isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }
  
  double get responsiveBorderRadius {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }
  
  double get responsiveElevation {
    if (isMobile) return 4;
    if (isTablet) return 6;
    return 8;
  }
}