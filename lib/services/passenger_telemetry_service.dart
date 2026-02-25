import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/vehicle_telemetry.dart';

/// Service to read live telemetry data for passengers
/// Connects to Firebase /live-telemetry path and streams active vehicles
class PassengerTelemetryService extends ChangeNotifier {
  static const String _databaseURL = 'https://orbit-live-3836f-default-rtdb.firebaseio.com/';
  static const String _telemetryPath = 'live-telemetry';

  StreamSubscription<DatabaseEvent>? _telemetrySubscription;
  List<VehicleTelemetry> _activeVehicles = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _busTypeFilter; // 'AC', 'Non-AC', or null for all
  bool _accessibilityFilter = false;
  bool _lowCrowdFilter = false;

  List<VehicleTelemetry> get activeVehicles => _activeVehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get unique route IDs from active vehicles
  List<String> get availableRoutes {
    final routes = _activeVehicles.map((v) => v.routeId).toSet().toList();
    routes.sort();
    return routes;
  }

  /// Get count of buses on a specific route
  int getBusCountForRoute(String routeId) {
    return _activeVehicles.where((v) => v.routeId == routeId).length;
  }

  /// Set bus type filter
  void setBusTypeFilter(String? busType) {
    _busTypeFilter = busType;
    notifyListeners();
  }

  /// Set accessibility filter
  void setAccessibilityFilter(bool enabled) {
    _accessibilityFilter = enabled;
    notifyListeners();
  }

  /// Set low crowd filter
  void setLowCrowdFilter(bool enabled) {
    _lowCrowdFilter = enabled;
    notifyListeners();
  }

  /// Get filtered vehicles based on current filters
  List<VehicleTelemetry> get filteredVehicles {
    var result = _activeVehicles;

    // Apply bus type filter
    if (_busTypeFilter != null) {
      result = result.where((v) => v.busType == _busTypeFilter).toList();
    }

    // Accessibility filter is a stub for now
    // In future, this would filter based on wheelchair accessibility data

    // Low crowd filter is a stub for now
    // In future, this would filter based on occupancy data
    if (_lowCrowdFilter) {
      // For now, we show all buses but this can be expanded
      // result = result.where((v) => v.seatsAvailable != null && v.seatsAvailable! > 10).toList();
    }

    return result;
  }

  /// Start listening to live telemetry updates
  void startListening() {
    debugPrint('[PASSENGER_TELEMETRY] Starting listener...');

    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _databaseURL,
      );

      final ref = db.ref(_telemetryPath);

      _telemetrySubscription = ref.onValue.listen(
        (DatabaseEvent event) {
          _processSnapshot(event.snapshot);
        },
        onError: (error) {
          debugPrint('[PASSENGER_TELEMETRY] Error: $error');
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );

      debugPrint('[PASSENGER_TELEMETRY] Listener started');
    } catch (e) {
      debugPrint('[PASSENGER_TELEMETRY] Failed to start listener: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processSnapshot(DataSnapshot snapshot) {
    try {
      _isLoading = false;
      _error = null;

      if (!snapshot.exists || snapshot.value == null) {
        debugPrint('[PASSENGER_TELEMETRY] No data in snapshot');
        _activeVehicles = [];
        notifyListeners();
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      debugPrint('[PASSENGER_TELEMETRY] Received ${data.length} vehicles');

      final vehicles = <VehicleTelemetry>[];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final telemetry = VehicleTelemetry.fromFirebase(key.toString(), value);

          // Only include active vehicles with in_transit status
          if (telemetry.isActive &&
              (telemetry.status == 'in_transit' || telemetry.status == 'active')) {
            vehicles.add(telemetry);
            debugPrint('[PASSENGER_TELEMETRY] Active vehicle: ${telemetry.vehicleId} at (${telemetry.lat}, ${telemetry.lon})');
          }
        }
      });

      _activeVehicles = vehicles;
      debugPrint('[PASSENGER_TELEMETRY] Total active vehicles: ${_activeVehicles.length}');
      notifyListeners();

    } catch (e) {
      debugPrint('[PASSENGER_TELEMETRY] Error processing snapshot: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Stop listening to telemetry updates
  void stopListening() {
    debugPrint('[PASSENGER_TELEMETRY] Stopping listener...');
    _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
  }

  /// Get a specific vehicle by ID
  VehicleTelemetry? getVehicle(String vehicleId) {
    try {
      return _activeVehicles.firstWhere((v) => v.vehicleId == vehicleId);
    } catch (e) {
      return null;
    }
  }

  /// Get vehicles on a specific route
  List<VehicleTelemetry> getVehiclesOnRoute(String routeId) {
    return _activeVehicles.where((v) => v.routeId == routeId).toList();
  }

  /// Refresh data manually
  Future<void> refresh() async {
    debugPrint('[PASSENGER_TELEMETRY] Refreshing data...');
    _isLoading = true;
    notifyListeners();

    // Stop and restart listener to force refresh
    stopListening();
    await Future.delayed(const Duration(milliseconds: 500));
    startListening();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

