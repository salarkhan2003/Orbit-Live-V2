import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse notificationResponse,
        ) async {
          // Handle notification tap
          final String? payload = notificationResponse.payload;
          if (payload != null) {
            debugPrint('Notification payload: $payload');
            // Handle deep linking based on payload
            _handleDeepLink(payload);
          }
        },
      );

      // Configure Firebase Messaging
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
      
      // Get the token and save it
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }
      
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  // Handle deep linking from notifications
  void _handleDeepLink(String payload) {
    try {
      final data = jsonDecode(payload);
      final screen = data['screen'] as String?;
      final arguments = data['arguments'] as Map<String, dynamic>? ?? {};
      
      debugPrint('Deep link to screen: $screen with arguments: $arguments');
      // In a real app, you would navigate to the specified screen
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.notification?.title}');
    
    // Show local notification
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Orbit Live',
      body: message.notification?.body ?? 'You have a new notification',
      payload: jsonEncode(message.data),
    );
  }

  // Handle background message tap
  Future<void> _handleBackgroundMessageTap(RemoteMessage message) async {
    debugPrint('Background message tapped: ${message.notification?.title}');
    // Handle navigation based on message data
    _handleDeepLink(jsonEncode(message.data));
  }

  // Show local notification with action buttons
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'orbit_live_channel',
        'Orbit Live Notifications',
        channelDescription: 'Notifications for Orbit Live app',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Orbit Live Notification',
        // Add action buttons
        actions: [
          AndroidNotificationAction('view_action', 'View'),
          AndroidNotificationAction('dismiss_action', 'Dismiss'),
        ],
      );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _localNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Send push notification via FCM
  Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // In a real implementation, this would be done on the backend
      // This is just a placeholder for the frontend implementation
      debugPrint('Would send push notification to $fcmToken: $title - $body');
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  // Save FCM token to SharedPreferences
  Future<void> _saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      debugPrint('FCM token saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Get FCM token from SharedPreferences
  Future<String?> getFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Track notification engagement
  Future<void> trackNotificationEngagement(String notificationId, String action) async {
    try {
      // In a real implementation, this would send analytics data to your backend
      debugPrint('Notification $notificationId engaged with action: $action');
    } catch (e) {
      debugPrint('Error tracking notification engagement: $e');
    }
  }

  // Send SMS using a generic SMS API (you would replace this with your actual SMS service)
  Future<void> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // This is a placeholder - you would integrate with your actual SMS service
      debugPrint('Sending SMS to $phoneNumber: $message');
      // Example API call:
      /*
      final response = await http.post(
        Uri.parse('https://api.sms-service.com/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': phoneNumber,
          'message': message,
          'apiKey': 'your-api-key',
        }),
      );
      */
    } catch (e) {
      debugPrint('Error sending SMS: $e');
    }
  }

  // Send email using Resend.com API
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      // Using Resend.com API
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer re_6wNRXr1G_KVm9qCqH97rC6uwTCTMBcJXf',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'notifications@orbitlive.com',
          'to': to,
          'subject': subject,
          'html': htmlContent,
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('Email sent successfully to $to');
      } else {
        debugPrint('Failed to send email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }
}