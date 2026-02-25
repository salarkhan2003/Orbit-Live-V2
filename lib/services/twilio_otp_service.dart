import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Twilio OTP Service for phone verification
class TwilioOtpService {
  // Twilio Credentials - ORBIT LIVE
  // TODO: Move these to environment variables or secure backend
  static const String _accountSid = String.fromEnvironment('TWILIO_ACCOUNT_SID', defaultValue: '');
  static const String _authToken = String.fromEnvironment('TWILIO_AUTH_TOKEN', defaultValue: '');
  static const String _serviceSid = String.fromEnvironment('TWILIO_SERVICE_SID', defaultValue: '');

  /// Send OTP to phone number
  /// Returns true if OTP sent successfully
  static Future<bool> sendOtp(String phoneNumber) async {
    try {
      // Format phone number (ensure it has country code)
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      debugPrint('[TWILIO] Sending OTP to: $formattedPhone');

      final url = Uri.parse(
        'https://verify.twilio.com/v2/Services/$_serviceSid/Verifications'
      );

      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedPhone,
          'Channel': 'sms',
        },
      );

      debugPrint('[TWILIO] Send OTP Response: ${response.statusCode}');
      debugPrint('[TWILIO] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[TWILIO] OTP sent successfully. Status: ${data['status']}');
        return true;
      } else {
        debugPrint('[TWILIO] Failed to send OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('[TWILIO] Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP code
  /// Returns true if OTP is valid
  static Future<bool> verifyOtp(String phoneNumber, String code) async {
    try {
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      debugPrint('[TWILIO] Verifying OTP for: $formattedPhone');

      final url = Uri.parse(
        'https://verify.twilio.com/v2/Services/$_serviceSid/VerificationCheck'
      );

      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedPhone,
          'Code': code,
        },
      );

      debugPrint('[TWILIO] Verify OTP Response: ${response.statusCode}');
      debugPrint('[TWILIO] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        debugPrint('[TWILIO] Verification status: $status');
        return status == 'approved';
      } else {
        debugPrint('[TWILIO] Verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('[TWILIO] Error verifying OTP: $e');
      return false;
    }
  }

  /// Format phone number with country code
  static String _formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or parentheses
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If it doesn't start with +, assume Indian number and add +91
    if (!cleaned.startsWith('+')) {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      cleaned = '+91$cleaned';
    }

    return cleaned;
  }
}

