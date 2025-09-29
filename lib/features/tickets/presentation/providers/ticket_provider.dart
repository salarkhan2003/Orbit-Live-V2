import 'package:flutter/material.dart';
import '../../domain/ticket_models.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];
  bool _isProcessingPayment = false;
  Ticket? _generatedTicket;

  List<Ticket> get tickets => _tickets;
  bool get isProcessingPayment => _isProcessingPayment;
  Ticket? get generatedTicket => _generatedTicket;

  Future<void> processPayment({
    required BusRoute route,
    required TicketType ticketType,
    required PaymentDetails paymentDetails,
    required String source,
    required String destination,
  }) async {
    _isProcessingPayment = true;
    _generatedTicket = null;
    notifyListeners();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Generate ticket
    final ticket = Ticket(
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
      fare: paymentDetails.amount,
      qrCode: 'ORBIT_${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: paymentDetails.method,
    );

    _tickets.add(ticket);
    _generatedTicket = ticket;
    _isProcessingPayment = false;
    notifyListeners();
  }

  void clearGeneratedTicket() {
    _generatedTicket = null;
    notifyListeners();
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
}