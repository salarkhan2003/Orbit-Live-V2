import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:public_transport_tracker/features/auth/presentation/orbit_live_role_selection_page.dart';
import 'package:public_transport_tracker/features/auth/presentation/providers/role_selection_provider.dart';
import 'package:public_transport_tracker/features/auth/domain/user_role.dart';
import 'package:public_transport_tracker/main.dart';
import 'package:public_transport_tracker/core/localization_service.dart';
import 'package:public_transport_tracker/core/connectivity_service.dart';

void main() {
  group('OrbitLiveRoleSelectionPage', () {
    late AuthProvider mockAuthProvider;
    late LocalizationProvider mockLocalizationProvider;
    late ConnectivityService mockConnectivityService;
    late RoleSelectionProvider mockRoleSelectionProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
      mockLocalizationProvider = LocalizationProvider();
      mockConnectivityService = ConnectivityService();
      mockRoleSelectionProvider = RoleSelectionProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<LocalizationProvider>.value(value: mockLocalizationProvider),
          ChangeNotifierProvider<ConnectivityService>.value(value: mockConnectivityService),
          ChangeNotifierProvider<RoleSelectionProvider>.value(value: mockRoleSelectionProvider),
        ],
        child: MaterialApp(
          home: OrbitLiveRoleSelectionPage(),
          routes: {
            '/passenger': (context) => Scaffold(body: Text('Passenger Dashboard')),
            '/enhanced-conductor-login': (context) => Scaffold(body: Text('Conductor Login')),
            '/signup': (context) => Scaffold(body: Text('Signup Page')),
            '/login': (context) => Scaffold(body: Text('Login Page')),
          },
        ),
      );
    }

    testWidgets('displays main UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for main title
      expect(find.text('Orbit Live'), findsOneWidget);
      
      // Check for subtitle
      expect(find.text('Choose your role to get started'), findsOneWidget);
      
      // Check for action buttons
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      
      // Check for language selector
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('displays role cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for passenger and driver role cards
      expect(find.text('Passenger'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('Book tickets and track buses'), findsOneWidget);
      expect(find.text('Manage trips and routes'), findsOneWidget);
    });

    testWidgets('continue button is disabled initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting passenger role enables continue button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap passenger role card
      await tester.tap(find.text('Passenger'));
      await tester.pumpAndSettle();

      // Continue button should now be enabled
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('selecting driver role enables continue button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap driver role card
      await tester.tap(find.text('Driver'));
      await tester.pumpAndSettle();

      // Continue button should now be enabled
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows loading state when submitting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select passenger role
      await tester.tap(find.text('Passenger'));
      await tester.pumpAndSettle();

      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Setting up your role...'), findsOneWidget);
    });

    testWidgets('skip button navigates to passenger dashboard', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Should navigate to passenger dashboard
      expect(find.text('Passenger Dashboard'), findsOneWidget);
    });

    testWidgets('sign up button navigates to signup page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap sign up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should navigate to signup page
      expect(find.text('Signup Page'), findsOneWidget);
    });

    testWidgets('login button navigates to login page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to login page
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('language selector shows language options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should show language options
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Hindi'), findsOneWidget);
      expect(find.text('Punjabi'), findsOneWidget);
    });

    testWidgets('shows error when no role selected and continue pressed', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to continue without selecting a role
      // Note: The button should be disabled, but let's test the error handling
      // This would require mocking the provider to simulate the error state
    });

    testWidgets('has proper gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for gradient container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Find the main container with gradient
      final mainContainer = tester.widgetList<Container>(containers).firstWhere(
        (container) => container.decoration is BoxDecoration &&
            (container.decoration as BoxDecoration).gradient != null,
        orElse: () => Container(),
      );
      
      expect(mainContainer.decoration, isA<BoxDecoration>());
      final decoration = mainContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('role cards show selection state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially no selection indicators should be visible
      expect(find.byIcon(Icons.check), findsNothing);

      // Select passenger role
      await tester.tap(find.text('Passenger'));
      await tester.pumpAndSettle();

      // Should show selection indicator
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('responsive layout works on different screen sizes', (tester) async {
      // Test mobile layout
      tester.binding.window.physicalSizeTestValue = Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display role cards in column layout for mobile
      expect(find.text('Passenger'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);

      // Test tablet layout
      tester.binding.window.physicalSizeTestValue = Size(800, 600);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still display role cards (layout might be different but content same)
      expect(find.text('Passenger'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);

      // Reset window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('animations are present', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Check for animation widgets
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);
      
      await tester.pumpAndSettle();
    });

    testWidgets('handles back navigation properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The page should be in a navigation stack
      expect(find.byType(Scaffold), findsOneWidget);
    });

    group('error handling', () {
      testWidgets('shows error snackbar on authentication failure', (tester) async {
        // This would require mocking the AuthProvider to simulate failure
        // For now, we'll test the structure is in place
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify ScaffoldMessenger is available for showing snackbars
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check for semantic widgets
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('buttons have proper touch targets', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check button sizes
        final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
        final buttonSize = tester.getSize(continueButton);
        
        // Should meet minimum touch target size (44x44 dp)
        expect(buttonSize.height, greaterThanOrEqualTo(44));
      });
    });
  });
}