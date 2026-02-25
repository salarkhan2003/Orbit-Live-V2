import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/payments/presentation/static_upi_qr_screen.dart';

void main() {
  group('StaticUpiQrScreen', () {
    testWidgets('should display static QR code screen', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: StaticUpiQrScreen(),
        ),
      );

      // Verify that the screen title is displayed
      expect(find.text('Pay with UPI QR'), findsOneWidget);

      // Verify that the scan instruction is displayed
      expect(find.text('Scan QR Code to Pay'), findsOneWidget);

      // Verify that the UPI ID section is displayed
      expect(find.text('UPI ID:'), findsOneWidget);
    });

    testWidgets('should display payment details when provided', (WidgetTester tester) async {
      // Build the widget with payment details
      await tester.pumpWidget(
        const MaterialApp(
          home: StaticUpiQrScreen(
            amount: 11.0,
            source: 'Station A',
            destination: 'Station B',
            distanceInKm: 3.0,
          ),
        ),
      );

      // Verify that the amount is displayed
      expect(find.text('Amount: ₹11.00'), findsOneWidget);

      // Verify that the route is displayed
      expect(find.text('Route: Station A to Station B'), findsOneWidget);

      // Verify that the distance is displayed
      expect(find.text('Distance: 3.0 km'), findsOneWidget);
    });
  });
}