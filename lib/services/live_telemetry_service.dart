import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Simple, reliable live telemetry service for GPS → Firebase
class LiveTelemetryService {
  static StreamSubscription<Position>? _positionStream;
  static String? _currentVehicleId;
  static String? _currentRouteId;
  static bool _isActive = false;

  /// Write live telemetry data to Firebase - SINGLE CLEAN FUNCTION
  static Future<void> writeLiveTelemetry({
    required String vehicleId,
    required double lat,
    required double lon,
    required String routeId,
    required bool isActive,
  }) async {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://orbit-live-3836f-default-rtdb.firebaseio.com/',
      );
      final ref = db.ref('live-telemetry/$vehicleId');
      
      final data = {
        'lat': lat,
        'lon': lon,
        'vehicle_id': vehicleId,
        'route_id': routeId,
        'status': isActive ? 'in_transit' : 'offline',
        'is_active': isActive,
        'timestamp': ServerValue.timestamp,
      };

      debugPrint('[LIVE] Writing telemetry for $vehicleId: $lat, $lon');
      await ref.update(data);
      debugPrint('[LIVE] Firebase write SUCCESS for $vehicleId');
    } catch (e) {
      debugPrint('[LIVE] Firebase write ERROR: $e');
      // Don't throw - keep trying
    }
  }

  /// Start live telemetry tracking - SIMPLE & RELIABLE
  static Future<bool> startTracking({
    required String vehicleId,
    required String routeId,
  }) async {
    try {
      debugPrint('[LIVE] Starting telemetry for $vehicleId');
      
      // Stop any existing tracking first
      await stopTracking();
      
      _currentVehicleId = vehicleId;
      _currentRouteId = routeId;
      _isActive = true;

      // 1. Get REAL GPS position - NO HARDCODED COORDINATES
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint('[LIVE] REAL GPS obtained: ${position.latitude}, ${position.longitude}');

      // 2. Write initial position immediately
      await writeLiveTelemetry(
        vehicleId: vehicleId,
        lat: position.latitude,
        lon: position.longitude,
        routeId: routeId,
        isActive: true,
      );

      // 3. Start continuous GPS stream - updates every 3-5 seconds
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update when moved 5 meters
          timeLimit: Duration(seconds: 30),
        ),
      ).listen(
        (Position position) async {
          if (_isActive && _currentVehicleId != null) {
            debugPrint('[LIVE] GPS stream update: ${position.latitude}, ${position.longitude}');
            await writeLiveTelemetry(
              vehicleId: _currentVehicleId!,
              lat: position.latitude,
              lon: position.longitude,
              routeId: _currentRouteId ?? 'UNKNOWN',
              isActive: true,
            );
          }
        },
        onError: (error) {
          debugPrint('[LIVE] GPS stream error: $error');
        },
      );

      debugPrint('[LIVE] Telemetry tracking started for $vehicleId');
      return true;
    } catch (e) {
      debugPrint('[LIVE] Failed to start tracking: $e');
      _isActive = false;
      return false;
    }
  }

  /// Stop live telemetry tracking - DO NOT DELETE NODE
  static Future<void> stopTracking() async {
    try {
      debugPrint('[LIVE] Stopping telemetry tracking');
      
      // Cancel GPS stream
      _positionStream?.cancel();
      _positionStream = null;

      // Write final position with inactive status (DO NOT DELETE NODE)
      if (_currentVehicleId != null && _isActive) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );

          await writeLiveTelemetry(
            vehicleId: _currentVehicleId!,
            lat: position.latitude,
            lon: position.longitude,
            routeId: _currentRouteId ?? 'UNKNOWN',
            isActive: false,
          );

          debugPrint('[LIVE] Final telemetry written for $_currentVehicleId with is_active: false');
        } catch (e) {
          debugPrint('[LIVE] Failed to write final position: $e');
        }
      }

      // Reset state
      _currentVehicleId = null;
      _currentRouteId = null;
      _isActive = false;

      debugPrint('[LIVE] Telemetry tracking stopped');
    } catch (e) {
      debugPrint('[LIVE] Error stopping tracking: $e');
    }
  }

  /// Check if tracking is active
  static bool get isTracking => _isActive && _positionStream != null;

  /// Get current vehicle ID
  static String? get currentVehicleId => _currentVehicleId;

  /// Get telemetry path for UI display
  static String getTelemetryPath() {
    if (_currentVehicleId != null) {
      return '/live-telemetry/$_currentVehicleId';
    }
    return '/live-telemetry/{vehicleId}';
  }

  /// Get database URL for UI display
  static String getDatabaseURL() {
    return 'https://orbit-live-3836f-default-rtdb.firebaseio.com/';
  }

  /// Get debug info for settings screen
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isActive': _isActive,
      'currentVehicleId': _currentVehicleId,
      'currentRouteId': _currentRouteId,
      'hasStream': _positionStream != null,
      'databaseURL': getDatabaseURL(),
      'telemetryPath': getTelemetryPath(),
    };
  }
}