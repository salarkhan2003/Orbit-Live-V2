import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../data/booking_service.dart';
import '../../domain/booking_models.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  StreamSubscription? _bookingsSubscription;
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Load bookings from Firestore
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await BookingService.getUserBookings();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Subscribe to real-time booking updates
  void subscribeToBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _bookingsSubscription?.cancel();
      _bookingsSubscription = BookingService.getUserBookingsStream().listen((bookings) {
        _bookings = bookings;
        notifyListeners();
      });
    }
  }

  // Unsubscribe from booking updates
  void unsubscribeFromBookings() {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = null;
  }

  // Get active bookings
  List<Booking> getActiveBookings() {
    return _bookings.where((booking) => booking.status == BookingStatus.confirmed).toList();
  }

  // Get booking history
  List<Booking> getBookingHistory() {
    return _bookings.where((booking) => booking.status != BookingStatus.confirmed).toList();
  }

  @override
  void dispose() {
    unsubscribeFromBookings();
    super.dispose();
  }
}