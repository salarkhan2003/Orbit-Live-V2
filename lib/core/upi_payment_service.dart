import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpiPaymentService {
  static const String upiId = 'salarkhanp@ybl';
  static const double baseFare = 5.0; // ₹5 base fare
  static const double perKilometerRate = 2.0; // ₹2 per kilometer

  // Calculate fare based on distance
  static double calculateFare(double distanceInKm) {
    if (distanceInKm <= 0) return baseFare;
    return baseFare + (distanceInKm * perKilometerRate);
  }

  // Format fare for display
  static String formatFare(double fare) {
    return '₹${fare.toStringAsFixed(2)}';
  }

  // Format fare breakdown for display
  static String formatFareBreakdown(double distanceInKm) {
    final fare = calculateFare(distanceInKm);
    if (distanceInKm <= 0) {
      return 'Fare: ${formatFare(fare)} (₹5 base)';
    }
    final distanceCost = distanceInKm * perKilometerRate;
    return 'Fare: ${formatFare(fare)} (₹5 base + ₹${distanceCost.toStringAsFixed(2)} for ${distanceInKm.toStringAsFixed(1)}km)';
  }

  // Launch UPI payment intent
  static Future<UpiPaymentResult> launchUPIPayment({
    required double amount,
    required String source,
    required String destination,
    String? transactionNote,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        return UpiPaymentResult(
          status: UpiPaymentStatus.failure,
          message: 'Invalid amount',
        );
      }

      // Create UPI URL
      final encodedSource = Uri.encodeComponent(source);
      final encodedDestination = Uri.encodeComponent(destination);
      final note = transactionNote ?? 'Bus ticket from $encodedSource to $encodedDestination';
      final upiUrl = 'upi://pay?pa=$upiId&pn=Orbit+Live&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$note';

      // Check if UPI URL can be launched
      if (await canLaunchUrl(Uri.parse(upiUrl))) {
        // Save payment attempt
        await _savePaymentAttempt(amount, source, destination);
        
        // Launch UPI payment
        final result = await launchUrl(
          Uri.parse(upiUrl),
          mode: LaunchMode.externalApplication,
        );
        
        if (result) {
          return UpiPaymentResult(
            status: UpiPaymentStatus.pending,
            message: 'Payment initiated. Please complete the transaction in your UPI app.',
          );
        } else {
          return UpiPaymentResult(
            status: UpiPaymentStatus.failure,
            message: 'Failed to launch UPI payment. Please try again.',
          );
        }
      } else {
        return UpiPaymentResult(
          status: UpiPaymentStatus.noUpiApp,
          message: 'No UPI app found. Please install a UPI app to proceed with payment.',
        );
      }
    } catch (e) {
      debugPrint('UPI Payment Error: $e');
      return UpiPaymentResult(
        status: UpiPaymentStatus.failure,
        message: 'An error occurred while processing your payment. Please try again.',
      );
    }
  }

  // Save payment attempt to SharedPreferences for tracking
  static Future<void> _savePaymentAttempt(double amount, String source, String destination) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final paymentData = '$timestamp|$amount|$source|$destination';
      
      // Get existing payment attempts
      final List<String> existingAttempts = prefs.getStringList('payment_attempts') ?? [];
      
      // Add new attempt
      existingAttempts.add(paymentData);
      
      // Keep only the last 50 attempts to prevent storage bloat
      if (existingAttempts.length > 50) {
        existingAttempts.removeRange(0, existingAttempts.length - 50);
      }
      
      await prefs.setStringList('payment_attempts', existingAttempts);
    } catch (e) {
      debugPrint('Error saving payment attempt: $e');
    }
  }

  // Get payment history
  static Future<List<PaymentAttempt>> getPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> attempts = prefs.getStringList('payment_attempts') ?? [];
      
      return attempts.map((attempt) {
        final parts = attempt.split('|');
        return PaymentAttempt(
          timestamp: int.parse(parts[0]),
          amount: double.parse(parts[1]),
          source: parts[2],
          destination: parts[3],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error retrieving payment history: $e');
      return [];
    }
  }

  // Clear payment history
  static Future<void> clearPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('payment_attempts');
    } catch (e) {
      debugPrint('Error clearing payment history: $e');
    }
  }
  
  // Verify payment completion by checking if user has returned to the app
  // This is a simplified approach - in a real app, you would use a backend service to verify
  static Future<bool> verifyPaymentCompletion() async {
    // In a real implementation, this would check with a backend service
    // For now, we'll just return true to simulate successful verification
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return true;
  }
}

// UPI Payment Result class
class UpiPaymentResult {
  final UpiPaymentStatus status;
  final String message;

  UpiPaymentResult({
    required this.status,
    required this.message,
  });
}

// Payment attempt class for history tracking
class PaymentAttempt {
  final int timestamp;
  final double amount;
  final String source;
  final String destination;

  PaymentAttempt({
    required this.timestamp,
    required this.amount,
    required this.source,
    required this.destination,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

// UPI Payment Status enum
enum UpiPaymentStatus {
  success,
  failure,
  pending,
  cancelled,
  noUpiApp,
}