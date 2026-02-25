import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/tickets/domain/popular_routes.dart';

void main() {
  group('Popular Routes', () {
    test('Popular routes list is not empty', () {
      final routes = PopularRoutesData.getGunturRoutes();
      expect(routes, isNotEmpty);
      expect(routes.length, 11); // Now we expect 11 routes (10 + 1 new 5 INR route)
    });

    test('All routes have valid data', () {
      final routes = PopularRoutesData.getGunturRoutes();
      for (final route in routes) {
        expect(route.id, isNotEmpty);
        expect(route.name, isNotEmpty);
        expect(route.source, isNotEmpty);
        expect(route.destination, isNotEmpty);
        expect(route.distanceInKm, greaterThan(0));
        expect(route.estimatedDuration, greaterThan(Duration.zero));
        expect(route.timings, isNotEmpty);
        expect(route.fixedFare, greaterThan(0)); // All routes should have fixed fares
      }
    });

    test('All routes use fixed fares', () {
      final routes = PopularRoutesData.getGunturRoutes();
      for (final route in routes) {
        // Fare should be the fixed fare provided by RTC
        expect(route.fare, route.fixedFare);
      }
    });

    test('5 INR fare route is correctly implemented', () {
      final routes = PopularRoutesData.getGunturRoutes();
      final fiveRupeeRoute = routes.firstWhere((route) => route.id == '0');
      
      expect(fiveRupeeRoute.name, 'Sims - RTC Bus Stand');
      expect(fiveRupeeRoute.source, 'Sims');
      expect(fiveRupeeRoute.destination, 'RTC Bus Stand');
      expect(fiveRupeeRoute.fixedFare, 5.0);
      expect(fiveRupeeRoute.fare, 5.0);
      expect(fiveRupeeRoute.distanceInKm, 2.0);
      expect(fiveRupeeRoute.estimatedDuration, const Duration(minutes: 10));
    });

    test('Specific route fixed fares', () {
      final routes = PopularRoutesData.getGunturRoutes();
      
      // Find the 5 INR route
      final fiveRupeeRoute = routes.firstWhere((route) => route.id == '0');
      expect(fiveRupeeRoute.fixedFare, 5.0);
      expect(fiveRupeeRoute.fare, 5.0);
      
      // Find specific routes and verify their fixed fares
      final route1 = routes.firstWhere((route) => route.id == '1');
      expect(route1.name, 'Guntur Central - Tenali');
      expect(route1.fixedFare, 25.0);
      expect(route1.fare, 25.0);
      
      final route2 = routes.firstWhere((route) => route.id == '2');
      expect(route2.name, 'RTC Bus Stand - Mangalagiri');
      expect(route2.fixedFare, 40.0);
      expect(route2.fare, 40.0);
      
      final route5 = routes.firstWhere((route) => route.id == '5');
      expect(route5.name, 'Guntur Junction - Vijayawada');
      expect(route5.fixedFare, 50.0);
      expect(route5.fare, 50.0);
    });

    test('Route serialization works correctly', () {
      final route = PopularRoute(
        id: 'test1',
        name: 'Test Route',
        source: 'Source',
        destination: 'Destination',
        distanceInKm: 12.5,
        estimatedDuration: const Duration(minutes: 30),
        timings: ['9:00 AM', '12:00 PM'],
        fixedFare: 20.0,
      );

      final json = route.toJson();
      final restoredRoute = PopularRoute.fromJson(json);

      expect(restoredRoute.id, route.id);
      expect(restoredRoute.name, route.name);
      expect(restoredRoute.source, route.source);
      expect(restoredRoute.destination, route.destination);
      expect(restoredRoute.distanceInKm, route.distanceInKm);
      expect(restoredRoute.estimatedDuration, route.estimatedDuration);
      expect(restoredRoute.timings, route.timings);
      expect(restoredRoute.fixedFare, route.fixedFare);
      expect(restoredRoute.fare, route.fare);
    });
  });
}