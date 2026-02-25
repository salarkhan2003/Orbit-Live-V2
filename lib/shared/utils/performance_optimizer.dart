import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PerformanceOptimizer {
  static bool _isInitialized = false;

  /// Initialize performance optimizations
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Optimize system UI
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Set preferred orientations for better performance
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Performance optimization error: $e');
    }
  }

  /// Optimize memory usage by clearing image cache when needed
  static void clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('Image cache clear error: $e');
    }
  }

  /// Preload critical images for faster loading
  static Future<void> preloadCriticalImages(BuildContext context) async {
    try {
      // Add any critical images that need to be preloaded
      final List<String> criticalImages = [
        'assets/images/ORBIT LIVE APP ICON.jpg',
        // Add more critical images here
      ];

      for (String imagePath in criticalImages) {
        try {
          await precacheImage(AssetImage(imagePath), context);
        } catch (e) {
          debugPrint('Failed to preload image $imagePath: $e');
        }
      }
    } catch (e) {
      debugPrint('Image preloading error: $e');
    }
  }

  /// Optimize widget rebuilds with RepaintBoundary
  static Widget optimizeRebuilds({
    required Widget child,
    String? debugLabel,
  }) {
    return RepaintBoundary(
      child: child,
    );
  }

  /// Create optimized list view for better scrolling performance
  static Widget createOptimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      // Optimize for performance
      cacheExtent: 200.0,
      physics: const BouncingScrollPhysics(),
    );
  }

  /// Debounce function calls to improve performance
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }
}

