import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  Timer? _frequentTimer;
  final Random _random = Random();
  final int _notificationsToday = 0;

  // Expanded list of notification messages with categories and personalization placeholders
  final List<Map<String, dynamic>> _notificationTemplates = [
    {
      'category': 'travel_tip',
      'title': 'Travel Tip',
      'body': 'Avoid peak hours for a more comfortable journey!',
      'frequency': 'daily',
      'personalization': false,
    },
    {
      'category': 'feature_highlight',
      'title': 'New Feature',
      'body': 'Try our new TravelBuddy feature to find companions for your journey!',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'discount',
      'title': 'Special Offer',
      'body': 'Get 10% off on your next ticket booking. Limited time offer!',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'reminder',
      'title': 'Plan Your Next Trip',
      'body': 'Plan your next trip with discounts on passes!',
      'frequency': 'daily',
      'personalization': false,
    },
    {
      'category': 'safety',
      'title': 'Safety First',
      'body': 'Remember to wear your mask and maintain social distancing.',
      'frequency': 'daily',
      'personalization': false,
    },
    {
      'category': 'eco_friendly',
      'title': 'Eco-Friendly Travel',
      'body': 'Choose public transport to reduce your carbon footprint!',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'feedback',
      'title': 'Rate Your Experience',
      'body': 'How was your last journey? Share your feedback with us.',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'advance_booking',
      'title': 'Did you know?',
      'body': 'Booking tickets in advance gets you better prices!',
      'frequency': 'daily',
      'personalization': false,
    },
    {
      'category': 'voice_chat',
      'title': 'TravelBuddy Update',
      'body': 'TravelBuddy now supports voice chat. Try it today for safer trips.',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'cashback',
      'title': 'SPECIAL OFFER',
      'body': '15% cashback on monthly passes this week only!',
      'frequency': 'weekly',
      'personalization': false,
    },
    {
      'category': 'quiet_hours',
      'title': 'Avoid the rush hour!',
      'body': 'Check out quieter bus timings in your area.',
      'frequency': 'daily',
      'personalization': true, // Can be personalized with user location
    },
    {
      'category': 'new_routes',
      'title': 'New Routes Available',
      'body': 'Your city\'s new routes are live! Explore and plan your journey.',
      'frequency': 'weekly',
      'personalization': true, // Can be personalized with user location
    },
  ];

  // Start the notification scheduler
  void startScheduler() {
    // Schedule frequent notifications (every 10 minutes)
    _scheduleFrequentNotifications();
    
    debugPrint('Enhanced notification scheduler started');
  }

  // Stop the notification scheduler
  void stopScheduler() {
    _frequentTimer?.cancel();
    debugPrint('Enhanced notification scheduler stopped');
  }

  // Schedule frequent notifications (every 10 minutes)
  void _scheduleFrequentNotifications() {
    _frequentTimer?.cancel();
    
    // Schedule to run every 10 minutes during active hours (9 AM to 9 PM)
    const Duration interval = Duration(minutes: 10);
    _frequentTimer = Timer.periodic(interval, (timer) {
      _sendPersonalizedRandomNotification();
    });
  }

  // Send a personalized random notification
  Future<void> _sendPersonalizedRandomNotification() async {
    try {
      // Check if we've exceeded daily limit (max 3 notifications per day)
      if (await _hasExceededDailyLimit()) {
        debugPrint('Daily notification limit reached. Skipping notification.');
        return;
      }
      
      // Check if current time is within active hours (9 AM to 9 PM)
      final now = DateTime.now();
      final hour = now.hour;
      if (hour < 9 || hour >= 21) {
        debugPrint('Outside active hours. Skipping notification.');
        return;
      }
      
      // Select a random notification template
      final randomIndex = _random.nextInt(_notificationTemplates.length);
      final template = _notificationTemplates[randomIndex];
      
      // Personalize the message if needed
      final personalizedMessage = await _personalizeMessage(template);
      
      // Send the notification
      final notificationService = NotificationService();
      await notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: personalizedMessage['title']!,
        body: personalizedMessage['body']!,
        payload: jsonEncode({
          'category': template['category'],
          'screen': _getScreenForCategory(template['category']),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      // Update notification count
      await _incrementNotificationCount();
      
      debugPrint('Personalized notification sent: ${personalizedMessage['title']}');
    } catch (e) {
      debugPrint('Error sending personalized notification: $e');
    }
  }

  // Personalize message based on user data
  Future<Map<String, String>> _personalizeMessage(Map<String, dynamic> template) async {
    // In a real implementation, you would fetch user data and personalize accordingly
    // For now, we'll just return the template as-is
    return {
      'title': template['title'],
      'body': template['body'],
    };
  }

  // Get screen to navigate to based on notification category
  String _getScreenForCategory(String category) {
    switch (category) {
      case 'travel_tip':
      case 'safety':
      case 'eco_friendly':
        return 'home';
      case 'feature_highlight':
      case 'voice_chat':
        return 'travel_buddy';
      case 'discount':
      case 'cashback':
        return 'tickets';
      case 'reminder':
      case 'advance_booking':
        return 'bookings';
      case 'new_routes':
        return 'map';
      default:
        return 'home';
    }
  }

  // Check if daily notification limit has been exceeded
  Future<bool> _hasExceededDailyLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNotificationDateStr = prefs.getString('last_notification_date');
      final notificationsToday = prefs.getInt('notifications_today') ?? 0;
      
      // Reset count if it's a new day
      if (lastNotificationDateStr != null) {
        final lastNotificationDate = DateTime.parse(lastNotificationDateStr);
        if (!_isSameDay(lastNotificationDate, DateTime.now())) {
          await prefs.setInt('notifications_today', 0);
          return false;
        }
      }
      
      // Check if we've exceeded the limit (max 3 per day)
      return notificationsToday >= 3;
    } catch (e) {
      debugPrint('Error checking notification limit: $e');
      return false; // Allow notification if there's an error
    }
  }

  // Increment notification count for the day
  Future<void> _incrementNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsToday = prefs.getInt('notifications_today') ?? 0;
      await prefs.setInt('notifications_today', notificationsToday + 1);
      await prefs.setString('last_notification_date', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error incrementing notification count: $e');
    }
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Send an immediate random notification (for testing)
  Future<void> sendImmediateRandomNotification() async {
    await _sendPersonalizedRandomNotification();
  }
  
  // Send a specific notification by category
  Future<void> sendNotificationByCategory(String category) async {
    try {
      // Find template by category
      final template = _notificationTemplates.firstWhere(
        (t) => t['category'] == category,
        orElse: () => _notificationTemplates.first,
      );
      
      // Personalize the message if needed
      final personalizedMessage = await _personalizeMessage(template);
      
      // Send the notification
      final notificationService = NotificationService();
      await notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: personalizedMessage['title']!,
        body: personalizedMessage['body']!,
        payload: jsonEncode({
          'category': template['category'],
          'screen': _getScreenForCategory(template['category']),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      debugPrint('Category notification sent: ${personalizedMessage['title']}');
    } catch (e) {
      debugPrint('Error sending category notification: $e');
    }
  }
}