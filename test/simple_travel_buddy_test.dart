import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/features/travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../lib/features/travel_buddy/domain/travel_buddy_models.dart';

void main() {
  group('TravelBuddy Basic Tests', () {
    testWidgets('TravelBuddyProvider initializes correctly', (tester) async {
      final provider = TravelBuddyProvider();
      
      expect(provider.matches, isEmpty);
      expect(provider.pendingRequests, isEmpty);
      expect(provider.activeConnections, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.isSearching, false);
    });

    testWidgets('TravelBuddyProfile model works correctly', (tester) async {
      final profile = TravelBuddyProfile(
        id: '1',
        name: 'Test User',
        route: 'Test Route',
        travelTime: DateTime.now(),
        genderPreference: GenderPreference.any,
        languages: ['English'],
      );
      
      expect(profile.id, '1');
      expect(profile.name, 'Test User');
      expect(profile.route, 'Test Route');
      expect(profile.genderPreference, GenderPreference.any);
      expect(profile.languages, contains('English'));
    });

    testWidgets('TravelBuddyPreferences model works correctly', (tester) async {
      final preferences = TravelBuddyPreferences(
        genderPreference: GenderPreference.female,
        preferredLanguages: ['English', 'Spanish'],
        maxDistanceKm: 10,
        timeWindowMinutes: 60,
      );
      
      expect(preferences.genderPreference, GenderPreference.female);
      expect(preferences.preferredLanguages, contains('English'));
      expect(preferences.preferredLanguages, contains('Spanish'));
      expect(preferences.maxDistanceKm, 10);
      expect(preferences.timeWindowMinutes, 60);
    });

    testWidgets('BuddyRequest model works correctly', (tester) async {
      final request = BuddyRequest(
        id: '1',
        senderId: 'sender1',
        receiverId: 'receiver1',
        route: 'Test Route',
        travelTime: DateTime.now(),
        status: BuddyRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      
      expect(request.id, '1');
      expect(request.senderId, 'sender1');
      expect(request.receiverId, 'receiver1');
      expect(request.status, BuddyRequestStatus.pending);
    });

    testWidgets('TravelBuddyConnection model works correctly', (tester) async {
      final connection = TravelBuddyConnection(
        id: '1',
        userId1: 'user1',
        userId2: 'user2',
        route: 'Test Route',
        travelTime: DateTime.now(),
        connectedAt: DateTime.now(),
      );
      
      expect(connection.id, '1');
      expect(connection.userId1, 'user1');
      expect(connection.userId2, 'user2');
      expect(connection.isActive, true);
    });

    testWidgets('TravelBuddyLocation model works correctly', (tester) async {
      final location = TravelBuddyLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
      );
      
      expect(location.latitude, 37.7749);
      expect(location.longitude, -122.4194);
      expect(location.timestamp, isA<DateTime>());
    });
  });
}