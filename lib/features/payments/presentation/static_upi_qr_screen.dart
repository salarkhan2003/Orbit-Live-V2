import 'package:flutter/material.dart';
import 'package:public_transport_tracker/core/upi_payment_service.dart';

class StaticUpiQrScreen extends StatelessWidget {
  final double amount;
  final String source;
  final String destination;
  final double distanceInKm;

  const StaticUpiQrScreen({
    super.key,
    this.amount = 0.0,
    this.source = '',
    this.destination = '',
    this.distanceInKm = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final upiId = UpiPaymentService.upiId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with UPI QR'),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/payment/upi_qr.jpg',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
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
                    'UPI ID:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006064),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SelectableText(
                    upiId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0288D1), // Blue color
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Recipient Name: Orbit Live',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (amount > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Amount: ${UpiPaymentService.formatFare(amount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (source.isNotEmpty && destination.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Route: $source to $destination',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (distanceInKm > 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Distance: ${distanceInKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      UpiPaymentService.formatFareBreakdown(distanceInKm),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ] else if (amount > 0) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'RTC Fixed Fare',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}