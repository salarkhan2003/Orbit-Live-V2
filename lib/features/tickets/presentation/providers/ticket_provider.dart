import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../../core/firebase_database_service.dart';
import '../../domain/ticket_models.dart';
import '../../../bookings/data/booking_service.dart';
import '../../../bookings/domain/booking_models.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];
  bool _isProcessingPayment = false;
  Ticket? _generatedTicket;
  StreamSubscription? _ticketsSubscription;

  List<Ticket> get tickets => _tickets;
  bool get isProcessingPayment => _isProcessingPayment;
  Ticket? get generatedTicket => _generatedTicket;

  Future<void> processUpiPayment({
    required BusRoute route,
    required TicketType ticketType,
    required double distanceInKm,
    required String source,
    required String destination,
  }) async {
    _isProcessingPayment = true;
    _generatedTicket = null;
    notifyListeners();

    // Use the route's fare if available, otherwise calculate based on distance
    final fare = route.fare > 0 ? route.fare : (5.0 + (distanceInKm * 2.0));

    // Generate ticket
    Ticket ticket = Ticket(
      id: 'TKT${DateTime.now().millisecondsSinceEpoch}',
      routeId: route.id,
      routeName: route.name,
      source: source,
      destination: destination,
      type: ticketType,
      status: TicketStatus.active,
      purchaseDate: DateTime.now(),
      validFrom: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 1)),
      fare: fare,
      qrCode: 'ORBIT_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: PaymentMethod.upi,
    );

    // Store ticket in Firestore using the new booking service
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create booking record
        final bookingId = await BookingService.createBooking(
          type: BookingType.ticket,
          source: source,
          destination: destination,
          fare: fare,
          travelDate: DateTime.now(),
          paymentStatus: PaymentStatus.success,
          transactionId: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
          routeId: route.id,
          qrCode: ticket.qrCode,
        );
        
        // Update ticket ID with booking ID
        final updatedTicket = Ticket(
          id: bookingId,
          routeId: ticket.routeId,
          routeName: ticket.routeName,
          source: ticket.source,
          destination: ticket.destination,
          type: ticket.type,
          status: ticket.status,
          purchaseDate: ticket.purchaseDate,
          validFrom: ticket.validFrom,
          validUntil: ticket.validUntil,
          fare: ticket.fare,
          qrCode: ticket.qrCode,
          paymentMethod: ticket.paymentMethod,
        );
        
        ticket = updatedTicket;
      }
    } catch (e) {
      debugPrint('Error storing ticket in Firestore: $e');
    }

    _tickets.add(ticket);
    _generatedTicket = ticket;
    _isProcessingPayment = false;
    notifyListeners();
  }

  // New method for processing Cashfree payments
  Future<void> processCashfreePayment({
    required BusRoute route,
    required TicketType ticketType,
    required double distanceInKm,
    required String source,
    required String destination,
    required String transactionId,
  }) async {
    _isProcessingPayment = true;
    _generatedTicket = null;
    notifyListeners();

    // Use the route's fare if available, otherwise calculate based on distance
    final fare = route.fare > 0 ? route.fare : (5.0 + (distanceInKm * 2.0));

    // Generate ticket
    Ticket ticket = Ticket(
      id: 'TKT${DateTime.now().millisecondsSinceEpoch}',
      routeId: route.id,
      routeName: route.name,
      source: source,
      destination: destination,
      type: ticketType,
      status: TicketStatus.active,
      purchaseDate: DateTime.now(),
      validFrom: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 1)),
      fare: fare,
      qrCode: 'ORBIT_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: PaymentMethod.upi, // For now, we'll mark all payments as UPI
    );

    // Store ticket in Firestore using the new booking service
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create booking record
        final bookingId = await BookingService.createBooking(
          type: BookingType.ticket,
          source: source,
          destination: destination,
          fare: fare,
          travelDate: DateTime.now(),
          paymentStatus: PaymentStatus.success,
          transactionId: transactionId,
          routeId: route.id,
          qrCode: ticket.qrCode,
        );
        
        // Update ticket ID with booking ID
        final updatedTicket = Ticket(
          id: bookingId,
          routeId: ticket.routeId,
          routeName: ticket.routeName,
          source: ticket.source,
          destination: ticket.destination,
          type: ticket.type,
          status: ticket.status,
          purchaseDate: ticket.purchaseDate,
          validFrom: ticket.validFrom,
          validUntil: ticket.validUntil,
          fare: ticket.fare,
          qrCode: ticket.qrCode,
          paymentMethod: ticket.paymentMethod,
        );
        
        ticket = updatedTicket;
      }
    } catch (e) {
      debugPrint('Error storing ticket in Firestore: $e');
    }

    _tickets.add(ticket);
    _generatedTicket = ticket;
    _isProcessingPayment = false;
    notifyListeners();
  }

  Future<void> processPayment({
    required BusRoute route,
    required TicketType ticketType,
    required PaymentDetails paymentDetails,
    required String source,
    required String destination,
    required double distanceInKm,
  }) async {
    _isProcessingPayment = true;
    _generatedTicket = null;
    notifyListeners();

    // Use the route's fare if available, otherwise calculate based on distance
    final fare = route.fare > 0 ? route.fare : (5.0 + (distanceInKm * 2.0));

    // Generate ticket
    Ticket ticket = Ticket(
      id: 'TKT${DateTime.now().millisecondsSinceEpoch}',
      routeId: route.id,
      routeName: route.name,
      source: source,
      destination: destination,
      type: ticketType,
      status: TicketStatus.active,
      purchaseDate: DateTime.now(),
      validFrom: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 1)),
      fare: fare,
      qrCode: 'ORBIT_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: paymentDetails.method,
    );

    // Store ticket in Firestore using the new booking service
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create booking record
        final bookingId = await BookingService.createBooking(
          type: BookingType.ticket,
          source: source,
          destination: destination,
          fare: fare,
          travelDate: DateTime.now(),
          paymentStatus: paymentDetails.method == PaymentMethod.upi 
              ? PaymentStatus.success 
              : PaymentStatus.pending,
          transactionId: paymentDetails.transactionId ?? 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          routeId: route.id,
          qrCode: ticket.qrCode,
        );
        
        // Update ticket ID with booking ID
        final updatedTicket = Ticket(
          id: bookingId,
          routeId: ticket.routeId,
          routeName: ticket.routeName,
          source: ticket.source,
          destination: ticket.destination,
          type: ticket.type,
          status: ticket.status,
          purchaseDate: ticket.purchaseDate,
          validFrom: ticket.validFrom,
          validUntil: ticket.validUntil,
          fare: ticket.fare,
          qrCode: ticket.qrCode,
          paymentMethod: ticket.paymentMethod,
        );
        
        ticket = updatedTicket;
      }
    } catch (e) {
      debugPrint('Error storing ticket in Firestore: $e');
    }

    _tickets.add(ticket);
    _generatedTicket = ticket;
    _isProcessingPayment = false;
    notifyListeners();
  }

  void clearGeneratedTicket() {
    _generatedTicket = null;
    notifyListeners();
  }

  Future<void> loadTicketsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ticketsData = await FirebaseDatabaseService.getUserTickets(user.uid);
        
        // Convert Firestore data to Ticket objects
        _tickets = ticketsData.map((data) {
          return Ticket(
            id: data['id'] as String,
            routeId: data['routeId'] as String? ?? '',
            routeName: data['routeName'] as String? ?? '',
            source: data['source'] as String? ?? '',
            destination: data['destination'] as String? ?? '',
            type: TicketType.values.firstWhere(
              (e) => e.name == data['ticketType'],
              orElse: () => TicketType.oneTime,
            ),
            status: TicketStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => TicketStatus.active,
            ),
            purchaseDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validUntil: (data['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 1)),
            fare: (data['amount'] as num?)?.toDouble() ?? 0.0,
            qrCode: data['qrCode'] as String? ?? '',
            paymentMethod: PaymentMethod.values.firstWhere(
              (e) => e.name == data['paymentMethod'],
              orElse: () => PaymentMethod.upi,
            ),
          );
        }).toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tickets from Firestore: $e');
    }
  }

  void subscribeToTickets() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ticketsSubscription?.cancel();
      _ticketsSubscription = FirebaseDatabaseService.getUserTicketsStream(user.uid).listen((ticketsData) {
        // Convert Firestore data to Ticket objects
        _tickets = ticketsData.map((data) {
          return Ticket(
            id: data['id'] as String,
            routeId: data['routeId'] as String? ?? '',
            routeName: data['routeName'] as String? ?? '',
            source: data['source'] as String? ?? '',
            destination: data['destination'] as String? ?? '',
            type: TicketType.values.firstWhere(
              (e) => e.name == data['ticketType'],
              orElse: () => TicketType.oneTime,
            ),
            status: TicketStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => TicketStatus.active,
            ),
            purchaseDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validUntil: (data['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 1)),
            fare: (data['amount'] as num?)?.toDouble() ?? 0.0,
            qrCode: data['qrCode'] as String? ?? '',
            paymentMethod: PaymentMethod.values.firstWhere(
              (e) => e.name == data['paymentMethod'],
              orElse: () => PaymentMethod.upi,
            ),
          );
        }).toList();
        
        notifyListeners();
      });
    }
  }

  void unsubscribeFromTickets() {
    _ticketsSubscription?.cancel();
    _ticketsSubscription = null;
  }

  List<Ticket> getActiveTickets() {
    return _tickets.where((ticket) => ticket.status == TicketStatus.active).toList();
  }

  List<Ticket> getTicketHistory() {
    return _tickets.where((ticket) => ticket.status != TicketStatus.active).toList();
  }

  void useTicket(String ticketId) {
    final ticketIndex = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex != -1) {
      final ticket = _tickets[ticketIndex];
      _tickets[ticketIndex] = Ticket(
        id: ticket.id,
        routeId: ticket.routeId,
        routeName: ticket.routeName,
        source: ticket.source,
        destination: ticket.destination,
        type: ticket.type,
        status: TicketStatus.used,
        purchaseDate: ticket.purchaseDate,
        validFrom: ticket.validFrom,
        validUntil: ticket.validUntil,
        fare: ticket.fare,
        qrCode: ticket.qrCode,
        seatNumber: ticket.seatNumber,
        paymentMethod: ticket.paymentMethod,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unsubscribeFromTickets();
    super.dispose();
  }
}