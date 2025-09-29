import 'package:flutter/material.dart';

class AppValidator {
  /// Validate that all critical screens are accessible
  static Future<bool> validateAppFlow(BuildContext context) async {
    try {
      // Test navigation routes
      final routes = [
        '/onboarding',
        '/role-selection',
        '/passenger-auth',
        '/driver-auth',
        '/ticket-booking',
        '/pass-application',
        '/travel-buddy',
      ];

      // Check if routes are registered
      for (String route in routes) {
        try {
          Navigator.pushNamed(context, route);
          Navigator.pop(context);
        } catch (e) {
          debugPrint('Route validation failed for $route: $e');
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('App validation failed: $e');
      return false;
    }
  }

  /// Validate responsive extensions are working
  static bool validateResponsiveExtensions(BuildContext context) {
    try {
      // Test responsive extensions
      final screenWidth = context.screenWidth;
      final screenHeight = context.screenHeight;
      final responsivePadding = context.responsivePadding;
      final responsiveBorderRadius = context.responsiveBorderRadius;
      
      return screenWidth > 0 && 
             screenHeight > 0 && 
             responsivePadding != null && 
             responsiveBorderRadius > 0;
    } catch (e) {
      debugPrint('Responsive extensions validation failed: $e');
      return false;
    }
  }

  /// Show validation results
  static void showValidationResults(BuildContext context, bool isValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isValid 
            ? '✅ App validation successful!' 
            : '❌ App validation failed!',
        ),
        backgroundColor: isValid ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}