import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/driver_models.dart';
import 'live_telemetry_service.dart';

/// Comprehensive service for Driver/Conductor operations
class DriverService extends ChangeNotifier {
  static const String _databaseURL = 'https://orbit-live-3836f-default-rtdb.firebaseio.com/';

  // Session data
  DriverEmployee? _currentEmployee;
  DriverTrip? _currentTrip;
  bool _isLoggedIn = false;

  // Trip state
  String _tripStatus = 'not_started'; // not_started, on_trip, paused, completed
  int _seatsBoarded = 0;
  int _totalCapacity = 40;

  // Seat update debounce
  Timer? _seatUpdateDebounce;
  final List<Map<String, dynamic>> _offlineSeatQueue = [];

  // Getters
  DriverEmployee? get currentEmployee => _currentEmployee;
  DriverTrip? get currentTrip => _currentTrip;
  bool get isLoggedIn => _isLoggedIn;
  String get tripStatus => _tripStatus;
  int get seatsBoarded => _seatsBoarded;
  int get totalCapacity => _totalCapacity;
  int get seatsAvailable => _totalCapacity - _seatsBoarded;
  bool get isOnTrip => _tripStatus == 'on_trip';

  DatabaseReference get _dbRef {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseURL,
    );
    return db.ref();
  }

  // ==================== AUTHENTICATION ====================

  /// Login with employee ID and password
  Future<bool> login(String employeeId, String password) async {
    try {
      debugPrint('[DRIVER_SERVICE] Attempting login for: $employeeId');

      // Check employees collection
      final snapshot = await _dbRef.child('employees/$employeeId').get();

      if (!snapshot.exists) {
        debugPrint('[DRIVER_SERVICE] Employee not found: $employeeId');
        return false;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final storedPassword = data['password']?.toString();

      // Validate password (in production, use proper hashing)
      if (storedPassword != password) {
        debugPrint('[DRIVER_SERVICE] Invalid password for: $employeeId');
        return false;
      }

      // Create employee object
      _currentEmployee = DriverEmployee.fromFirebase(employeeId, data);
      _isLoggedIn = true;

      // Update last login
      await _dbRef.child('employees/$employeeId/last_login').set(ServerValue.timestamp);

      // Save session locally
      await _saveSession(employeeId);

      debugPrint('[DRIVER_SERVICE] Login successful for: $employeeId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Login error: $e');
      return false;
    }
  }

  /// Auto-login from saved session
  Future<bool> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('driver_employee_id');

      if (employeeId == null || employeeId.isEmpty) {
        return false;
      }

      // Fetch employee data
      final snapshot = await _dbRef.child('employees/$employeeId').get();

      if (!snapshot.exists) {
        await _clearSession();
        return false;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      _currentEmployee = DriverEmployee.fromFirebase(employeeId, data);
      _isLoggedIn = true;

      debugPrint('[DRIVER_SERVICE] Auto-login successful for: $employeeId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Auto-login error: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Stop any active trip first
      if (isOnTrip) {
        await endTrip();
      }

      await _clearSession();
      _currentEmployee = null;
      _currentTrip = null;
      _isLoggedIn = false;
      _tripStatus = 'not_started';

      debugPrint('[DRIVER_SERVICE] Logged out');
      notifyListeners();
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Logout error: $e');
    }
  }

  Future<void> _saveSession(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_employee_id', employeeId);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_employee_id');
  }

  // ==================== TRIP MANAGEMENT ====================

  /// Start a new trip
  Future<bool> startTrip({
    required String vehicleId,
    required String routeId,
    required String source,
    required String destination,
    required int capacity,
  }) async {
    try {
      debugPrint('[DRIVER_SERVICE] Starting trip: $vehicleId on $routeId');

      // Validate inputs
      if (vehicleId.isEmpty || routeId.isEmpty) {
        debugPrint('[DRIVER_SERVICE] Invalid vehicle or route ID');
        return false;
      }

      // Check GPS permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('[DRIVER_SERVICE] GPS permission denied');
        return false;
      }

      // Generate trip ID
      final tripId = 'TRIP-${DateTime.now().millisecondsSinceEpoch}';

      // Create trip object
      _currentTrip = DriverTrip(
        tripId: tripId,
        vehicleId: vehicleId,
        routeId: routeId,
        conductorId: _currentEmployee?.employeeId ?? 'GUEST',
        source: source,
        destination: destination,
        capacity: capacity,
        startTime: DateTime.now(),
        status: 'on_trip',
        seatsBoarded: 0,
        seatsAvailable: capacity,
      );

      _totalCapacity = capacity;
      _seatsBoarded = 0;
      _tripStatus = 'on_trip';

      // Write trip to Firebase
      await _dbRef.child('trips/$tripId').set(_currentTrip!.toMap());

      // Start live telemetry
      final telemetryStarted = await LiveTelemetryService.startTracking(
        vehicleId: vehicleId,
        routeId: routeId,
      );

      if (!telemetryStarted) {
        debugPrint('[DRIVER_SERVICE] Failed to start telemetry');
        return false;
      }

      // Update live-telemetry with additional fields
      await _dbRef.child('live-telemetry/$vehicleId').update({
        'trip_id': tripId,
        'conductor_id': _currentEmployee?.employeeId ?? 'GUEST',
        'capacity': capacity,
        'seats_boarded': 0,
        'seats_available': capacity,
      });

      debugPrint('[DRIVER_SERVICE] Trip started: $tripId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Start trip error: $e');
      return false;
    }
  }

  /// End the current trip
  Future<Map<String, dynamic>?> endTrip() async {
    try {
      if (_currentTrip == null) {
        debugPrint('[DRIVER_SERVICE] No active trip to end');
        return null;
      }

      debugPrint('[DRIVER_SERVICE] Ending trip: ${_currentTrip!.tripId}');

      // Stop live telemetry
      await LiveTelemetryService.stopTracking();

      // Calculate trip summary
      final endTime = DateTime.now();
      final duration = endTime.difference(_currentTrip!.startTime);

      final summary = {
        'trip_id': _currentTrip!.tripId,
        'status': 'completed',
        'end_time': endTime.millisecondsSinceEpoch,
        'total_time_minutes': duration.inMinutes,
        'total_time_formatted': '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
        'seats_sold': _seatsBoarded,
        'capacity': _totalCapacity,
        'occupancy_rate': _totalCapacity > 0 ? (_seatsBoarded / _totalCapacity * 100).toStringAsFixed(1) : '0',
      };

      // Update trip in Firebase
      await _dbRef.child('trips/${_currentTrip!.tripId}').update(summary);

      // Reset state
      final tripId = _currentTrip!.tripId;
      _currentTrip = null;
      _tripStatus = 'completed';
      _seatsBoarded = 0;

      debugPrint('[DRIVER_SERVICE] Trip ended: $tripId');
      notifyListeners();

      return summary;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] End trip error: $e');
      return null;
    }
  }

  /// Pause the current trip
  void pauseTrip() {
    if (_tripStatus == 'on_trip') {
      _tripStatus = 'paused';
      notifyListeners();
    }
  }

  /// Resume the current trip
  void resumeTrip() {
    if (_tripStatus == 'paused') {
      _tripStatus = 'on_trip';
      notifyListeners();
    }
  }

  // ==================== SEAT MANAGEMENT ====================

  /// Add passengers (with debounce)
  void addPassengers(int count) {
    _seatsBoarded += count;
    if (_seatsBoarded < 0) _seatsBoarded = 0;
    if (_seatsBoarded > _totalCapacity) _seatsBoarded = _totalCapacity;

    notifyListeners();
    _debounceSeatUpdate();
  }

  /// Remove passengers (with debounce)
  void removePassengers(int count) {
    _seatsBoarded -= count;
    if (_seatsBoarded < 0) _seatsBoarded = 0;

    notifyListeners();
    _debounceSeatUpdate();
  }

  /// Set exact passenger count
  void setExactPassengers(int count) {
    _seatsBoarded = count.clamp(0, _totalCapacity);
    notifyListeners();
    _debounceSeatUpdate();
  }

  void _debounceSeatUpdate() {
    _seatUpdateDebounce?.cancel();
    _seatUpdateDebounce = Timer(const Duration(seconds: 1), () {
      _syncSeatsToBackend();
    });
  }

  Future<void> _syncSeatsToBackend() async {
    if (_currentTrip == null) return;

    try {
      final vehicleId = _currentTrip!.vehicleId;
      final tripId = _currentTrip!.tripId;

      final seatData = {
        'seats_boarded': _seatsBoarded,
        'seats_available': seatsAvailable,
      };

      // Update live-telemetry
      await _dbRef.child('live-telemetry/$vehicleId').update(seatData);

      // Update trip record
      await _dbRef.child('trips/$tripId').update(seatData);

      debugPrint('[DRIVER_SERVICE] Seats synced: boarded=$_seatsBoarded, available=$seatsAvailable');
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Seat sync error: $e');
      // Queue for offline sync
      _offlineSeatQueue.add({
        'seats_boarded': _seatsBoarded,
        'seats_available': seatsAvailable,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Sync offline seat updates when reconnected
  Future<void> syncOfflineUpdates() async {
    if (_offlineSeatQueue.isEmpty || _currentTrip == null) return;

    try {
      // Get the latest update
      final latestUpdate = _offlineSeatQueue.last;

      await _dbRef.child('live-telemetry/${_currentTrip!.vehicleId}').update({
        'seats_boarded': latestUpdate['seats_boarded'],
        'seats_available': latestUpdate['seats_available'],
      });

      _offlineSeatQueue.clear();
      debugPrint('[DRIVER_SERVICE] Offline updates synced');
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Offline sync error: $e');
    }
  }

  // ==================== EMERGENCY ====================

  /// Send emergency alert
  Future<bool> sendEmergencyAlert({String? message}) async {
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );

      final emergencyId = 'EMG-${DateTime.now().millisecondsSinceEpoch}';

      final alert = EmergencyAlert(
        emergencyId: emergencyId,
        vehicleId: _currentTrip?.vehicleId ?? 'UNKNOWN',
        routeId: _currentTrip?.routeId ?? 'UNKNOWN',
        conductorId: _currentEmployee?.employeeId ?? 'GUEST',
        lat: position.latitude,
        lon: position.longitude,
        timestamp: DateTime.now(),
        status: 'open',
        message: message,
      );

      await _dbRef.child('emergencies/$emergencyId').set(alert.toMap());

      debugPrint('[DRIVER_SERVICE] Emergency alert sent: $emergencyId');
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Emergency alert error: $e');
      return false;
    }
  }

  // ==================== ALERTS & MODIFICATIONS ====================

  /// Report delay or route change
  Future<bool> reportAlert({required String reason, required int delayMinutes}) async {
    try {
      if (_currentTrip == null) return false;

      final alertId = 'ALERT-${DateTime.now().millisecondsSinceEpoch}';

      final alert = TripAlert(
        alertId: alertId,
        tripId: _currentTrip!.tripId,
        reason: reason,
        delayMinutes: delayMinutes,
        timestamp: DateTime.now(),
      );

      await _dbRef.child('trip_alerts/${_currentTrip!.tripId}/$alertId').set(alert.toMap());

      debugPrint('[DRIVER_SERVICE] Alert reported: $alertId');
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Report alert error: $e');
      return false;
    }
  }

  /// Request reduced service
  Future<bool> requestReducedService() async {
    try {
      if (_currentTrip == null) return false;

      await _dbRef.child('trips/${_currentTrip!.tripId}/reduced_service').set(true);

      debugPrint('[DRIVER_SERVICE] Reduced service requested');
      return true;
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Reduced service error: $e');
      return false;
    }
  }

  // ==================== PASSENGER VALIDATION ====================

  /// Validate passenger pass/ticket
  Future<Map<String, dynamic>?> validatePass(String passId) async {
    try {
      final snapshot = await _dbRef.child('passes/$passId').get();

      if (!snapshot.exists) {
        return {'valid': false, 'reason': 'Pass not found'};
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch((data['expiry'] as num?)?.toInt() ?? 0);

      if (expiryDate.isBefore(DateTime.now())) {
        return {'valid': false, 'reason': 'Pass expired'};
      }

      return {
        'valid': true,
        'pass_id': passId,
        'type': data['type'],
        'holder_name': data['holder_name'],
        'expiry': expiryDate.toIso8601String(),
      };
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Validate pass error: $e');
      return {'valid': false, 'reason': 'Validation error'};
    }
  }

  /// Record manual boarding
  Future<void> recordManualBoarding(String passengerInfo) async {
    try {
      if (_currentTrip == null) return;

      final boardingId = 'BOARD-${DateTime.now().millisecondsSinceEpoch}';

      await _dbRef.child('trips/${_currentTrip!.tripId}/manual_boardings/$boardingId').set({
        'passenger_info': passengerInfo,
        'timestamp': ServerValue.timestamp,
      });

      // Also increment seats
      addPassengers(1);

      debugPrint('[DRIVER_SERVICE] Manual boarding recorded');
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Manual boarding error: $e');
    }
  }

  // ==================== COMPLIANCE ====================

  /// Start duty
  Future<void> startDuty() async {
    try {
      if (_currentEmployee == null) return;

      final logId = 'LOG-${DateTime.now().millisecondsSinceEpoch}';

      final log = DutyLog(
        logId: logId,
        employeeId: _currentEmployee!.employeeId,
        startTime: DateTime.now(),
        status: 'on_duty',
      );

      await _dbRef.child('drivers/${_currentEmployee!.employeeId}/duty_logs/$logId').set(log.toMap());

      debugPrint('[DRIVER_SERVICE] Duty started');
    } catch (e) {
      debugPrint('[DRIVER_SERVICE] Start duty error: $e');
    }
  }

  @override
  void dispose() {
    _seatUpdateDebounce?.cancel();
    super.dispose();
  }
}

