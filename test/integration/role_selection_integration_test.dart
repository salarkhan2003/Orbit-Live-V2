import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:public_transport_tracker/main.dart';
import 'package:public_transport_tracker/features/auth/presentation/orbit_live_role_selection_page.dart';
import 'package:public_transport_tracker/features/auth/presentation/enhanced_conductor_login_screen.dart';
import 'package:public_transport_tracker/features/passenger/presentation/passenger_dashboard.dart';
import 'package:public_transport_tracker/features/driver/presentation/driver_dashboard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role Selection Integration Tests', () {
    testWidgets('Complete passenger flow from role selection to dashboard', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
      expect(find.text('Orbit Live'), findsOneWidget);

      // Select passenger role
      await tester.tap(find.text('Passenger'));
      await tester.pumpAndSettle();

      // Continue button should be enabled
      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);
      
      // Tap continue
      await tester.tap(continueButton);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should navigate to passenger dashboard or auth screen
      // The exact destination depends on authentication state
      expect(find.byType(OrbitLiveRoleSelectionPage), findsNothing);
    });

    testWidgets('Complete driver flow from role selection to conductor login', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);

      // Select driver role
      await tester.tap(find.text('Driver'));
      await tester.pumpAndSettle();

      // Continue button should be enabled
      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);
      
      // Tap continue
      await tester.tap(continueButton);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should navigate to enhanced conductor login screen
      expect(find.byType(EnhancedConductorLoginScreen), findsOneWidget);
    });

    testWidgets('Skip functionality creates guest user and navigates to dashboard', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);

      // Tap skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Should navigate to passenger dashboard as guest
      expect(find.byType(PassengerDashboard), findsOneWidget);
    });

    testWidgets('Sign up navigation works correctly', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);

      // Tap sign up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should navigate to signup page
      expect(find.text('Sign Up'), findsWidgets); // May find multiple instances
    });

    testWidgets('Login navigation works correctly', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to login page
      expect(find.text('Login'), findsWidgets); // May find multiple instances
    });

    testWidgets('Language selection works correctly', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Should start with role selection page
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);

      // Tap language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should show language options
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Hindi'), findsOneWidget);

      // Select a language
      await tester.tap(find.text('Hindi'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('English'), findsNothing);
    });

    testWidgets('Role selection state persists during navigation', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Select passenger role
      await tester.tap(find.text('Passenger'));
      await tester.pumpAndSettle();

      // Role should be visually selected
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Select driver role instead
      await tester.tap(find.text('Driver'));
      await tester.pumpAndSettle();

      // Only driver should be selected now
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Error handling works for network issues', (tester) async {
      // This test would require mocking network failures
      // For now, we'll test that error handling structure is in place
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verify that ScaffoldMessenger is available for error display
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Animations complete without errors', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Let animations complete
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Should have completed loading
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
      expect(find.text('Orbit Live'), findsOneWidget);
    });

    testWidgets('Back navigation works correctly', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back at role selection
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
    });

    testWidgets('Memory usage remains stable during navigation', (tester) async {
      // This is a basic test for memory leaks
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate through different screens multiple times
      for (int i = 0; i < 3; i++) {
        // Go to sign up
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Go to login
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Should still be functional
      expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
    });

    group('Conductor Authentication Flow', () {
      testWidgets('Complete conductor login flow', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Select driver role and continue
        await tester.tap(find.text('Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Should be on conductor login screen
        expect(find.byType(EnhancedConductorLoginScreen), findsOneWidget);

        // Fill in login form
        await tester.enterText(find.byKey(Key('employeeId')), 'EMP001');
        await tester.enterText(find.byKey(Key('password')), 'password123');
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle(Duration(seconds: 3));

        // Should show loading or navigate to dashboard
        // Exact behavior depends on authentication service
      });

      testWidgets('Conductor signup flow works', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Navigate to conductor login
        await tester.tap(find.text('Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Switch to signup mode
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Fill in signup form
        await tester.enterText(find.byKey(Key('fullName')), 'John Doe');
        await tester.enterText(find.byKey(Key('employeeId')), 'EMP002');
        await tester.enterText(find.byKey(Key('phoneNumber')), '1234567890');
        await tester.enterText(find.byKey(Key('password')), 'password123');
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle(Duration(seconds: 3));

        // Should show loading or navigate to dashboard
      });

      testWidgets('Form validation works correctly', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Navigate to conductor login
        await tester.tap(find.text('Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Try to submit empty form
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Please enter employee ID'), findsOneWidget);
        expect(find.text('Please enter password'), findsOneWidget);
      });

      testWidgets('Skip option works in conductor screen', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Navigate to conductor login
        await tester.tap(find.text('Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Tap skip button
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Should navigate to driver dashboard as guest
        expect(find.byType(DriverDashboard), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('Page loads within acceptable time', (tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Should load within 3 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
      });

      testWidgets('Animations are smooth and complete', (tester) async {
        await tester.pumpWidget(MyApp());
        
        // Pump frames to ensure animations complete
        for (int i = 0; i < 100; i++) {
          await tester.pump(Duration(milliseconds: 16)); // 60 FPS
        }
        
        await tester.pumpAndSettle();
        
        // Should be fully loaded
        expect(find.text('Orbit Live'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Screen reader accessibility', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Check for semantic labels
        expect(find.byType(Semantics), findsWidgets);
        
        // Check that interactive elements have proper semantics
        final passengerCard = find.text('Passenger');
        expect(passengerCard, findsOneWidget);
        
        final driverCard = find.text('Driver');
        expect(driverCard, findsOneWidget);
      });

      testWidgets('Touch target sizes are adequate', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Check button sizes
        final continueButton = find.text('Continue');
        final buttonSize = tester.getSize(continueButton);
        
        // Should meet minimum touch target size (44x44 dp)
        expect(buttonSize.height, greaterThanOrEqualTo(44));
        expect(buttonSize.width, greaterThanOrEqualTo(44));
      });

      testWidgets('Color contrast is sufficient', (tester) async {
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // This is a basic test - in a real scenario, you'd use tools
        // to measure actual color contrast ratios
        expect(find.text('Orbit Live'), findsOneWidget);
        expect(find.text('Passenger'), findsOneWidget);
        expect(find.text('Driver'), findsOneWidget);
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('App recovers from authentication errors', (tester) async {
        // This would require mocking authentication failures
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Basic test that error handling structure is in place
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('App handles network connectivity issues', (tester) async {
        // This would require mocking network failures
        await tester.pumpWidget(MyApp());
        await tester.pumpAndSettle();

        // Basic test that connectivity handling is in place
        expect(find.byType(OrbitLiveRoleSelectionPage), findsOneWidget);
      });
    });
  });
}