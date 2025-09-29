import 'package:flutter/material.dart';

/// Animation duration and curve constants for the Orbit Live design system
class OrbitLiveAnimations {
  // Duration constants
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration standardDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 450);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration extraLongDuration = Duration(milliseconds: 900);
  
  // Curve constants
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve slowStart = Curves.slowMiddle;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve sharpCurve = Curves.easeInOutQuart;
  
  // Page transition curves
  static const Curve pageEnterCurve = Curves.easeOut;
  static const Curve pageExitCurve = Curves.easeIn;
  
  // Card animation curves
  static const Curve cardScaleCurve = Curves.elasticOut;
  static const Curve cardSlideCurve = Curves.easeOutBack;
  
  // Button animation curves
  static const Curve buttonPressCurve = Curves.easeInOut;
  static const Curve buttonReleaseCurve = Curves.bounceOut;
  
  // Loading animation curves
  static const Curve loadingCurve = Curves.linear;
  static const Curve pulseCurve = Curves.easeInOut;
  
  // Stagger delays for sequential animations
  static const Duration staggerShort = Duration(milliseconds: 50);
  static const Duration staggerMedium = Duration(milliseconds: 100);
  static const Duration staggerLong = Duration(milliseconds: 150);
  
  // Animation intervals for complex sequences
  static const double fadeInStart = 0.0;
  static const double fadeInEnd = 0.3;
  static const double slideInStart = 0.2;
  static const double slideInEnd = 0.7;
  static const double scaleInStart = 0.5;
  static const double scaleInEnd = 1.0;
  
  // Tween configurations
  static final Tween<double> fadeInTween = Tween<double>(begin: 0.0, end: 1.0);
  static final Tween<double> fadeOutTween = Tween<double>(begin: 1.0, end: 0.0);
  static final Tween<double> scaleUpTween = Tween<double>(begin: 0.8, end: 1.0);
  static final Tween<double> scaleDownTween = Tween<double>(begin: 1.0, end: 0.95);
  static final Tween<Offset> slideUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.3),
    end: Offset.zero,
  );
  static final Tween<Offset> slideDownTween = Tween<Offset>(
    begin: const Offset(0.0, -0.3),
    end: Offset.zero,
  );
  static final Tween<Offset> slideLeftTween = Tween<Offset>(
    begin: const Offset(0.3, 0.0),
    end: Offset.zero,
  );
  static final Tween<Offset> slideRightTween = Tween<Offset>(
    begin: const Offset(-0.3, 0.0),
    end: Offset.zero,
  );
  
  // Animation helper methods
  
  /// Creates a fade transition animation
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  /// Creates a scale transition animation
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
    Curve curve = bounceCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  /// Creates a slide transition animation
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 0.3),
    Offset end = Offset.zero,
    Curve curve = cardSlideCurve,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  /// Creates a staggered animation with interval
  static Animation<double> createStaggeredAnimation(
    AnimationController controller, {
    required double intervalStart,
    required double intervalEnd,
    Curve curve = standardCurve,
  }) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(intervalStart, intervalEnd, curve: curve),
      ),
    );
  }
  
  /// Creates a rotation animation
  static Animation<double> createRotationAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  // Private constructor to prevent instantiation
  OrbitLiveAnimations._();
}