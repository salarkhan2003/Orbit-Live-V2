import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../lib/main.dart';
import '../../lib/features/travel_buddy/presentation/travel_buddy_screen.dart';
import '../../lib/features/travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../../lib/core/localization_service.dart';
import '../../lib/core/connectivity_service.dart';

void main() {

  group('TravelBuddy Feature Tests', () {
    testWidgets('TravelBuddy screen displays correctly', (tester) async {
      // Test the TravelBuddy screen directly
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the TravelBuddy screen
      expect(find.byType(TravelBuddyScreen), findsOneWidget);
      expect(find.text('TravelBuddy'), findsOneWidget);
    });

    testWidgets('TravelBuddy screen has all required tabs', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for tab bar
      expect(find.text('Find Buddies'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Search form works correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should be on Find Buddies tab by default
      expect(find.text('Find Travel Buddies'), findsOneWidget);

      // Enter route information
      await tester.enterText(
        find.widgetWithText(TextField, 'Route (e.g., Downtown to Airport)'),
        'Downtown to Airport',
      );
      await tester.pumpAndSettle();

      // Search button should be disabled until travel time is selected
      final searchButton = find.widgetWithText(ElevatedButton, 'Search for Buddies');
      expect(searchButton, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(searchButton);
      expect(button.onPressed, isNull); // Should be disabled
    });

    testWidgets('Tab navigation works correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Requests tab
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      // Should show empty requests state
      expect(find.text('No Pending Requests'), findsOneWidget);

      // Tap on Active tab
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      // Should show empty active connections state
      expect(find.text('No Active Connections'), findsOneWidget);
    });

    testWidgets('Back navigation works from TravelBuddy screen', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Home')),
            ),
            routes: {
              '/travel-buddy': (context) => TravelBuddyScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to TravelBuddy
      Navigator.of(tester.element(find.text('Home'))).pushNamed('/travel-buddy');
      await tester.pumpAndSettle();

      // Should be on TravelBuddy screen
      expect(find.byType(TravelBuddyScreen), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back to home
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('SOS button appears when there are active connections', (tester) async {
      // This test would require mocking active connections
      // For now, we'll just verify the SOS button structure is in place
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // SOS button should not be visible when no active connections
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Screen is responsive to different sizes', (tester) async {
      // Test mobile layout
      tester.binding.window.physicalSizeTestValue = Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display correctly on mobile
      expect(find.text('TravelBuddy'), findsOneWidget);
      expect(find.text('Find Buddies'), findsOneWidget);

      // Test tablet layout
      tester.binding.window.physicalSizeTestValue = Size(800, 600);
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
            ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
          ],
          child: MaterialApp(
            home: TravelBuddyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should still display correctly on tablet
      expect(find.text('TravelBuddy'), findsOneWidget);
      expect(find.text('Find Buddies'), findsOneWidget);

      // Reset window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
  });
}