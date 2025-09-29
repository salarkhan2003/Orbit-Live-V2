import 'package:flutter/foundation.dart';

/// Represents a travel buddy user profile
class TravelBuddyProfile {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String route;
  final DateTime travelTime;
  final GenderPreference genderPreference;
  final List<String> languages;
  final double rating;
  final int completedTrips;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? bio;

  const TravelBuddyProfile({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.route,
    required this.travelTime,
    required this.genderPreference,
    required this.languages,
    this.rating = 0.0,
    this.completedTrips = 0,
    this.isOnline = false,
    this.lastSeen,
    this.bio,
  });

  TravelBuddyProfile copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    String? route,
    DateTime? travelTime,
    GenderPreference? genderPreference,
    List<String>? languages,
    double? rating,
    int? completedTrips,
    bool? isOnline,
    DateTime? lastSeen,
    String? bio,
  }) {
    return TravelBuddyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      route: route ?? this.route,
      travelTime: travelTime ?? this.travelTime,
      genderPreference: genderPreference ?? this.genderPreference,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      completedTrips: completedTrips ?? this.completedTrips,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'route': route,
      'travelTime': travelTime.toIso8601String(),
      'genderPreference': genderPreference.name,
      'languages': languages,
      'rating': rating,
      'completedTrips': completedTrips,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'bio': bio,
    };
  }

  factory TravelBuddyProfile.fromJson(Map<String, dynamic> json) {
    return TravelBuddyProfile(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      route: json['route'],
      travelTime: DateTime.parse(json['travelTime']),
      genderPreference: GenderPreference.values.firstWhere(
        (e) => e.name == json['genderPreference'],
        orElse: () => GenderPreference.any,
      ),
      languages: List<String>.from(json['languages'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      completedTrips: json['completedTrips'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      bio: json['bio'],
    );
  }
}

/// Gender preference for matching
enum GenderPreference {
  male,
  female,
  any,
}

/// Travel buddy request status
enum BuddyRequestStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// Represents a buddy request between users
class BuddyRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String route;
  final DateTime travelTime;
  final BuddyRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message;

  const BuddyRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.route,
    required this.travelTime,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  BuddyRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? route,
    DateTime? travelTime,
    BuddyRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return BuddyRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      route: route ?? this.route,
      travelTime: travelTime ?? this.travelTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'route': route,
      'travelTime': travelTime.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'message': message,
    };
  }

  factory BuddyRequest.fromJson(Map<String, dynamic> json) {
    return BuddyRequest(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      route: json['route'],
      travelTime: DateTime.parse(json['travelTime']),
      status: BuddyRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BuddyRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      message: json['message'],
    );
  }
}

/// Represents an active travel buddy connection
class TravelBuddyConnection {
  final String id;
  final String userId1;
  final String userId2;
  final String route;
  final DateTime travelTime;
  final DateTime connectedAt;
  final bool isActive;
  final TravelBuddyLocation? user1Location;
  final TravelBuddyLocation? user2Location;

  const TravelBuddyConnection({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.route,
    required this.travelTime,
    required this.connectedAt,
    this.isActive = true,
    this.user1Location,
    this.user2Location,
  });

  TravelBuddyConnection copyWith({
    String? id,
    String? userId1,
    String? userId2,
    String? route,
    DateTime? travelTime,
    DateTime? connectedAt,
    bool? isActive,
    TravelBuddyLocation? user1Location,
    TravelBuddyLocation? user2Location,
  }) {
    return TravelBuddyConnection(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      route: route ?? this.route,
      travelTime: travelTime ?? this.travelTime,
      connectedAt: connectedAt ?? this.connectedAt,
      isActive: isActive ?? this.isActive,
      user1Location: user1Location ?? this.user1Location,
      user2Location: user2Location ?? this.user2Location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'route': route,
      'travelTime': travelTime.toIso8601String(),
      'connectedAt': connectedAt.toIso8601String(),
      'isActive': isActive,
      'user1Location': user1Location?.toJson(),
      'user2Location': user2Location?.toJson(),
    };
  }

  factory TravelBuddyConnection.fromJson(Map<String, dynamic> json) {
    return TravelBuddyConnection(
      id: json['id'],
      userId1: json['userId1'],
      userId2: json['userId2'],
      route: json['route'],
      travelTime: DateTime.parse(json['travelTime']),
      connectedAt: DateTime.parse(json['connectedAt']),
      isActive: json['isActive'] ?? true,
      user1Location: json['user1Location'] != null 
          ? TravelBuddyLocation.fromJson(json['user1Location']) 
          : null,
      user2Location: json['user2Location'] != null 
          ? TravelBuddyLocation.fromJson(json['user2Location']) 
          : null,
    );
  }
}

/// Represents real-time location data for travel buddy
class TravelBuddyLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;

  const TravelBuddyLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  TravelBuddyLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? speed,
    double? heading,
  }) {
    return TravelBuddyLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'heading': heading,
    };
  }

  factory TravelBuddyLocation.fromJson(Map<String, dynamic> json) {
    return TravelBuddyLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
    );
  }
}

/// User preferences for travel buddy matching
class TravelBuddyPreferences {
  final GenderPreference genderPreference;
  final List<String> preferredLanguages;
  final int maxDistanceKm;
  final int timeWindowMinutes;
  final bool shareLocation;
  final bool allowVoiceCalls;
  final bool showOnlineStatus;

  const TravelBuddyPreferences({
    this.genderPreference = GenderPreference.any,
    this.preferredLanguages = const [],
    this.maxDistanceKm = 5,
    this.timeWindowMinutes = 30,
    this.shareLocation = true,
    this.allowVoiceCalls = false,
    this.showOnlineStatus = true,
  });

  TravelBuddyPreferences copyWith({
    GenderPreference? genderPreference,
    List<String>? preferredLanguages,
    int? maxDistanceKm,
    int? timeWindowMinutes,
    bool? shareLocation,
    bool? allowVoiceCalls,
    bool? showOnlineStatus,
  }) {
    return TravelBuddyPreferences(
      genderPreference: genderPreference ?? this.genderPreference,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      timeWindowMinutes: timeWindowMinutes ?? this.timeWindowMinutes,
      shareLocation: shareLocation ?? this.shareLocation,
      allowVoiceCalls: allowVoiceCalls ?? this.allowVoiceCalls,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genderPreference': genderPreference.name,
      'preferredLanguages': preferredLanguages,
      'maxDistanceKm': maxDistanceKm,
      'timeWindowMinutes': timeWindowMinutes,
      'shareLocation': shareLocation,
      'allowVoiceCalls': allowVoiceCalls,
      'showOnlineStatus': showOnlineStatus,
    };
  }

  factory TravelBuddyPreferences.fromJson(Map<String, dynamic> json) {
    return TravelBuddyPreferences(
      genderPreference: GenderPreference.values.firstWhere(
        (e) => e.name == json['genderPreference'],
        orElse: () => GenderPreference.any,
      ),
      preferredLanguages: List<String>.from(json['preferredLanguages'] ?? []),
      maxDistanceKm: json['maxDistanceKm'] ?? 5,
      timeWindowMinutes: json['timeWindowMinutes'] ?? 30,
      shareLocation: json['shareLocation'] ?? true,
      allowVoiceCalls: json['allowVoiceCalls'] ?? false,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
    );
  }
}