import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataCacheService {
  static const String _busRoutesKey = 'cached_bus_routes';
  static const String _busStopsKey = 'cached_bus_stops';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _lastUpdateKey = 'last_cache_update';

  // Cache data with expiration time (in minutes)
  static const int _cacheExpirationMinutes = 30;

  // Save bus routes to cache
  static Future<void> cacheBusRoutes(List<dynamic> routes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(routes);
    await prefs.setString(_busRoutesKey, jsonString);
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached bus routes
  static Future<List<dynamic>?> getCachedBusRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_busRoutesKey);
    
    if (jsonString == null) return null;
    
    // Check if cache is expired
    final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final minutesSinceUpdate = (now - lastUpdate) / 60000;
    
    if (minutesSinceUpdate > _cacheExpirationMinutes) {
      // Cache expired, remove it
      await clearBusRoutesCache();
      return null;
    }
    
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is List ? decoded : null;
    } catch (e) {
      // Invalid JSON, clear cache
      await clearBusRoutesCache();
      return null;
    }
  }

  // Clear bus routes cache
  static Future<void> clearBusRoutesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_busRoutesKey);
  }

  // Save bus stops to cache
  static Future<void> cacheBusStops(List<dynamic> stops) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stops);
    await prefs.setString(_busStopsKey, jsonString);
  }

  // Get cached bus stops
  static Future<List<dynamic>?> getCachedBusStops() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_busStopsKey);
    
    if (jsonString == null) return null;
    
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is List ? decoded : null;
    } catch (e) {
      // Invalid JSON, clear cache
      await clearBusStopsCache();
      return null;
    }
  }

  // Clear bus stops cache
  static Future<void> clearBusStopsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_busStopsKey);
  }

  // Save user preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(preferences);
    await prefs.setString(_userPreferencesKey, jsonString);
  }

  // Get user preferences
  static Future<Map<String, dynamic>?> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userPreferencesKey);
    
    if (jsonString == null) return null;
    
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      // Invalid JSON, clear cache
      await prefs.remove(_userPreferencesKey);
      return null;
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_busRoutesKey);
    await prefs.remove(_busStopsKey);
    await prefs.remove(_userPreferencesKey);
    await prefs.remove(_lastUpdateKey);
  }

  // Check if we should use cached data based on connectivity
  static bool shouldUseCachedData(bool isConnected, bool isLowBandwidth) {
    // Use cached data if not connected or on low bandwidth
    return !isConnected || isLowBandwidth;
  }
}