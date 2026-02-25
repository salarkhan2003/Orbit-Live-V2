/// Production configuration for Orbit Live app
class ProductionConfig {
  // Firebase configuration
  static const String firebaseProjectId = 'orbit-live-3836f';
  static const String databaseUrl = 'https://orbit-live-3836f-default-rtdb.firebaseio.com';
  
  // App configuration
  static const String appName = 'Orbit Live';
  static const String appVersion = '1.0.0';
  
  // Vehicle configuration
  static const String defaultVehicleId = 'APSRTC-VEH-123';
  static const String defaultRouteId = 'RJ-12';
  static const String defaultRouteName = 'Route 101';
  
  // GPS configuration
  static const int gpsUpdateIntervalSeconds = 5;
  static const double gpsDistanceFilterMeters = 5.0;
  static const int gpsTimeoutSeconds = 15;
  
  // Firebase timeouts
  static const int firestoreTimeoutSeconds = 5;
  static const int realtimeDbTimeoutSeconds = 5;
  
  // Debug configuration
  static const bool enableDebugMode = true; // Set to false for production
  static const bool enableVerboseLogging = true; // Set to false for production
  
  // Feature flags
  static const bool enableGuestMode = true;
  static const bool enableFirestoreFallback = true;
  static const bool enableOfflineMode = true;
  
  /// Check if app is running in production mode
  static bool get isProduction => !enableDebugMode;
  
  /// Get appropriate log level based on configuration
  static String get logLevel => enableVerboseLogging ? 'DEBUG' : 'INFO';
}