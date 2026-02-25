import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CashfreePaymentService {
  // TODO: Move these to environment variables or secure backend
  static const String _appId = String.fromEnvironment('CASHFREE_APP_ID', defaultValue: '');
  static const String _secretKey = String.fromEnvironment('CASHFREE_SECRET_KEY', defaultValue: '');
  
  // For production use, you should move this to a secure backend
  // This is just for demonstration purposes
  static const String _baseUrl = "https://api.cashfree.com";
  
  // Environment - change to PRODUCTION for release
  static String get environment => 
      Platform.isAndroid ? "PRODUCTION" : "SANDBOX";

  // Calculate fare based on distance
  static double calculateFare(double distanceInKm) {
    // Minimum fare is ₹5
    // ₹2 per km after that
    final baseFare = 5.0;
    if (distanceInKm <= 0) return baseFare;
    return baseFare + (distanceInKm * 2.0);
  }

  // Format fare for display
  static String formatFare(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Format fare breakdown for display
  static String formatFareBreakdown(double distanceInKm) {
    if (distanceInKm <= 0) return 'RTC Fixed Fare';
    final baseFare = 5.0;
    final distanceFare = distanceInKm * 2.0;
    return 'Base: ₹${baseFare.toStringAsFixed(2)} + Distance: ₹${distanceFare.toStringAsFixed(2)}';
  }

  // Create order on Cashfree server
  static Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String source,
    required String destination,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/pg/orders');
      
      final body = {
        "order_id": orderId,
        "order_amount": amount,
        "order_currency": "INR",
        "customer_details": {
          "customer_id": "customer_${DateTime.now().millisecondsSinceEpoch}",
          "customer_name": customerName,
          "customer_email": customerEmail,
          "customer_phone": customerPhone,
        },
        "order_meta": {
          "notify_url": "https://your-domain.com/webhook/cashfree",
          "return_url": "https://your-domain.com/return"
        },
        "order_note": "Ticket booking from $source to $destination",
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-version': '2023-08-01',
          'X-Client-Id': _appId,
          'X-Client-Secret': _secretKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'payment_session_id': data['payment_session_id'],
          'order_id': data['order_id'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create order: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred: $e',
      };
    }
  }

  // Store payment in Firestore
  static Future<void> storePaymentInFirestore({
    required String orderId,
    required String transactionId,
    required double amount,
    required String status,
    required String source,
    required String destination,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('payments').add({
        'orderId': orderId,
        'transactionId': transactionId,
        'amount': amount,
        'status': status,
        'source': source,
        'destination': destination,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error storing payment in Firestore: $e');
    }
  }

  // Generate unique order ID
  static String generateOrderId() {
    return 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  }
}