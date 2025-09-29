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
    
    _matchesController.add(matches);
    return matches;
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
    final words1 = route1.toLowerCase().split(' ');
    final words2 = route2.toLowerCase().split(' ');
    
    int commonWords = 0;
    for (String word in words1) {
      if (words2.contains(word)) {
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