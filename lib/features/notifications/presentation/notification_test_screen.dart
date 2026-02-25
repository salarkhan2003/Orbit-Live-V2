import 'package:flutter/material.dart';
import '../../../core/notification_scheduler.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isSending = false;

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
                title: 'Notification Test',
                subtitle: 'Test notification sending',
                showBackButton: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 80,
                        color: OrbitLiveColors.primaryTeal,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Notification Testing',
                        style: OrbitLiveTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Use the buttons below to test notification functionality',
                        style: OrbitLiveTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildTestButton(
                        'Send Immediate Notification',
                        Icons.send,
                        _sendImmediateNotification,
                        OrbitLiveColors.primaryTeal,
                      ),
                      const SizedBox(height: 20),
                      _buildTestButton(
                        'Send Travel Tip Notification',
                        Icons.directions_bus,
                        () => _sendCategoryNotification('travel_tip'),
                        OrbitLiveColors.primaryBlue,
                      ),
                      const SizedBox(height: 20),
                      _buildTestButton(
                        'Send Discount Notification',
                        Icons.local_offer,
                        () => _sendCategoryNotification('discount'),
                        OrbitLiveColors.primaryOrange,
                      ),
                      const SizedBox(height: 20),
                      _buildTestButton(
                        'Send Feature Highlight',
                        Icons.star,
                        () => _sendCategoryNotification('feature_highlight'),
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _sendImmediateNotification() async {
    setState(() {
      _isSending = true;
    });

    try {
      final scheduler = NotificationScheduler();
      await scheduler.sendImmediateRandomNotification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendCategoryNotification(String category) async {
    setState(() {
      _isSending = true;
    });

    try {
      final scheduler = NotificationScheduler();
      await scheduler.sendNotificationByCategory(category);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}