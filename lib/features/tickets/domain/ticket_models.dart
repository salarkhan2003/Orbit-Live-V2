import 'package:flutter/material.dart';

enum TicketType {
  oneTime,
  returnTrip,
  multiRide,
}

enum TicketStatus {
  active,
  used,
  expired,
  cancelled,
}

enum PaymentMethod {
  upi,
  wallet,
  debitCard,
  creditCard,
}

class BusRoute {
  final String id;
  final String name;
  final String source;
  final String destination;
  final List<String> stops;
  final Duration estimatedDuration;
  final double fare;
  final List<String> timings;

  BusRoute({
    required this.id,
    required this.name,
    required this.source,
    required this.destination,
    required this.stops,
    required this.estimatedDuration,
    required this.fare,
    required this.timings,
  });
}

class Ticket {
  final String id;
  final String routeId;
  final String routeName;
  final String source;
  final String destination;
  final TicketType type;
  final TicketStatus status;
  final DateTime purchaseDate;
  final DateTime validFrom;
  final DateTime validUntil;
  final double fare;
  final String qrCode;
  final String? seatNumber;
  final PaymentMethod paymentMethod;

  Ticket({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.source,
    required this.destination,
    required this.type,
    required this.status,
    required this.purchaseDate,
    required this.validFrom,
    required this.validUntil,
    required this.fare,
    required this.qrCode,
    this.seatNumber,
    required this.paymentMethod,
  });

  String get typeDisplayName {
    switch (type) {
      case TicketType.oneTime:
        return 'One-time';
      case TicketType.returnTrip:
        return 'Return';
      case TicketType.multiRide:
        return 'Multi-ride';
    }
  }

  Color get statusColor {
    switch (status) {
      case TicketStatus.active:
        return Colors.green;
      case TicketStatus.used:
        return Colors.orange;
      case TicketStatus.expired:
        return Colors.red;
      case TicketStatus.cancelled:
        return Colors.grey;
    }
  }
}

class PaymentDetails {
  final PaymentMethod method;
  final String? cardNumber;
  final String? upiId;
  final String? walletId;
  final double amount;

  PaymentDetails({
    required this.method,
    this.cardNumber,
    this.upiId,
    this.walletId,
    required this.amount,
  });
}