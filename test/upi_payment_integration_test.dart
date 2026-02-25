import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/core/upi_payment_service.dart';

void main() {
  group('UPI Payment Integration', () {
    test('UPI ID is correct', () {
      expect(UpiPaymentService.upiId, 'salarkhanp@ybl');
    });

    test('Fare calculation works correctly', () {
      // Test base fare
      expect(UpiPaymentService.calculateFare(0), 5.0);
      expect(UpiPaymentService.calculateFare(-1), 5.0);
      
      // Test fare calculation
      expect(UpiPaymentService.calculateFare(1), 7.0);
      expect(UpiPaymentService.calculateFare(3), 11.0);
      expect(UpiPaymentService.calculateFare(5.5), 16.0);
    });

    test('Fare formatting works correctly', () {
      expect(UpiPaymentService.formatFare(5.0), '₹5.00');
      expect(UpiPaymentService.formatFare(11.5), '₹11.50');
      expect(UpiPaymentService.formatFare(16.75), '₹16.75');
    });

    test('Fare breakdown formatting works correctly', () {
      expect(UpiPaymentService.formatFareBreakdown(0), 'Fare: ₹5.00 (₹5 base)');
      expect(UpiPaymentService.formatFareBreakdown(3), 'Fare: ₹11.00 (₹5 base + ₹6.00 for 3.0km)');
    });
  });
}