/// Driver/Conductor Employee model for login and session management
class DriverEmployee {
  final String employeeId;
  final String name;
  final String role; // 'driver' or 'conductor'
  final String depot;
  final List<String> assignedRoutes;
  final String? phoneNumber;
  final DateTime? lastLogin;

  DriverEmployee({
    required this.employeeId,
    required this.name,
    required this.role,
    required this.depot,
    this.assignedRoutes = const [],
    this.phoneNumber,
    this.lastLogin,
  });

  factory DriverEmployee.fromFirebase(String id, Map<dynamic, dynamic> data) {
    return DriverEmployee(
      employeeId: id,
      name: data['name']?.toString() ?? 'Unknown',
      role: data['role']?.toString() ?? 'driver',
      depot: data['depot']?.toString() ?? 'Main Depot',
      assignedRoutes: (data['assigned_routes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      phoneNumber: data['phone']?.toString(),
      lastLogin: data['last_login'] != null ? DateTime.fromMillisecondsSinceEpoch(data['last_login'] as int) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'name': name,
      'role': role,
      'depot': depot,
      'assigned_routes': assignedRoutes,
      'phone': phoneNumber,
      'last_login': DateTime.now().millisecondsSinceEpoch,
    };
  }

  bool get isDriver => role == 'driver';
  bool get isConductor => role == 'conductor';
}

/// Trip model for start/end trip tracking
class DriverTrip {
  final String tripId;
  final String vehicleId;
  final String routeId;
  final String conductorId;
  final String source;
  final String destination;
  final int capacity;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'on_trip', 'paused', 'completed'
  final int seatsBoarded;
  final int seatsAvailable;
  final double? distanceTravelled;
  final bool reducedService;

  DriverTrip({
    required this.tripId,
    required this.vehicleId,
    required this.routeId,
    required this.conductorId,
    required this.source,
    required this.destination,
    required this.capacity,
    required this.startTime,
    this.endTime,
    this.status = 'on_trip',
    this.seatsBoarded = 0,
    this.seatsAvailable = 0,
    this.distanceTravelled,
    this.reducedService = false,
  });

  factory DriverTrip.fromFirebase(String id, Map<dynamic, dynamic> data) {
    return DriverTrip(
      tripId: id,
      vehicleId: data['vehicle_id']?.toString() ?? '',
      routeId: data['route_id']?.toString() ?? '',
      conductorId: data['conductor_id']?.toString() ?? '',
      source: data['source']?.toString() ?? '',
      destination: data['destination']?.toString() ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 40,
      startTime: DateTime.fromMillisecondsSinceEpoch((data['start_time'] as num?)?.toInt() ?? 0),
      endTime: data['end_time'] != null ? DateTime.fromMillisecondsSinceEpoch((data['end_time'] as num).toInt()) : null,
      status: data['status']?.toString() ?? 'on_trip',
      seatsBoarded: (data['seats_boarded'] as num?)?.toInt() ?? 0,
      seatsAvailable: (data['seats_available'] as num?)?.toInt() ?? 0,
      distanceTravelled: (data['distance_travelled'] as num?)?.toDouble(),
      reducedService: data['reduced_service'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'vehicle_id': vehicleId,
      'route_id': routeId,
      'conductor_id': conductorId,
      'source': source,
      'destination': destination,
      'capacity': capacity,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'status': status,
      'seats_boarded': seatsBoarded,
      'seats_available': seatsAvailable,
      'distance_travelled': distanceTravelled,
      'reduced_service': reducedService,
    };
  }

  DriverTrip copyWith({
    String? status,
    DateTime? endTime,
    int? seatsBoarded,
    int? seatsAvailable,
    double? distanceTravelled,
    bool? reducedService,
  }) {
    return DriverTrip(
      tripId: tripId,
      vehicleId: vehicleId,
      routeId: routeId,
      conductorId: conductorId,
      source: source,
      destination: destination,
      capacity: capacity,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      seatsBoarded: seatsBoarded ?? this.seatsBoarded,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      distanceTravelled: distanceTravelled ?? this.distanceTravelled,
      reducedService: reducedService ?? this.reducedService,
    );
  }

  Duration get tripDuration => (endTime ?? DateTime.now()).difference(startTime);
  String get formattedDuration {
    final d = tripDuration;
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
}

/// Emergency alert model
class EmergencyAlert {
  final String emergencyId;
  final String vehicleId;
  final String routeId;
  final String conductorId;
  final double lat;
  final double lon;
  final DateTime timestamp;
  final String status; // 'open', 'acknowledged', 'resolved'
  final String? message;

  EmergencyAlert({
    required this.emergencyId,
    required this.vehicleId,
    required this.routeId,
    required this.conductorId,
    required this.lat,
    required this.lon,
    required this.timestamp,
    this.status = 'open',
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicle_id': vehicleId,
      'route_id': routeId,
      'conductor_id': conductorId,
      'lat': lat,
      'lon': lon,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'message': message,
    };
  }
}

/// Trip alert model for delays/detours
class TripAlert {
  final String alertId;
  final String tripId;
  final String reason;
  final int delayMinutes;
  final DateTime timestamp;

  TripAlert({
    required this.alertId,
    required this.tripId,
    required this.reason,
    required this.delayMinutes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'reason': reason,
      'delay_minutes': delayMinutes,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// Payment record for QR ticketing
class PaymentRecord {
  final String paymentId;
  final String tripId;
  final String fromStop;
  final String toStop;
  final double fare;
  final String status; // 'pending', 'settled'
  final DateTime timestamp;

  PaymentRecord({
    required this.paymentId,
    required this.tripId,
    required this.fromStop,
    required this.toStop,
    required this.fare,
    this.status = 'pending',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'from_stop': fromStop,
      'to_stop': toStop,
      'fare': fare,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// Duty log for compliance tracking
class DutyLog {
  final String logId;
  final String employeeId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<DateTime> breaksTaken;
  final String status; // 'on_duty', 'on_break', 'off_duty'

  DutyLog({
    required this.logId,
    required this.employeeId,
    required this.startTime,
    this.endTime,
    this.breaksTaken = const [],
    this.status = 'on_duty',
  });

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'breaks_taken': breaksTaken.map((b) => b.millisecondsSinceEpoch).toList(),
      'status': status,
    };
  }

  Duration get totalDutyTime => (endTime ?? DateTime.now()).difference(startTime);
  bool get needsBreak => totalDutyTime.inHours >= 4 && breaksTaken.isEmpty;
}

