import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Extension methods on BuildContext for responsive design
extension ResponsiveExtensions on BuildContext {
  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  
  /// Get responsive margin based on screen size
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  
  /// Get responsive border radius based on screen size
  double get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  
  /// Get responsive elevation based on screen size
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
  
  /// Get responsive spacing based on screen size
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  
  /// Get responsive icon size based on screen size
  double get responsiveIconSize => ResponsiveHelper.getResponsiveIconSize(this);
  
  /// Get responsive button height based on screen size
  double get responsiveButtonHeight => ResponsiveHelper.getResponsiveButtonHeight(this);
  
  /// Get screen width
  double get screenWidth => ResponsiveHelper.getScreenWidth(this);
  
  /// Get screen height
  double get screenHeight => ResponsiveHelper.getScreenHeight(this);
  
  /// Check if device is tablet
  bool get isTablet => ResponsiveHelper.getScreenType(this) == ScreenType.tablet;
  
  /// Check if device is mobile
  bool get isMobile => ResponsiveHelper.getScreenType(this) == ScreenType.mobile;
  
  /// Check if device is desktop
  bool get isDesktop => ResponsiveHelper.getScreenType(this) == ScreenType.desktop;
  
  /// Check if device is in landscape mode
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  
  /// Check if device is in portrait mode
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  
  /// Get safe area padding
  EdgeInsets get safeAreaPadding => ResponsiveHelper.getSafeAreaPadding(this);
  
  /// Get text scale factor
  double get textScaleFactor => ResponsiveHelper.getTextScaleFactor(this);
  
  /// Get responsive font size with base size
  double responsiveFontSize(double baseFontSize, {double? tabletMultiplier, double? desktopMultiplier}) {
    return ResponsiveHelper.getResponsiveFontSize(
      context: this,
      baseFontSize: baseFontSize,
      tabletMultiplier: tabletMultiplier,
      desktopMultiplier: desktopMultiplier,
    );
  }
}