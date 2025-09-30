import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/travel_buddy_models.dart';

/// Service for managing travel buddy functionality
class TravelBuddyService {
  static final TravelBuddyService _instance = TravelBuddyService._internal();
  factory TravelBuddyService() => _instance;
  TravelBuddyService._internal();

  // Mock data for demonstration
  final List<TravelBuddyProfile> _mockProfiles = [];
  final List<BuddyRequest> _mockRequests = [];
  final List<TravelBuddyConnection> _mockConnections = [];
  
  // Stream controllers for real-time updates
  final StreamController<List<TravelBuddyProfile>> _matchesController = 
      StreamController<List<TravelBuddyProfile>>.broadcast();
  final StreamController<List<BuddyRequest>> _requestsController = 
      StreamController<List<BuddyRequest>>.broadcast();
  final StreamController<List<TravelBuddyConnection>> _connectionsController = 
      StreamController<List<TravelBuddyConnection>>.broadcast();

  // Getters for streams
  Stream<List<TravelBuddyProfile>> get matchesStream => _matchesController.stream;
  Stream<List<BuddyRequest>> get requestsStream => _requestsController.stream;
  Stream<List<TravelBuddyConnection>> get connectionsStream => _connectionsController.stream;

  /// Initialize mock data
  void _initializeMockData() {
    if (_mockProfiles.isEmpty) {
      _mockProfiles.addAll([
        TravelBuddyProfile(
          id: '1',
          name: 'Sarah Johnson',
          profileImageUrl: null,
          route: 'Downtown to Airport',
          travelTime: DateTime.now().add(Duration(minutes: 15)),
          genderPreference: GenderPreference.any,
          languages: ['English', 'Spanish'],
          rating: 4.8,
          completedTrips: 23,
          isOnline: true,
          bio: 'Love meeting new people during my commute!',
        ),
        TravelBuddyProfile(
          id: '2',
          name: 'Mike Chen',
          profileImageUrl: null,
          route: 'University to Mall',
          travelTime: DateTime.now().add(Duration(minutes: 20)),
          genderPreference: GenderPreference.any,
          languages: ['English', 'Mandarin'],
          rating: 4.6,
          completedTrips: 15,
          isOnline: true,
          bio: 'Student looking for travel companions',
        ),
        TravelBuddyProfile(
          id: '3',
          name: 'Emma Wilson',
          profileImageUrl: null,
          route: 'City Center to Suburbs',
          travelTime: DateTime.now().add(Duration(minutes: 10)),
          genderPreference: GenderPreference.female,
          languages: ['English', 'French'],
          rating: 4.9,
          completedTrips: 31,
          isOnline: false,
          lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
          bio: 'Professional commuter, prefer quiet conversations',
        ),
        // Add more mock profiles for Guntur area
        TravelBuddyProfile(
          id: '4',
          name: 'Raj Kumar',
          profileImageUrl: null,
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 5)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'English'],
          rating: 4.7,
          completedTrips: 18,
          isOnline: true,
          bio: 'Daily commuter from Guntur to Tenali',
        ),
        TravelBuddyProfile(
          id: '5',
          name: 'Priya Reddy',
          profileImageUrl: null,
          route: 'Guntur to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 12)),
          genderPreference: GenderPreference.female,
          languages: ['Telugu', 'English'],
          rating: 4.5,
          completedTrips: 25,
          isOnline: true,
          bio: 'Software engineer traveling to Mangalagiri tech park',
        ),
        TravelBuddyProfile(
          id: '6',
          name: 'Arun Patel',
          profileImageUrl: null,
          route: 'RTC Bus Stand to Namburu',
          travelTime: DateTime.now().add(Duration(minutes: 8)),
          genderPreference: GenderPreference.any,
          languages: ['Hindi', 'English'],
          rating: 4.3,
          completedTrips: 12,
          isOnline: true,
          bio: 'College student looking for travel buddies',
        ),
        TravelBuddyProfile(
          id: '7',
          name: 'Lakshmi Devi',
          profileImageUrl: null,
          route: 'Guntur Central to Amaravati Road',
          travelTime: DateTime.now().add(Duration(minutes: 18)),
          genderPreference: GenderPreference.female,
          languages: ['Telugu'],
          rating: 4.9,
          completedTrips: 35,
          isOnline: false,
          lastSeen: DateTime.now().subtract(Duration(minutes: 2)),
          bio: 'Retired teacher, enjoy peaceful commutes',
        ),
        TravelBuddyProfile(
          id: '8',
          name: 'Kiran Babu',
          profileImageUrl: null,
          route: 'Lakshmipuram to Pedakakani',
          travelTime: DateTime.now().add(Duration(minutes: 25)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'English'],
          rating: 4.2,
          completedTrips: 9,
          isOnline: true,
          bio: 'New to the city, looking to make friends during commute',
        ),
        // Additional mock profiles for better matching
        TravelBuddyProfile(
          id: '9',
          name: 'Suresh Babu',
          profileImageUrl: null,
          route: 'Guntur to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 7)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'English'],
          rating: 4.6,
          completedTrips: 22,
          isOnline: true,
          bio: 'Regular traveler between Guntur and Tenali',
        ),
        TravelBuddyProfile(
          id: '10',
          name: 'Anitha Rao',
          profileImageUrl: null,
          route: 'RTC Bus Stand to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 15)),
          genderPreference: GenderPreference.female,
          languages: ['Telugu', 'English'],
          rating: 4.8,
          completedTrips: 28,
          isOnline: true,
          bio: 'Works in Mangalagiri tech park, enjoy chatting during commute',
        ),
        // Additional mock profiles for better matching
        TravelBuddyProfile(
          id: '11',
          name: 'Venkat Reddy',
          profileImageUrl: null,
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 6)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'English'],
          rating: 4.4,
          completedTrips: 15,
          isOnline: true,
          bio: 'Daily traveler to Tenali market',
        ),
        TravelBuddyProfile(
          id: '12',
          name: 'Saritha Naidu',
          profileImageUrl: null,
          route: 'RTC Bus Stand to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 14)),
          genderPreference: GenderPreference.female,
          languages: ['Telugu', 'English'],
          rating: 4.7,
          completedTrips: 22,
          isOnline: true,
          bio: 'Works in Mangalagiri hospital',
        ),
        TravelBuddyProfile(
          id: '13',
          name: 'Ramesh Babu',
          profileImageUrl: null,
          route: 'Lakshmipuram to Namburu',
          travelTime: DateTime.now().add(Duration(minutes: 9)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'Hindi'],
          rating: 4.2,
          completedTrips: 18,
          isOnline: true,
          bio: 'College professor',
        ),
        TravelBuddyProfile(
          id: '14',
          name: 'Deepika Rao',
          profileImageUrl: null,
          route: 'Gurazala to Pedakakani',
          travelTime: DateTime.now().add(Duration(minutes: 18)),
          genderPreference: GenderPreference.female,
          languages: ['Telugu', 'English'],
          rating: 4.9,
          completedTrips: 31,
          isOnline: true,
          bio: 'Software engineer',
        ),
        TravelBuddyProfile(
          id: '15',
          name: 'Srinivas Kumar',
          profileImageUrl: null,
          route: 'Guntur to Amaravati Road',
          travelTime: DateTime.now().add(Duration(minutes: 20)),
          genderPreference: GenderPreference.any,
          languages: ['Telugu', 'English'],
          rating: 4.3,
          completedTrips: 12,
          isOnline: true,
          bio: 'Business owner',
        ),
      ]);
    }
    
    // Add mock requests if none exist
    if (_mockRequests.isEmpty) {
      _mockRequests.addAll([
        BuddyRequest(
          id: 'req_1',
          senderId: '4', // Raj Kumar
          receiverId: 'test_user_123', // Current user
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 5)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 10)),
        ),
        BuddyRequest(
          id: 'req_2',
          senderId: '5', // Priya Reddy
          receiverId: 'test_user_123', // Current user
          route: 'Guntur to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 12)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 15)),
        ),
        // Additional mock requests
        BuddyRequest(
          id: 'req_3',
          senderId: '9', // Suresh Babu
          receiverId: 'test_user_123', // Current user
          route: 'Guntur to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 7)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        BuddyRequest(
          id: 'req_4',
          senderId: '10', // Anitha Rao
          receiverId: 'test_user_123', // Current user
          route: 'RTC Bus Stand to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 15)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 8)),
        ),
        // Additional mock requests
        BuddyRequest(
          id: 'req_5',
          senderId: '11', // Venkat Reddy
          receiverId: 'test_user_123', // Current user
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 6)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 12)),
        ),
        BuddyRequest(
          id: 'req_6',
          senderId: '12', // Saritha Naidu
          receiverId: 'test_user_123', // Current user
          route: 'RTC Bus Stand to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 14)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 20)),
        ),
        BuddyRequest(
          id: 'req_7',
          senderId: '14', // Deepika Rao
          receiverId: 'test_user_123', // Current user
          route: 'Gurazala to Pedakakani',
          travelTime: DateTime.now().add(Duration(minutes: 18)),
          status: BuddyRequestStatus.pending,
          createdAt: DateTime.now().subtract(Duration(minutes: 25)),
        ),
      ]);
    }
    
    // Add mock connections if none exist
    if (_mockConnections.isEmpty) {
      _mockConnections.addAll([
        TravelBuddyConnection(
          id: 'conn_1',
          userId1: 'test_user_123', // Current user
          userId2: '4', // Raj Kumar
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 5)),
          connectedAt: DateTime.now().subtract(Duration(minutes: 30)),
          isActive: true,
          user1Location: TravelBuddyLocation(
            latitude: 16.3067,
            longitude: 80.4365,
            timestamp: DateTime.now(),
          ),
          user2Location: TravelBuddyLocation(
            latitude: 16.2987,
            longitude: 80.4425,
            timestamp: DateTime.now(),
          ),
        ),
        TravelBuddyConnection(
          id: 'conn_2',
          userId1: 'test_user_123', // Current user
          userId2: '6', // Arun Patel
          route: 'RTC Bus Stand to Namburu',
          travelTime: DateTime.now().add(Duration(minutes: 8)),
          connectedAt: DateTime.now().subtract(Duration(minutes: 45)),
          isActive: true,
          user1Location: TravelBuddyLocation(
            latitude: 16.3067,
            longitude: 80.4365,
            timestamp: DateTime.now(),
          ),
          user2Location: TravelBuddyLocation(
            latitude: 16.2927,
            longitude: 80.4505,
            timestamp: DateTime.now(),
          ),
        ),
        // Additional mock connections
        TravelBuddyConnection(
          id: 'conn_3',
          userId1: 'test_user_123', // Current user
          userId2: '9', // Suresh Babu
          route: 'Guntur to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 7)),
          connectedAt: DateTime.now().subtract(Duration(minutes: 20)),
          isActive: true,
          user1Location: TravelBuddyLocation(
            latitude: 16.3067,
            longitude: 80.4365,
            timestamp: DateTime.now(),
          ),
          user2Location: TravelBuddyLocation(
            latitude: 16.3000,
            longitude: 80.4400,
            timestamp: DateTime.now(),
          ),
        ),
        TravelBuddyConnection(
          id: 'conn_4',
          userId1: 'test_user_123', // Current user
          userId2: '10', // Anitha Rao
          route: 'RTC Bus Stand to Mangalagiri',
          travelTime: DateTime.now().add(Duration(minutes: 15)),
          connectedAt: DateTime.now().subtract(Duration(minutes: 60)),
          isActive: true,
          user1Location: TravelBuddyLocation(
            latitude: 16.3067,
            longitude: 80.4365,
            timestamp: DateTime.now(),
          ),
          user2Location: TravelBuddyLocation(
            latitude: 16.2800,
            longitude: 80.4600,
            timestamp: DateTime.now(),
          ),
        ),
      ]);
    }
  }

  /// Find potential travel buddies based on route and preferences
  Future<List<TravelBuddyProfile>> findMatches({
    required String route,
    required DateTime travelTime,
    required TravelBuddyPreferences preferences,
    required String currentUserId,
  }) async {
    _initializeMockData();
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Filter matches based on criteria
    final matches = _mockProfiles.where((profile) {
      // Don't match with self
      if (profile.id == currentUserId) return false;
      
      // Check route similarity (simplified)
      if (!_isRouteSimilar(route, profile.route)) return false;
      
      // Check time window
      final timeDiff = profile.travelTime.difference(travelTime).inMinutes.abs();
      if (timeDiff > preferences.timeWindowMinutes) return false;
      
      // Check gender preference
      if (preferences.genderPreference != GenderPreference.any) {
        // In a real app, you'd have user gender data
        // For now, we'll assume all preferences match
      }
      
      // Check language compatibility
      if (preferences.preferredLanguages.isNotEmpty) {
        final hasCommonLanguage = profile.languages
            .any((lang) => preferences.preferredLanguages.contains(lang));
        if (!hasCommonLanguage) return false;
      }
      
      return true;
    }).toList();
    
    // Sort by rating and online status
    matches.sort((a, b) {
      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;
      return b.rating.compareTo(a.rating);
    });
    
    // Limit to 10 matches for better performance
    final limitedMatches = matches.length > 10 ? matches.sublist(0, 10) : matches;
    
    _matchesController.add(limitedMatches);
    return limitedMatches;
  }

  /// Send a buddy request
  Future<bool> sendBuddyRequest({
    required String senderId,
    required String receiverId,
    required String route,
    required DateTime travelTime,
    String? message,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    final request = BuddyRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      route: route,
      travelTime: travelTime,
      status: BuddyRequestStatus.pending,
      createdAt: DateTime.now(),
      message: message,
    );
    
    _mockRequests.add(request);
    _requestsController.add(_mockRequests);
    
    return true;
  }

  /// Respond to a buddy request
  Future<bool> respondToBuddyRequest({
    required String requestId,
    required bool accept,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    final requestIndex = _mockRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex == -1) return false;
    
    final request = _mockRequests[requestIndex];
    final updatedRequest = request.copyWith(
      status: accept ? BuddyRequestStatus.accepted : BuddyRequestStatus.declined,
      respondedAt: DateTime.now(),
    );
    
    _mockRequests[requestIndex] = updatedRequest;
    _requestsController.add(_mockRequests);
    
    // If accepted, create a connection
    if (accept) {
      final connection = TravelBuddyConnection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId1: request.senderId,
        userId2: request.receiverId,
        route: request.route,
        travelTime: request.travelTime,
        connectedAt: DateTime.now(),
      );
      
      _mockConnections.add(connection);
      _connectionsController.add(_mockConnections);
    }
    
    return true;
  }

  /// Get pending buddy requests for a user
  Future<List<BuddyRequest>> getPendingRequests(String userId) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final requests = _mockRequests.where((request) =>
        request.receiverId == userId && 
        request.status == BuddyRequestStatus.pending
    ).toList();
    
    return requests;
  }

  /// Get active connections for a user
  Future<List<TravelBuddyConnection>> getActiveConnections(String userId) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final connections = _mockConnections.where((connection) =>
        (connection.userId1 == userId || connection.userId2 == userId) &&
        connection.isActive
    ).toList();
    
    return connections;
  }

  /// Update user location in active connections
  Future<void> updateLocation({
    required String userId,
    required TravelBuddyLocation location,
  }) async {
    for (int i = 0; i < _mockConnections.length; i++) {
      final connection = _mockConnections[i];
      if (connection.userId1 == userId) {
        _mockConnections[i] = connection.copyWith(user1Location: location);
      } else if (connection.userId2 == userId) {
        _mockConnections[i] = connection.copyWith(user2Location: location);
      }
    }
    
    _connectionsController.add(_mockConnections);
  }

  /// Disconnect from a travel buddy
  Future<bool> disconnectBuddy(String connectionId) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final connectionIndex = _mockConnections.indexWhere((c) => c.id == connectionId);
    if (connectionIndex == -1) return false;
    
    _mockConnections[connectionIndex] = _mockConnections[connectionIndex].copyWith(
      isActive: false,
    );
    
    _connectionsController.add(_mockConnections);
    return true;
  }

  /// Send SOS alert to travel buddy and emergency contacts
  Future<bool> sendSOSAlert({
    required String userId,
    required TravelBuddyLocation location,
    String? message,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // In a real implementation, this would:
    // 1. Send alert to connected travel buddies
    // 2. Send alert to emergency contacts
    // 3. Log the emergency for admin escalation
    // 4. Potentially contact emergency services
    
    debugPrint('SOS Alert sent from user $userId at ${location.latitude}, ${location.longitude}');
    if (message != null) {
      debugPrint('SOS Message: $message');
    }
    
    return true;
  }

  /// Check if two routes are similar (simplified implementation)
  bool _isRouteSimilar(String route1, String route2) {
    // In a real implementation, this would use GPS coordinates
    // and calculate actual route similarity
    
    // Convert to lowercase for case-insensitive comparison
    final normalizedRoute1 = route1.toLowerCase();
    final normalizedRoute2 = route2.toLowerCase();
    
    // Check for exact match first
    if (normalizedRoute1 == normalizedRoute2) return true;
    
    // Check for Guntur-specific route matching
    final gunturLocations = [
      'guntur', 'guntur central', 'rtc bus stand', 'lakshmipuram', 
      'namburu', 'gurazala', 'kollipara', 'tenali', 'mangalagiri',
      'amaravati road', 'pedakakani'
    ];
    
    // Extract location keywords from both routes
    final route1Words = normalizedRoute1.split(RegExp(r'[^\w]+'));
    final route2Words = normalizedRoute2.split(RegExp(r'[^\w]+'));
    
    // Check if both routes contain the same Guntur locations
    bool hasCommonGunturLocations = false;
    for (String location in gunturLocations) {
      bool inRoute1 = route1Words.any((word) => word.contains(location) || location.contains(word));
      bool inRoute2 = route2Words.any((word) => word.contains(location) || location.contains(word));
      
      if (inRoute1 && inRoute2) {
        hasCommonGunturLocations = true;
        break;
      }
    }
    
    // Enhanced matching: check if routes have similar destinations
    bool hasSimilarDestination = false;
    final commonDestinations = ['tenali', 'mangalagiri', 'namburu', 'amaravati', 'pedakakani'];
    for (String destination in commonDestinations) {
      bool destInRoute1 = normalizedRoute1.contains(destination);
      bool destInRoute2 = normalizedRoute2.contains(destination);
      
      if (destInRoute1 && destInRoute2) {
        hasSimilarDestination = true;
        break;
      }
    }
    
    if (hasCommonGunturLocations || hasSimilarDestination) return true;
    
    // Fallback to original word matching for non-Guntur routes
    int commonWords = 0;
    for (String word in route1Words) {
      if (route2Words.contains(word)) {
        commonWords++;
      }
    }
    
    // Consider routes similar if they share at least 1 word
    return commonWords > 0;
  }

  /// Get user profile by ID
  Future<TravelBuddyProfile?> getUserProfile(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences({
    required String userId,
    required TravelBuddyPreferences preferences,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    // In a real implementation, this would save to backend
    debugPrint('Updated preferences for user $userId');
    return true;
  }

  /// Dispose resources
  void dispose() {
    _matchesController.close();
    _requestsController.close();
    _connectionsController.close();
  }
}