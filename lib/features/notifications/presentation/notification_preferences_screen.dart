import 'package:flutter/material.dart';
import '../../../core/notification_analytics_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  Map<String, bool> _preferences = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final analyticsService = NotificationAnalyticsService();
      _preferences = await analyticsService.getNotificationPreferences();
    } catch (e) {
      // Use default preferences if there's an error
      _preferences = {
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      final analyticsService = NotificationAnalyticsService();
      await analyticsService.saveNotificationPreferences(_preferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving preferences'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: OrbitLiveColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: 'Notification Preferences',
                subtitle: 'Customize your notification experience',
                showBackButton: true,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: OrbitLiveColors.primaryTeal,
                        ),
                      )
                    : _buildPreferencesList(),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrbitLiveColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesList() {
    final preferenceItems = [
      {
        'key': 'travel_tip',
        'title': 'Travel Tips',
        'description': 'Helpful tips for better travel experiences',
      },
      {
        'key': 'feature_highlight',
        'title': 'Feature Highlights',
        'description': 'New features and updates in the app',
      },
      {
        'key': 'discount',
        'title': 'Discounts & Offers',
        'description': 'Special deals and promotions',
      },
      {
        'key': 'reminder',
        'title': 'Trip Reminders',
        'description': 'Reminders to plan your next journey',
      },
      {
        'key': 'safety',
        'title': 'Safety Updates',
        'description': 'Important safety information',
      },
      {
        'key': 'eco_friendly',
        'title': 'Eco-Friendly Travel',
        'description': 'Tips for sustainable travel',
      },
      {
        'key': 'feedback',
        'title': 'Feedback Requests',
        'description': 'Requests for your valuable feedback',
      },
      {
        'key': 'advance_booking',
        'title': 'Advance Booking Tips',
        'description': 'Tips for booking in advance',
      },
      {
        'key': 'voice_chat',
        'title': 'Voice Chat Updates',
        'description': 'Updates about TravelBuddy voice chat',
      },
      {
        'key': 'cashback',
        'title': 'Cashback Offers',
        'description': 'Special cashback promotions',
      },
      {
        'key': 'quiet_hours',
        'title': 'Quiet Hours Info',
        'description': 'Information about quieter travel times',
      },
      {
        'key': 'new_routes',
        'title': 'New Routes',
        'description': 'Notifications about new bus routes',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: preferenceItems.length,
      itemBuilder: (context, index) {
        final item = preferenceItems[index];
        final key = item['key']!;
        final title = item['title']!;
        final description = item['description']!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              title,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              description,
              style: OrbitLiveTextStyles.bodyMedium,
            ),
            trailing: Switch(
              value: _preferences[key] ?? true,
              onChanged: (value) {
                setState(() {
                  _preferences[key] = value;
                });
              },
              activeColor: OrbitLiveColors.primaryTeal,
            ),
          ),
        );
      },
    );
  }
}