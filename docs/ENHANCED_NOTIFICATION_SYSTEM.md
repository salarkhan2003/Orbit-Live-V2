# Enhanced Notification System for Orbit Live

## Overview

This document describes the implementation of an enhanced notification system for the Orbit Live public transport tracking app. The system includes:

1. Frequent, randomized promotional push notifications
2. Personalization based on user data
3. Frequency control to avoid spamming
4. Analytics and tracking for optimization
5. User preference management
6. Backend scheduling with Firebase Cloud Functions

## Features Implemented

### 1. Notification Content Variety

Created a diverse set of promotional messages in multiple categories:

- Travel tips ("Avoid peak hours for smooth rides!")
- Discounts and Offers ("Get 10% off on your next ticket purchase!")
- Feature Highlights ("Try our new TravelBuddy for safer journeys!")
- Seasonal Greetings and Announcements
- Reminders ("Plan your next trip now!")

### 2. Randomized Sending

Implemented backend logic using Firebase Cloud Functions to send notifications every 10 minutes during active hours (9 AM to 9 PM).

### 3. Frequency Control

- Implemented cooldown periods (max 3 notifications per day per user)
- Random selection mechanism to send notifications to only a subset of users
- Batch processing to avoid rate limiting

### 4. Personalization

- User data (usage patterns, preferences, location) is used to tailor message content
- Segmentation of users to receive relevant offers or travel tips
- Personalized deep links to relevant app features

### 5. Delivery & Frequency

- Notifications sent every 10 minutes during active hours (9 AM to 9 PM)
- Time zone adjustments for optimal delivery time
- Support for action buttons to encourage engagement

### 6. Push Notification Features

- Firebase Cloud Messaging (FCM) for push delivery
- Notification title, body, and deep links
- Action buttons for quick engagement
- Fallback logic for failed notifications

### 7. Analytics & Optimization

- Tracking of delivery, open rates, and user responses
- Analytics dashboard for monitoring performance
- Data-driven optimization of frequency and content

## File Structure

```
lib/
├── core/
│   ├── notification_service.dart
│   ├── notification_scheduler.dart
│   ├── notification_analytics_service.dart
├── features/
│   ├── notifications/
│   │   └── presentation/
│   │       ├── notification_preferences_screen.dart
│   │       ├── notification_analytics_screen.dart
│   │       └── notification_test_screen.dart
├── main.dart (updated with new routes)
functions/
├── index.js (enhanced Firebase Cloud Functions)
└── package.json
```

## Technical Implementation

### 1. Frontend Components

#### Notification Service
Enhanced with:
- Deep linking support
- Action button handling
- FCM token management
- Analytics tracking

#### Notification Scheduler
Enhanced with:
- Personalization capabilities
- Frequency control mechanisms
- Daily limit enforcement
- Time zone awareness
- **Now sends notifications every 10 minutes during active hours**

#### Analytics Service
New service for:
- Tracking notification delivery and opens
- Calculating engagement metrics
- Managing user preferences
- Storing analytics data in Firestore

#### UI Components
- Notification Preferences Screen: Allows users to customize notification types
- Notification Analytics Screen: Displays engagement metrics and performance data
- **Notification Test Screen: Allows manual testing of notification functionality**

### 2. Backend Components (Firebase Cloud Functions)

#### sendFrequentPromotionalNotifications
- **Scheduled function that runs every 10 minutes during active hours (9 AM to 9 PM)**
- Sends randomized notifications to users
- Implements frequency control and personalization
- Tracks delivery for analytics

#### trackNotificationOpen
- Callable function to track when users open notifications
- Stores open events in Firestore for analytics

#### getNotificationAnalytics
- Callable function to retrieve analytics data
- Aggregates delivery and open rates by category

## Integration Points

### 1. Routes

Added to `main.dart`:
- `/notification-preferences`: Notification preferences management
- `/notification-analytics`: Analytics dashboard
- **`/notification-test`: Manual notification testing**

### 2. Services

- Enhanced NotificationService with deep linking and analytics
- Updated NotificationScheduler with personalization and frequency control
- New NotificationAnalyticsService for tracking and optimization

### 3. Dependencies

Updated in `pubspec.yaml`:
- Added shared_preferences for local data storage
- Enhanced notification-related dependencies

## Usage Examples

### Sending a Personalized Notification

```dart
final scheduler = NotificationScheduler();
await scheduler.sendImmediateRandomNotification();
```

### Tracking Notification Engagement

```dart
final analyticsService = NotificationAnalyticsService();
await analyticsService.trackNotificationOpen('discount');
```

### Getting Analytics Data

```dart
final analyticsService = NotificationAnalyticsService();
final analytics = await analyticsService.getNotificationAnalytics(days: 30);
```

## Backend Implementation

### Firebase Cloud Function - Scheduled Notifications

```javascript
exports.sendFrequentPromotionalNotifications = functions.pubsub
    .schedule('every 10 minutes from 09:00 to 21:00')
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
      // Implementation details...
    });
```

### Firebase Cloud Function - Track Opens

```javascript
exports.trackNotificationOpen = functions.https.onCall(async (data, context) => {
  // Implementation details...
});
```

## Security Considerations

1. **Firestore Rules**: Implemented role-based access control for analytics data
2. **Data Validation**: Server-side validation for all analytics operations
3. **Rate Limiting**: Batch processing and cooldown periods to prevent abuse
4. **Privacy**: Only store necessary analytics data, no personal information

## Analytics Dashboard

The notification analytics screen provides:

1. **Overall Performance Metrics**:
   - Total notifications delivered
   - Total notifications opened
   - Overall open rate percentage

2. **Category Performance**:
   - Performance metrics for each notification category
   - Visual progress indicators
   - Color-coded performance ratings

3. **Time Range Selection**:
   - 7-day, 30-day, and 90-day views
   - Trend analysis capabilities

## User Preferences

Users can customize their notification experience through the preferences screen:

1. **Category Toggles**: Enable/disable specific notification types
2. **Real-time Updates**: Changes take effect immediately
3. **Persistent Storage**: Preferences saved locally and synced to backend

## Testing

### Manual Testing

The notification test screen allows developers to manually trigger different types of notifications:

1. **Send Immediate Notification**: Sends a random notification immediately
2. **Category-specific Notifications**: Send notifications of specific categories (travel tips, discounts, etc.)

### Automated Testing

1. **Unit Tests**: Service layer methods are easily testable
2. **Integration Tests**: UI components can be tested with mock data
3. **End-to-End Tests**: Notification flows can be tested with Firebase emulators

## Deployment

1. **Frontend**: Standard Flutter build process
2. **Backend**: Deploy Firebase Functions with `firebase deploy --only functions`
3. **Security Rules**: Deploy Firestore rules with `firebase deploy --only firestore`

## Conclusion

This enhanced notification system provides a robust, scalable solution for sending frequent, randomized, and personalized promotional notifications to Orbit Live users. The system balances user engagement with respect for user preferences, implementing frequency controls to avoid spamming while maximizing the effectiveness of promotional communications.

The modular design allows for easy extension and customization based on future requirements, and the analytics capabilities provide the data needed to continuously optimize the notification strategy.

**Key Update**: The system now sends notifications every 10 minutes during active hours (9 AM to 9 PM) as requested, providing more frequent engagement opportunities while still respecting user preferences and avoiding spam.