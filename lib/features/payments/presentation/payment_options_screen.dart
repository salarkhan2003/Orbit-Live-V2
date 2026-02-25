import 'package:flutter/material.dart';
import 'package:public_transport_tracker/core/cashfree_payment_service.dart';
import '../widgets/cashfree_payment_button.dart';
import 'cashfree_qr_screen.dart';
import '../widgets/payment_confirmation_dialog.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final double distanceInKm;
  final String source;
  final String destination;
  final VoidCallback onPaymentSuccess;

  const PaymentOptionsScreen({
    super.key,
    required this.distanceInKm,
    required this.source,
    required this.destination,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  late double fare;

  @override
  void initState() {
    super.initState();
    fare = CashfreePaymentService.calculateFare(widget.distanceInKm);
  }

  Future<void> _handlePaymentResult(Map<String, dynamic> result) async {
    final status = result['status'];
    final message = result['message'];

    switch (status) {
      case 'success':
        if (mounted) {
          // Show confirmation dialog after payment is successful
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => PaymentConfirmationDialog(
              amount: fare,
              source: widget.source,
              destination: widget.destination,
              distanceInKm: widget.distanceInKm,
            ),
          );

          if (confirmed == true && mounted) {
            // Payment confirmed
            widget.onPaymentSuccess();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment processed successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back to previous screen
            Navigator.of(context).pop(true);
          }
        }
        break;

      case 'failure':
      case 'cancelled':
      case 'error':
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message ?? 'Payment not completed. Please try again.'),
              backgroundColor: status == 'failure' ? Colors.red : Colors.orange,
            ),
          );
        }
        break;

      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unknown payment status. Please try again.'),
              backgroundColor: Colors.grey,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
        backgroundColor: const Color(0xFF006064), // Teal color
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ticket Booking',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route: ${widget.source} to ${widget.destination}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: ${widget.distanceInKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CashfreePaymentService.formatFare(fare),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006064),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.distanceInKm > 0
                          ? CashfreePaymentService.formatFareBreakdown(widget.distanceInKm)
                          : 'RTC Fixed Fare',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            const SizedBox(height: 20),
            CashfreePaymentButton(
              distanceInKm: widget.distanceInKm,
              source: widget.source,
              destination: widget.destination,
              onPaymentResult: _handlePaymentResult,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CashfreeQrScreen(
                        amount: fare,
                        source: widget.source,
                        destination: widget.destination,
                        distanceInKm: widget.distanceInKm,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.qr_code,
                  color: Color(0xFF006064), // Teal color
                  size: 30,
                ),
                label: const Text(
                  'Show QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF006064), // Teal color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Scan the QR code with any UPI app to make payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}