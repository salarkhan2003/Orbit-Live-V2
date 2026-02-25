import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/payments/widgets/upi_payment_button.dart';

void main() {
  group('UpiPaymentButton', () {
    testWidgets('should display correct fare amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpiPaymentButton(
              distanceInKm: 10.0,
              source: 'Source',
              destination: 'Destination',
            ),
          ),
        ),
      );

      // For 10km: ₹5 base + (10 × ₹2) = ₹25
      expect(find.text('Pay ₹25.00 via UPI'), findsOneWidget);
    });

    testWidgets('should display processing state when pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpiPaymentButton(
              distanceInKm: 5.0,
              source: 'Source',
              destination: 'Destination',
            ),
          ),
        ),
      );

      // Initial state should show pay button
      expect(find.text('Pay ₹15.00 via UPI'), findsOneWidget);
      expect(find.text('Processing...'), findsNothing);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show processing state
      expect(find.text('Processing...'), findsOneWidget);
    });

    testWidgets('should handle zero distance correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpiPaymentButton(
              distanceInKm: 0.0,
              source: 'Source',
              destination: 'Destination',
            ),
          ),
        ),
      );

      // For 0km: ₹5 base fare
      expect(find.text('Pay ₹5.00 via UPI'), findsOneWidget);
    });
  });
}