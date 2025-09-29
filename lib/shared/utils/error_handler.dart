import 'package:flutter/material.dart';
import '../orbit_live_colors.dart';
import '../orbit_live_text_styles.dart';

/// Centralized error handling utility for consistent error management
class ErrorHandler {
  /// Handles authentication errors and displays appropriate messages
  static void handleAuthError(BuildContext context, dynamic error) {
    String message = _getAuthErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _retryLastAction(context),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  /// Handles network errors with appropriate user feedback
  static void handleNetworkError(BuildContext context, dynamic error) {
    String message = _getNetworkErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _retryLastAction(context),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// Handles validation errors with field-specific feedback
  static void handleValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Handles general errors with fallback messaging
  static void handleGeneralError(BuildContext context, dynamic error) {
    String message = _getGeneralErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  /// Shows success message with consistent styling
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Shows info message with consistent styling
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: OrbitLiveColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Shows a dialog for critical errors that require user attention
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: OrbitLiveColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: OrbitLiveTextStyles.cardTitle.copyWith(
                  color: OrbitLiveColors.black,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: OrbitLiveTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: OrbitLiveTextStyles.buttonMedium.copyWith(
                  color: OrbitLiveColors.darkGray,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: OrbitLiveTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  /// Maps authentication errors to user-friendly messages
  static String _getAuthErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid credentials') || 
        errorString.contains('wrong password') ||
        errorString.contains('incorrect password')) {
      return 'Invalid employee ID or password. Please try again.';
    }
    
    if (errorString.contains('user not found') || 
        errorString.contains('employee not found')) {
      return 'Employee ID not found. Please check your ID or contact support.';
    }
    
    if (errorString.contains('account disabled') || 
        errorString.contains('account suspended')) {
      return 'Your account has been disabled. Please contact support.';
    }
    
    if (errorString.contains('too many attempts') || 
        errorString.contains('rate limit')) {
      return 'Too many login attempts. Please wait a few minutes and try again.';
    }
    
    if (errorString.contains('employee id already exists') || 
        errorString.contains('already registered')) {
      return 'This employee ID is already registered. Try logging in instead.';
    }
    
    if (errorString.contains('weak password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    
    return 'Authentication failed. Please check your credentials and try again.';
  }
  
  /// Maps network errors to user-friendly messages
  static String _getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('no internet') || 
        errorString.contains('network unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (errorString.contains('timeout') || 
        errorString.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }
    
    if (errorString.contains('server error') || 
        errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    if (errorString.contains('service unavailable') || 
        errorString.contains('503')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    
    return 'Network error. Please check your connection and try again.';
  }
  
  /// Maps general errors to user-friendly messages
  static String _getGeneralErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission denied')) {
      return 'Permission denied. Please check your access rights.';
    }
    
    if (errorString.contains('file not found') || 
        errorString.contains('resource not found')) {
      return 'Required resource not found. Please try again.';
    }
    
    if (errorString.contains('storage full') || 
        errorString.contains('disk full')) {
      return 'Storage full. Please free up some space and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Retry mechanism for failed operations
  static void _retryLastAction(BuildContext context) {
    // This would typically call a callback stored in a state management solution
    // For now, we'll just show a message
    showInfo(context, 'Retry functionality would be implemented here');
  }
  
  /// Logs errors for debugging and analytics
  static void logError(dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    // In a real app, this would send to crash reporting service like Firebase Crashlytics
    debugPrint('Error logged: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    if (context != null) {
      debugPrint('Context: $context');
    }
  }
}

/// Extension methods for easier error handling
extension ErrorHandlerExtension on BuildContext {
  /// Show authentication error
  void showAuthError(dynamic error) {
    ErrorHandler.handleAuthError(this, error);
  }
  
  /// Show network error
  void showNetworkError(dynamic error) {
    ErrorHandler.handleNetworkError(this, error);
  }
  
  /// Show validation error
  void showValidationError(String message) {
    ErrorHandler.handleValidationError(this, message);
  }
  
  /// Show general error
  void showError(dynamic error) {
    ErrorHandler.handleGeneralError(this, error);
  }
  
  /// Show success message
  void showSuccess(String message) {
    ErrorHandler.showSuccess(this, message);
  }
  
  /// Show info message
  void showInfo(String message) {
    ErrorHandler.showInfo(this, message);
  }
}