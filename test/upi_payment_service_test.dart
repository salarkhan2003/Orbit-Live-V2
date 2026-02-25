import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/core/upi_payment_service.dart';

void main() {
  group('UpiPaymentService', () {
    group('calculateFare', () {
      test('should return base fare for zero distance', () {
        expect(UpiPaymentService.calculateFare(0), 5.0);
      });

      test('should return base fare for negative distance', () {
        expect(UpiPaymentService.calculateFare(-1), 5.0);
      });

      test('should calculate fare correctly for 1 km', () {
        expect(UpiPaymentService.calculateFare(1), 7.0);
      });

      test('should calculate fare correctly for 3 km', () {
        expect(UpiPaymentService.calculateFare(3), 11.0);
      });

      test('should calculate fare correctly for 5.5 km', () {
        expect(UpiPaymentService.calculateFare(5.5), 16.0);
      });
    });

    group('formatFare', () {
      test('should format fare correctly', () {
        expect(UpiPaymentService.formatFare(5.0), '₹5.00');
        expect(UpiPaymentService.formatFare(11.5), '₹11.50');
        expect(UpiPaymentService.formatFare(16.75), '₹16.75');
      });
    });

    group('formatFareBreakdown', () {
      test('should format fare breakdown for zero distance', () {
        expect(UpiPaymentService.formatFareBreakdown(0), 'Fare: ₹5.00 (₹5 base)');
      });

      test('should format fare breakdown for 3 km', () {
        expect(UpiPaymentService.formatFareBreakdown(3), 'Fare: ₹11.00 (₹5 base + ₹6.00 for 3.0km)');
      });
    });
  });
}