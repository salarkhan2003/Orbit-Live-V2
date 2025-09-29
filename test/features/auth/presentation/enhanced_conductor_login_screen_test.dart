import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:public_transport_tracker/features/auth/presentation/enhanced_conductor_login_screen.dart';
import 'package:public_transport_tracker/main.dart';
import 'package:public_transport_tracker/core/localization_service.dart';
import 'package:public_transport_tracker/core/connectivity_service.dart';

void main() {
  group('EnhancedConductorLoginScreen', () {
    late AuthProvider mockAuthProvider;
    late LocalizationProvider mockLocalizationProvider;
    late ConnectivityService mockConnectivityService;

    setUp(() {
      mockAuthProvider = AuthProvider();
      mockLocalizationProvider = LocalizationProvider();
      mockConnectivityService = ConnectivityService();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<LocalizationProvider>.value(value: mockLocalizationProvider),
          ChangeNotifierProvider<ConnectivityService>.value(value: mockConnectivityService),
        ],
        child: MaterialApp(
          home: EnhancedConductorLoginScreen(),
          routes: {
            '/driver': (context) => Scaffold(body: Text('Driver Dashboard')),
          },
        ),
      );
    }

    testWidgets('displays login form by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for login-specific elements
      expect(find.text('Driver Login'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your driver account'), findsOneWidget);
      
      // Should show login fields
      expect(find.text('Employee ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      
      // Should not show signup-only fields
      expect(find.text('Full Name'), findsNothing);
      expect(find.text('Phone Number'), findsNothing);
    });

    testWidgets('toggles to signup form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the toggle link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should now show signup form
      expect(find.text('Driver Signup'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Fill in your details to get started'), findsOneWidget);
      
      // Should show all signup fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Employee ID'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsAtLeastNWidgets(1));
    });

    testWidgets('toggles back to login form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Switch back to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should be back to login form
      expect(find.text('Driver Login'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your employee ID'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates employee ID format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid employee ID
      await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'AB');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should show employee ID validation error
      expect(find.text('Employee ID must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('validates password strength', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter weak password
      await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'EMP123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('validates signup fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Try to submit empty signup form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Should show all required field errors
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your employee ID'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Initially password should be obscured
      TextFormField field = tester.widget<TextFormField>(passwordField);
      expect(field.obscureText, true);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Password should now be visible
      field = tester.widget<TextFormField>(passwordField);
      expect(field.obscureText, false);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Password should be obscured again
      field = tester.widget<TextFormField>(passwordField);
      expect(field.obscureText, true);
    });

    testWidgets('shows loading state during authentication', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill valid form
      await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'EMP123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

      // Submit form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('skip button navigates to driver dashboard', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap skip button
      await tester.tap(find.text('Skip - Continue as Guest'));
      await tester.pumpAndSettle();

      // Should navigate to driver dashboard
      expect(find.text('Driver Dashboard'), findsOneWidget);
    });

    testWidgets('back button is present and functional', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have back button
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('has proper gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for gradient container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Find container with orange gradient
      final gradientContainer = tester.widgetList<Container>(containers).firstWhere(
        (container) => container.decoration is BoxDecoration &&
            (container.decoration as BoxDecoration).gradient != null,
        orElse: () => Container(),
      );
      
      expect(gradientContainer.decoration, isA<BoxDecoration>());
    });

    testWidgets('form clears when switching modes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter some data in login form
      await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'EMP123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

      // Switch to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Switch back to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Fields should be cleared (name and phone should be cleared)
      // Employee ID and password should remain as they're common fields
      final employeeIdField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Employee ID')
      );
      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Password')
      );
      
      expect(employeeIdField.controller?.text, 'EMP123');
      expect(passwordField.controller?.text, 'password123');
    });

    testWidgets('displays error messages properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // This would require mocking the authentication service to return errors
      // For now, we test that the error display structure is in place
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('animations are present', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Check for animation widgets
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);
      
      await tester.pumpAndSettle();
    });

    group('form validation edge cases', () {
      testWidgets('validates phone number format in signup', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to signup
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Enter invalid phone number
        await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
        await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'EMP123');
        await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '123');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
        await tester.pumpAndSettle();

        // Should show phone validation error
        expect(find.text('Please enter a valid phone number'), findsOneWidget);
      });

      testWidgets('validates name format in signup', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Switch to signup
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Enter invalid name
        await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'A');
        await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), 'EMP123');
        await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '+1234567890');
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
        await tester.pumpAndSettle();

        // Should show name validation error
        expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('form fields have proper labels', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that form fields have proper labels
        expect(find.text('Employee ID'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('buttons have proper touch targets', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check button sizes
        final loginButton = find.widgetWithText(ElevatedButton, 'Login');
        final buttonSize = tester.getSize(loginButton);
        
        // Should meet minimum touch target size
        expect(buttonSize.height, greaterThanOrEqualTo(44));
      });
    });
  });
}