import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:public_transport_tracker/core/cashfree_payment_service.dart';

class CashfreeQrScreen extends StatelessWidget {
  final double amount;
  final String source;
  final String destination;
  final double distanceInKm;

  const CashfreeQrScreen({
    super.key,
    this.amount = 0.0,
    this.source = '',
    this.destination = '',
    this.distanceInKm = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a sample UPI payment string for demo purposes
    final upiString = 'upi://pay?pa=salarkhanp@ybl&pn=OrbitLive&am=$amount&cu=INR&tn=TicketBooking';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with QR Code'),
        backgroundColor: const Color(0xFF006064), // Teal color matching app theme
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code to Pay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: upiString,
                version: QrVersions.auto,
                size: 250.0,
                gapless: false,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan this QR code with any UPI app to make payment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE), // Light blue background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0288D1)), // Blue border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006064),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (source.isNotEmpty && destination.isNotEmpty) ...[
                    const Text(
                      'Route:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$source to $destination',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (distanceInKm > 0) ...[
                    const Text(
                      'Distance:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${distanceInKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Text(
                    'Amount:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    CashfreePaymentService.formatFare(amount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006064),
                    ),
                  ),
                  if (distanceInKm > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      CashfreePaymentService.formatFareBreakdown(distanceInKm),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ] else if (amount > 0) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'RTC Fixed Fare',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006064),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}