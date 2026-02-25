import 'package:flutter/material.dart';
import '../../../core/notification_analytics_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';

class NotificationAnalyticsScreen extends StatefulWidget {
  const NotificationAnalyticsScreen({super.key});

  @override
  State<NotificationAnalyticsScreen> createState() => _NotificationAnalyticsScreenState();
}

class _NotificationAnalyticsScreenState extends State<NotificationAnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  int _timeRange = 30; // Default to 30 days

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analyticsService = NotificationAnalyticsService();
      _analytics = await analyticsService.getNotificationAnalytics(days: _timeRange);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                title: 'Notification Analytics',
                subtitle: 'Track your notification engagement',
                showBackButton: true,
              ),
              _buildTimeRangeSelector(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: OrbitLiveColors.primaryTeal,
                        ),
                      )
                    : _buildAnalyticsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Time Range:'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _timeRange,
            items: const [
              DropdownMenuItem(value: 7, child: Text('7 days')),
              DropdownMenuItem(value: 30, child: Text('30 days')),
              DropdownMenuItem(value: 90, child: Text('90 days')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _timeRange = value;
                });
                _loadAnalytics();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    if (_analytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No analytics data available',
              style: OrbitLiveTextStyles.cardTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Notification analytics will appear here once you receive notifications',
              style: OrbitLiveTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 20),
        const Text(
          'Category Performance',
          style: OrbitLiveTextStyles.cardTitle,
        ),
        const SizedBox(height: 16),
        ..._analytics.entries.map((entry) => _buildCategoryCard(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    int totalDelivered = 0;
    int totalOpened = 0;

    _analytics.forEach((key, value) {
      totalDelivered += value['delivered'] as int? ?? 0;
      totalOpened += value['opened'] as int? ?? 0;
    });

    final openRate = totalDelivered > 0 ? (totalOpened / totalDelivered) * 100 : 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Performance',
              style: OrbitLiveTextStyles.cardTitle,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard('Delivered', totalDelivered.toString(), OrbitLiveColors.primaryBlue),
                _buildMetricCard('Opened', totalOpened.toString(), OrbitLiveColors.primaryTeal),
                _buildMetricCard('Open Rate', '${openRate.toStringAsFixed(1)}%', OrbitLiveColors.primaryOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              color: color,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: OrbitLiveTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, Map<String, dynamic> data) {
    final delivered = data['delivered'] as int? ?? 0;
    final opened = data['opened'] as int? ?? 0;
    final openRate = delivered > 0 ? (opened / delivered) * 100 : 0.0;

    // Determine color based on open rate
    Color rateColor;
    if (openRate >= 50) {
      rateColor = Colors.green;
    } else if (openRate >= 25) {
      rateColor = Colors.orange;
    } else {
      rateColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatCategoryName(category),
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallMetric('Delivered', delivered.toString()),
                _buildSmallMetric('Opened', opened.toString()),
                _buildSmallMetric('Rate', '${openRate.toStringAsFixed(1)}%', rateColor),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: delivered > 0 ? opened / delivered : 0,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(rateColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetric(String title, String value, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: OrbitLiveTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: OrbitLiveTextStyles.bodySmall,
        ),
      ],
    );
  }

  String _formatCategoryName(String category) {
    // Convert snake_case to Title Case
    return category.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}