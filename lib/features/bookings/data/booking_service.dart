import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../domain/booking_models.dart';
import '../../../core/notification_service.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference _bookings = _firestore.collection('bookings');

  // Create a new booking
  static Future<String> createBooking({
    required BookingType type,
    required String source,
    required String destination,
    required double fare,
    required DateTime travelDate,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? routeId,
    String? qrCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final booking = Booking(
        id: '',
        userId: user.uid,
        type: type,
        source: source,
        destination: destination,
        fare: fare,
        travelDate: travelDate,
        status: BookingStatus.confirmed,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
        createdAt: DateTime.now(),
        routeId: routeId,
        qrCode: qrCode,
      );

      final docRef = await _bookings.add(booking.toFirestore());
      
      // Update the ID with the document ID
      await docRef.update({'id': docRef.id});
      
      debugPrint('✅ Booking created successfully: ${docRef.id}');
      
      // Send notifications
      await _sendBookingNotifications(booking, docRef.id);
      
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating booking: $e');
      rethrow;
    }
  }

  // Get user bookings
  static Future<List<Booking>> getUserBookings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _bookings
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user bookings: $e');
      return [];
    }
  }

  // Get booking by ID
  static Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _bookings.doc(bookingId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting booking: $e');
      return null;
    }
  }

  // Update booking status
  static Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _bookings.doc(bookingId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Booking status updated successfully: $bookingId');
    } catch (e) {
      debugPrint('❌ Error updating booking status: $e');
      rethrow;
    }
  }

  // Real-time listener for user bookings
  static Stream<List<Booking>> getUserBookingsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _bookings
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Send booking notifications
  static Future<void> _sendBookingNotifications(Booking booking, String bookingId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final notificationService = NotificationService();

      // Send push notification
      await notificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Booking Confirmed!',
        body: 'Your ${booking.type.name} from ${booking.source} to ${booking.destination} is confirmed.',
        payload: 'booking_$bookingId',
      );

      // In a real implementation, you would also send SMS and email notifications
      // For now, we'll just log that they would be sent
      debugPrint('Would send SMS and email notifications for booking: $bookingId');
    } catch (e) {
      debugPrint('Error sending booking notifications: $e');
    }
  }
}