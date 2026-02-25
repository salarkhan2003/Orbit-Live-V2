# Orbit Live Notification and Booking System

## Overview

This document describes the implementation of a complete notification and booking system for the Orbit Live public transport tracking app. The system includes:

1. Firestore booking storage with real-time listeners
2. SMS and email notifications
3. Rich push notification system
4. Stylish UI/UX design for notifications and history
5. Backend Firebase Cloud Functions for triggers
6. Bonus: Randomized frequent notifications

## Features Implemented

### 1. Firestore Booking Storage

- **Booking Model**: Created a unified [Booking](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/features/bookings/domain/booking_models.dart#L9-L45) model that supports both tickets and passes
- **Booking Service**: Implemented [BookingService](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/features/bookings/data/booking_service.dart#L11-L123) for CRUD operations on bookings
- **Real-time Listeners**: Added streaming capabilities to instantly update the UI when bookings change
- **Data Structure**: Each booking record contains:
  - User ID
  - Booking details (route, date, fare)
  - Payment status and transaction ID
  - Timestamp (createdAt)

### 2. Notification System

- **Local Notifications**: Integrated `flutter_local_notifications` for in-app alerts
- **Push Notifications**: Integrated `firebase_messaging` for cloud messaging
- **Notification Service**: Created [NotificationService](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/core/notification_service.dart#L7-L133) for managing all notification types
- **Notification Scheduler**: Implemented [NotificationScheduler](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/core/notification_scheduler.dart#L6-L104) for bonus feature of randomized notifications

### 3. SMS and Email Notifications

- **SMS Integration**: Placeholder implementation for SMS gateway API integration
- **Email Integration**: Implemented Resend.com API integration for HTML email notifications
- **Firebase Functions**: Created sample Cloud Functions for backend notification processing

### 4. UI/UX Components

- **Booking Cards**: Created [BookingCard](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/features/bookings/presentation/widgets/booking_card.dart#L10-L148) widget for displaying booking information with QR codes
- **All Bookings Screen**: Implemented [AllBookingsScreen](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/features/bookings/presentation/all_bookings_screen.dart#L12-L156) with tabbed interface for active bookings and history
- **Notification Permission Dialog**: Created styled dialog to encourage notification opt-in

### 5. Backend Implementation

- **Firebase Cloud Functions**: Sample implementations for:
  - Sending booking notifications on creation
  - Scheduled randomized notifications
- **Firestore Security Rules**: Defined access control for booking data

## File Structure

```
lib/
├── core/
│   ├── notification_service.dart
│   ├── notification_scheduler.dart
│   └── firebase_database_service.dart (updated)
├── features/
│   ├── bookings/
│   │   ├── domain/
│   │   │   └── booking_models.dart
│   │   ├── data/
│   │   │   └── booking_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── booking_provider.dart
│   │       ├── widgets/
│   │       │   └── booking_card.dart
│   │       └── all_bookings_screen.dart
│   ├── notifications/
│   │   └── widgets/
│   │       └── notification_permission_dialog.dart
│   ├── tickets/
│   │   └── presentation/
│   │       └── providers/
│   │           └── ticket_provider.dart (updated)
│   └── passes/
│       └── presentation/
│           └── providers/
│               └── pass_provider.dart (updated)
├── main.dart (updated)
functions/
├── index.js (Firebase Cloud Functions)
└── package.json
```

## Integration Points

### 1. Providers

- Added [BookingProvider](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/features/bookings/presentation/providers/booking_provider.dart#L7-L57) to manage booking state
- Updated TicketProvider and PassProvider to use the new booking system

### 2. Routes

- Added `/all-bookings` route to [main.dart](file:///D:/SIH/19-9-V5%20Orbit%20live/public_transport_tracker/lib/main.dart#L1-L381)

### 3. Dependencies

Added to `pubspec.yaml`:
- `firebase_messaging: ^15.1.3`
- Updated notification-related dependencies

## Usage Examples

### Creating a Booking

```dart
final bookingId = await BookingService.createBooking(
  type: BookingType.ticket,
  source: 'Sims',
  destination: 'RTC Bus Stand',
  fare: 5.0,
  travelDate: DateTime.now(),
  paymentStatus: PaymentStatus.success,
  transactionId: 'UPI_1234567890',
  qrCode: 'ORBIT_1234567890',
);
```

### Showing a Notification

```dart
await NotificationService().showLocalNotification(
  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  title: 'Booking Confirmed!',
  body: 'Your ticket is confirmed.',
  payload: 'booking_$bookingId',
);
```

### Starting the Notification Scheduler

```dart
NotificationScheduler().startScheduler();
```

## Backend Implementation (Firebase Functions)

The backend implementation uses Firebase Cloud Functions to handle:

1. **Booking Notifications**: Triggered when a new booking is created
2. **Scheduled Notifications**: Randomized notifications sent periodically

### Sample Function - Booking Notification

```javascript
exports.sendBookingNotification = functions.firestore
    .document('bookings/{bookingId}')
    .onCreate(async (snap, context) => {
      // Send SMS and email notifications
    });
```

## Security Considerations

1. **Firestore Rules**: Implemented role-based access control
2. **Data Validation**: Server-side validation for all booking operations
3. **API Keys**: Secure handling of Resend.com API key

## Future Enhancements

1. **Deep Linking**: Implement deep links in notifications to navigate to specific bookings
2. **Notification Preferences**: Allow users to customize notification types
3. **Analytics**: Track notification engagement and booking patterns
4. **Advanced Scheduling**: More sophisticated notification scheduling based on user behavior

## Testing

The system has been designed with testability in mind:

1. **Unit Tests**: Service layer methods are easily testable
2. **Integration Tests**: Provider and UI components can be tested with mock data
3. **End-to-End Tests**: Notification flows can be tested with Firebase emulators

## Deployment

1. **Frontend**: Standard Flutter build process
2. **Backend**: Deploy Firebase Functions with `firebase deploy --only functions`
3. **Security Rules**: Deploy Firestore rules with `firebase deploy --only firestore`

## Conclusion

This implementation provides a robust, scalable notification and booking system that enhances the user experience while maintaining security and performance standards. The modular design allows for easy extension and customization based on future requirements.