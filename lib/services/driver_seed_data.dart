import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Seeds test driver/conductor employees into Firebase for demo purposes
/// Run this once to populate the employees collection
class DriverSeedData {
  static const String _databaseURL = 'https://orbit-live-3836f-default-rtdb.firebaseio.com/';

  /// Seed test employees
  static Future<void> seedEmployees() async {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _databaseURL,
      );

      final employees = {
        'DRV001': {
          'name': 'Ramesh Kumar',
          'role': 'driver',
          'depot': 'Guntur Central',
          'assigned_routes': ['RJ-12', 'RJ-15'],
          'phone': '9876543210',
          'password': 'driver123', // For demo only - use hashing in production
        },
        'DRV002': {
          'name': 'Suresh Reddy',
          'role': 'driver',
          'depot': 'Vijayawada',
          'assigned_routes': ['AC-EXPRESS-1', 'RJ-20'],
          'phone': '9876543211',
          'password': 'driver123',
        },
        'CND001': {
          'name': 'Venkat Rao',
          'role': 'conductor',
          'depot': 'Guntur Central',
          'assigned_routes': ['RJ-12', 'RJ-15', 'RJ-20'],
          'phone': '9876543212',
          'password': 'conductor123',
        },
        'CND002': {
          'name': 'Krishna Prasad',
          'role': 'conductor',
          'depot': 'Vijayawada',
          'assigned_routes': ['AC-EXPRESS-1', 'AC-EXPRESS-2'],
          'phone': '9876543213',
          'password': 'conductor123',
        },
        'DRV003': {
          'name': 'Satish Babu',
          'role': 'driver',
          'depot': 'Tenali',
          'assigned_routes': ['CITY-LOOP-1'],
          'phone': '9876543214',
          'password': 'driver123',
        },
      };

      for (final entry in employees.entries) {
        await db.ref('employees/${entry.key}').set(entry.value);
        debugPrint('[SEED] Created employee: ${entry.key}');
      }

      debugPrint('[SEED] All employees seeded successfully');
    } catch (e) {
      debugPrint('[SEED] Error seeding employees: $e');
    }
  }

  /// Seed sample passes for passenger validation
  static Future<void> seedPasses() async {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _databaseURL,
      );

      final passes = {
        'PASS001': {
          'holder_name': 'Student A',
          'type': 'student',
          'route_id': 'RJ-12',
          'expiry': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
        },
        'PASS002': {
          'holder_name': 'Senior Citizen B',
          'type': 'senior',
          'route_id': 'RJ-15',
          'expiry': DateTime.now().add(const Duration(days: 60)).millisecondsSinceEpoch,
        },
        'PASS003': {
          'holder_name': 'Monthly C',
          'type': 'monthly',
          'route_id': 'AC-EXPRESS-1',
          'expiry': DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch, // Expired for testing
        },
      };

      for (final entry in passes.entries) {
        await db.ref('passes/${entry.key}').set(entry.value);
        debugPrint('[SEED] Created pass: ${entry.key}');
      }

      debugPrint('[SEED] All passes seeded successfully');
    } catch (e) {
      debugPrint('[SEED] Error seeding passes: $e');
    }
  }

  /// Run all seeds
  static Future<void> seedAll() async {
    await seedEmployees();
    await seedPasses();
  }
}

