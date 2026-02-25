// Vehicle telemetry model for live bus tracking
// This model represents the real-time data from Firebase /live-telemetry

class VehicleTelemetry {
  final String vehicleId;
  final double lat;
  final double lon;
  final String routeId;
  final String status;
  final bool isActive;
  final int timestamp;

  // Additional computed/stub fields
  final String? busType; // AC / Non-AC based on naming convention
  final int? seatsAvailable; // Placeholder for future implementation
  final double? speed; // Placeholder

  VehicleTelemetry({
    required this.vehicleId,
    required this.lat,
    required this.lon,
    required this.routeId,
    required this.status,
    required this.isActive,
    required this.timestamp,
    this.busType,
    this.seatsAvailable,
    this.speed,
  });

  /// Parse from Firebase snapshot data
  factory VehicleTelemetry.fromFirebase(String key, Map<dynamic, dynamic> data) {
    final vehicleId = data['vehicle_id']?.toString() ?? key;

    // Determine bus type from naming convention (stub logic)
    String? busType;
    final vehicleUpper = vehicleId.toUpperCase();
    if (vehicleUpper.contains('AC') || vehicleUpper.contains('VOLVO')) {
      busType = 'AC';
    } else {
      busType = 'Non-AC';
    }

    return VehicleTelemetry(
      vehicleId: vehicleId,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
      routeId: data['route_id']?.toString() ?? 'UNKNOWN',
      status: data['status']?.toString() ?? 'offline',
      isActive: data['is_active'] == true,
      timestamp: (data['timestamp'] as num?)?.toInt() ?? 0,
      busType: busType,
      seatsAvailable: 20, // Placeholder - will be dynamic in future
      speed: 35.0, // Placeholder - will come from GPS data in future
    );
  }

  /// Get formatted timestamp
  String get formattedTime {
    if (timestamp == 0) return 'N/A';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Get short display label
  String get displayLabel => '$routeId / $vehicleId';

  /// Check if data is stale (older than 30 seconds)
  bool get isStale {
    if (timestamp == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) > 30000; // 30 seconds
  }

  /// Get status color for UI
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'in_transit':
        return 'green';
      case 'stopped':
        return 'orange';
      case 'offline':
        return 'red';
      default:
        return 'gray';
    }
  }

  @override
  String toString() {
    return 'VehicleTelemetry{vehicleId: $vehicleId, lat: $lat, lon: $lon, routeId: $routeId, status: $status, isActive: $isActive}';
  }
}

