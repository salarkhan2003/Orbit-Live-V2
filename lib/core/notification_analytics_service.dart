import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationAnalyticsService {
  static final NotificationAnalyticsService _instance = NotificationAnalyticsService._internal();
  factory NotificationAnalyticsService() => _instance;
  NotificationAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track notification delivery
  Future<void> trackNotificationDelivery(String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notificationAnalytics').add({
        'userId': user.uid,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'delivered': true,
      });

      debugPrint('Notification delivery tracked: $category');
    } catch (e) {
      debugPrint('Error tracking notification delivery: $e');
    }
  }

  // Track notification open
  Future<void> trackNotificationOpen(String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notificationAnalytics').add({
        'userId': user.uid,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'opened': true,
      });

      debugPrint('Notification open tracked: $category');
    } catch (e) {
      debugPrint('Error tracking notification open: $e');
    }
  }

  // Track notification action (e.g., button click)
  Future<void> trackNotificationAction(String category, String action) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notificationAnalytics').add({
        'userId': user.uid,
        'category': category,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Notification action tracked: $category - $action');
    } catch (e) {
      debugPrint('Error tracking notification action: $e');
    }
  }

  // Get notification analytics for the last N days
  Future<Map<String, dynamic>> getNotificationAnalytics({int days = 30}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final snapshot = await _firestore
          .collection('notificationAnalytics')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate))
          .get();

      final analytics = <String, dynamic>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'unknown';
        final delivered = data['delivered'] as bool? ?? false;
        final opened = data['opened'] as bool? ?? false;

        if (!analytics.containsKey(category)) {
          analytics[category] = {'delivered': 0, 'opened': 0};
        }

        if (delivered) {
          analytics[category]['delivered'] += 1;
        }

        if (opened) {
          analytics[category]['opened'] += 1;
        }
      }

      return analytics;
    } catch (e) {
      debugPrint('Error getting notification analytics: $e');
      return {};
    }
  }

  // Get open rate for a specific category
  Future<double> getOpenRate(String category, {int days = 30}) async {
    try {
      final analytics = await getNotificationAnalytics(days: days);
      
      if (analytics.containsKey(category)) {
        final categoryData = analytics[category];
        final delivered = categoryData['delivered'] as int? ?? 0;
        final opened = categoryData['opened'] as int? ?? 0;
        
        if (delivered == 0) return 0.0;
        
        return opened / delivered;
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('Error calculating open rate: $e');
      return 0.0;
    }
  }

  // Save user notification preferences
  Future<void> saveNotificationPreferences(Map<String, bool> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_preferences', 
          preferences.entries.map((e) => '${e.key}:${e.value}').join(','));
      
      debugPrint('Notification preferences saved');
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  // Get user notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesString = prefs.getString('notification_preferences');
      
      if (preferencesString == null) {
        // Return default preferences
        return {
          'travel_tip': true,
          'feature_highlight': true,
          'discount': true,
          'reminder': true,
          'safety': true,
          'eco_friendly': true,
          'feedback': true,
          'advance_booking': true,
          'voice_chat': true,
          'cashback': true,
          'quiet_hours': true,
          'new_routes': true,
        };
      }
      
      final preferences = <String, bool>{};
      final pairs = preferencesString.split(',');
      
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          preferences[parts[0]] = parts[1] == 'true';
        }
      }
      
      return preferences;
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      // Return default preferences
      return {
        'travel_tip': true,
        'feature_highlight': true,
        'discount': true,
        'reminder': true,
        'safety': true,
        'eco_friendly': true,
        'feedback': true,
        'advance_booking': true,
        'voice_chat': true,
        'cashback': true,
        'quiet_hours': true,
        'new_routes': true,
      };
    }
  }

  // Update FCM token for the current user
  Future<void> updateFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM token updated for user: ${user.uid}');
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }
}