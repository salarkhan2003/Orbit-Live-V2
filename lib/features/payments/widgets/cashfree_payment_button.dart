import 'package:flutter/material.dart';
import 'package:public_transport_tracker/core/cashfree_payment_service.dart';

class CashfreePaymentButton extends StatefulWidget {
  final double distanceInKm;
  final String source;
  final String destination;
  final Function(Map<String, dynamic>) onPaymentResult;

  const CashfreePaymentButton({
    super.key,
    required this.distanceInKm,
    required this.source,
    required this.destination,
    required this.onPaymentResult,
  });

  @override
  State<CashfreePaymentButton> createState() => _CashfreePaymentButtonState();
}

class _CashfreePaymentButtonState extends State<CashfreePaymentButton> {
  bool _isLoading = false;
  late double fare;

  @override
  void initState() {
    super.initState();
    fare = CashfreePaymentService.calculateFare(widget.distanceInKm);
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate unique order ID
      final orderId = CashfreePaymentService.generateOrderId();
      
      // Get current user details (in a real app, you would get this from your auth service)
      final customerName = 'Passenger User';
      final customerEmail = 'passenger@example.com';
      final customerPhone = '+919876543210';

      // Create order on Cashfree server
      final orderResponse = await CashfreePaymentService.createOrder(
        amount: fare,
        orderId: orderId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        source: widget.source,
        destination: widget.destination,
      );

      if (!orderResponse['success']) {
        if (mounted) {
          widget.onPaymentResult({
            'status': 'error',
            'message': orderResponse['error'] ?? 'Failed to create order',
          });
        }
        return;
      }

      // For web-based payment, we'll show a success message
      // In a real implementation, you would redirect to Cashfree's payment page
      // or use their web SDK
      
      // Simulate successful payment for demonstration
      await CashfreePaymentService.storePaymentInFirestore(
        orderId: orderId,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: fare,
        status: 'success',
        source: widget.source,
        destination: widget.destination,
      );

      if (mounted) {
        widget.onPaymentResult({
          'status': 'success',
          'message': 'Payment successful',
          'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
        });
      }
    } catch (e) {
      if (mounted) {
        widget.onPaymentResult({
          'status': 'error',
          'message': 'Payment failed: $e',
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006064), // Teal color matching app theme
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.payment,
                    size: 22,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pay ${CashfreePaymentService.formatFare(fare)} via Cashfree',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}