import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Extension methods on BuildContext for convenient access to responsive design values
extension ResponsiveContextExtensions on BuildContext {
  // Screen size getters
  double get screenWidth => ResponsiveHelper.getScreenWidth(this);
  double get screenHeight => ResponsiveHelper.getScreenHeight(this);
  
  // Device type checks
  bool get isMobile => ResponsiveHelper.getScreenType(this) == ScreenType.mobile;
  bool get isTablet => ResponsiveHelper.getScreenType(this) == ScreenType.tablet;
  bool get isDesktop => ResponsiveHelper.getScreenType(this) == ScreenType.desktop;
  
  // Responsive values
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  double get responsiveBorderRadius => ResponsiveHelper.getResponsiveBorderRadius(this);
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
  
  // Responsive sizing
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  double get responsiveIconSize => ResponsiveHelper.getResponsiveIconSize(this);
  double get responsiveButtonHeight => ResponsiveHelper.getResponsiveButtonHeight(this);
  
  // Device information
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  EdgeInsets get safeAreaPadding => ResponsiveHelper.getSafeAreaPadding(this);
  double get textScaleFactor => ResponsiveHelper.getTextScaleFactor(this);
  
  // Methods with parameters
  double responsiveFontSize(double baseFontSize, {double? tabletMultiplier, double? desktopMultiplier}) => 
    ResponsiveHelper.getResponsiveFontSize(
      context: this, 
      baseFontSize: baseFontSize,
      tabletMultiplier: tabletMultiplier,
      desktopMultiplier: desktopMultiplier,
    );
}