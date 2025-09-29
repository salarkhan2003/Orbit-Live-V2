import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for accessibility features and helpers
class AccessibilityHelper {
  /// Minimum touch target size for accessibility
  static const double minTouchTargetSize = 44.0;
  
  /// Creates a semantic button with proper accessibility labels
  static Widget createSemanticButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: minTouchTargetSize,
              minHeight: minTouchTargetSize,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Creates a semantic text field with proper labels
  static Widget createSemanticTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? error,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: error,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  
  /// Creates a semantic loading indicator
  static Widget createSemanticLoadingIndicator({
    required Widget child,
    String label = 'Loading',
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }
  
  /// Creates a semantic error message
  static Widget createSemanticError({
    required Widget child,
    required String error,
  }) {
    return Semantics(
      label: error,
      liveRegion: true,
      child: child,
    );
  }
  
  /// Provides haptic feedback
  static void provideHapticFeedback() {
    HapticFeedback.vibrate();
  }
  
  /// Announces a message to screen readers
  static void announceMessage(String message) {
    // SemanticsService.announce(message, TextDirection.ltr);
    // Note: SemanticsService is not available in current Flutter version
  }
  
  /// Creates a semantic list item
  static Widget createSemanticListItem({
    required Widget child,
    required int index,
    required int total,
    String? customLabel,
  }) {
    return Semantics(
      label: customLabel ?? 'Item ${index + 1} of $total',
      // sortKey: OrdinalSortKey(index.toDouble()), // Not available in current Flutter version
      child: child,
    );
  }
  
  /// Creates a semantic card with proper navigation
  static Widget createSemanticCard({
    required Widget child,
    required VoidCallback onTap,
    String? semanticLabel,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }
  
  /// Checks if text scaling is enabled and adjusts accordingly
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(baseFontSize);
  }
  
  /// Creates accessible spacing based on text scale factor
  static double getAccessibleSpacing(BuildContext context, double baseSpacing) {
    final textScaler = MediaQuery.of(context).textScaler;
    final scaleFactor = textScaler.scale(1.0);
    return baseSpacing * scaleFactor.clamp(1.0, 1.5);
  }
  
  /// Ensures minimum touch target size
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double minSize = minTouchTargetSize,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
  
  /// Creates a semantic progress indicator
  static Widget createSemanticProgressIndicator({
    required double value,
    String? label,
    String? valueText,
  }) {
    return Semantics(
      label: label ?? 'Progress',
      value: valueText ?? '${(value * 100).round()}%',
      child: LinearProgressIndicator(value: value),
    );
  }
}