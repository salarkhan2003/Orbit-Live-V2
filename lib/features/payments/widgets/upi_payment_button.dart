import 'package:flutter/material.dart';
import 'package:public_transport_tracker/core/upi_payment_service.dart';
import '../presentation/static_upi_qr_screen.dart';

class UpiPaymentButton extends StatefulWidget {
  final double distanceInKm;
  final String source;
  final String destination;
  final VoidCallback? onPaymentInitiated;
  final Function(UpiPaymentResult)? onPaymentResult;

  const UpiPaymentButton({
    super.key,
    required this.distanceInKm,
    required this.source,
    required this.destination,
    this.onPaymentInitiated,
    this.onPaymentResult,
  });

  @override
  State<UpiPaymentButton> createState() => _UpiPaymentButtonState();
}

class _UpiPaymentButtonState extends State<UpiPaymentButton> {
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Calculate fare
      final fare = UpiPaymentService.calculateFare(widget.distanceInKm);
      
      // Launch UPI payment
      final result = await UpiPaymentService.launchUPIPayment(
        amount: fare,
        source: widget.source,
        destination: widget.destination,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Notify parent of payment result
        widget.onPaymentResult?.call(result);
        
        // Show appropriate message based on result
        if (result.status == UpiPaymentStatus.pending) {
          widget.onPaymentInitiated?.call();
          // For pending payments, we don't show a snackbar as the user needs to complete the payment
        } else if (result.status == UpiPaymentStatus.noUpiApp) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
          
          // Show QR code as fallback
          _showQrCode(context, fare);
        } else if (result.status == UpiPaymentStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error initiating payment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        
        widget.onPaymentResult?.call(
          UpiPaymentResult(
            status: UpiPaymentStatus.failure,
            message: 'Error initiating payment: $e',
          ),
        );
      }
    }
  }

  void _showQrCode(BuildContext context, double amount) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StaticUpiQrScreen(
          amount: amount,
          source: widget.source,
          destination: widget.destination,
          distanceInKm: widget.distanceInKm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fare = UpiPaymentService.calculateFare(widget.distanceInKm);
    
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handlePayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006064), // Teal color
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: _isProcessing
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text('Processing...'),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Pay ${UpiPaymentService.formatFare(fare)} via UPI',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}