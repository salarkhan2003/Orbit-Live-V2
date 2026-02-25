import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingType { ticket, pass }

enum BookingStatus { confirmed, pending, cancelled, expired }

enum PaymentStatus { success, pending, failed, refunded }

class Booking {
  final String id;
  final String userId;
  final BookingType type;
  final String source;
  final String destination;
  final double fare;
  final DateTime travelDate;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String transactionId;
  final DateTime createdAt;
  final String? routeId;
  final String? qrCode;

  Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.source,
    required this.destination,
    required this.fare,
    required this.travelDate,
    required this.status,
    required this.paymentStatus,
    required this.transactionId,
    required this.createdAt,
    this.routeId,
    this.qrCode,
  });

  // Create a Booking from Firestore data
  factory Booking.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Booking(
      id: documentId,
      userId: data['userId'] as String,
      type: BookingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BookingType.ticket,
      ),
      source: data['source'] as String,
      destination: data['destination'] as String,
      fare: (data['fare'] as num).toDouble(),
      travelDate: (data['travelDate'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == data['paymentStatus'],
        orElse: () => PaymentStatus.success,
      ),
      transactionId: data['transactionId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      routeId: data['routeId'] as String?,
      qrCode: data['qrCode'] as String?,
    );
  }

  // Convert Booking to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'source': source,
      'destination': destination,
      'fare': fare,
      'travelDate': travelDate,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'transactionId': transactionId,
      'createdAt': createdAt,
      'routeId': routeId,
      'qrCode': qrCode,
    };
  }
}