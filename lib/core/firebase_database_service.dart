import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/domain/user_role.dart';
import '../features/travel_buddy/domain/travel_buddy_models.dart';
import '../features/bookings/domain/booking_models.dart';

class FirebaseDatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static final CollectionReference users = _firestore.collection('users');
  static final CollectionReference tickets = _firestore.collection('tickets');
  static final CollectionReference passes = _firestore.collection('passes');
  static final CollectionReference travelBuddies = _firestore.collection('travelBuddies');
  static final CollectionReference complaints = _firestore.collection('complaints');
  static final CollectionReference busRoutes = _firestore.collection('busRoutes');
  static final CollectionReference bookings = _firestore.collection('bookings'); // Add bookings collection

  // User operations
  static Future<void> createUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    UserRole? role,
  }) async {
    try {
      await users.doc(uid).set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber ?? '',
        'role': role?.name ?? 'passenger',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User created successfully: $uid');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await users.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await users.doc(uid).update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User role updated successfully: $uid -> ${role.name}');
    } catch (e) {
      debugPrint('❌ Error updating user role: $e');
      rethrow;
    }
  }

  // Ticket operations
  static Future<String> createTicket({
    required String userId,
    required String source,
    required String destination,
    required double amount,
    required String ticketType,
    required DateTime travelDate,
    String? routeId,
  }) async {
    try {
      final docRef = await tickets.add({
        'userId': userId,
        'source': source,
        'destination': destination,
        'amount': amount,
        'ticketType': ticketType,
        'travelDate': travelDate,
        'routeId': routeId ?? '',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'qrCode': '', // Will be generated on the backend
      });
      
      debugPrint('✅ Ticket created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating ticket: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserTickets(String userId) async {
    try {
      final querySnapshot = await tickets
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user tickets: $e');
      return [];
    }
  }

  // Pass operations
  static Future<String> createPass({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String passType,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final docRef = await passes.add({
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'passType': passType,
        'amount': amount,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'qrCode': '', // Will be generated on the backend
      });
      
      debugPrint('✅ Pass created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating pass: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserPasses(String userId) async {
    try {
      final querySnapshot = await passes
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user passes: $e');
      return [];
    }
  }

  // Booking operations
  static Future<String> createBooking({
    required String userId,
    required BookingType type,
    required String source,
    required String destination,
    required double fare,
    required DateTime travelDate,
    required BookingStatus status,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? routeId,
    String? qrCode,
  }) async {
    try {
      final docRef = await bookings.add({
        'userId': userId,
        'type': type.name,
        'source': source,
        'destination': destination,
        'fare': fare,
        'travelDate': travelDate,
        'status': status.name,
        'paymentStatus': paymentStatus.name,
        'transactionId': transactionId,
        'routeId': routeId ?? '',
        'qrCode': qrCode ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Booking created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating booking: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await bookings
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user bookings: $e');
      return [];
    }
  }

  // Travel Buddy operations
  static Future<String> createTravelBuddyProfile({
    required String userId,
    required String name,
    required String route,
    required DateTime travelTime,
    required GenderPreference genderPreference,
    required List<String> languages,
    String? bio,
  }) async {
    try {
      final docRef = await travelBuddies.add({
        'userId': userId,
        'name': name,
        'route': route,
        'travelTime': travelTime,
        'genderPreference': genderPreference.name,
        'languages': languages,
        'bio': bio ?? '',
        'rating': 0.0,
        'completedTrips': 0,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Travel buddy profile created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating travel buddy profile: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> findTravelBuddies({
    required String route,
    required DateTime travelTime,
    GenderPreference? genderPreference,
  }) async {
    try {
      // Find buddies with similar routes and travel times
      final querySnapshot = await travelBuddies
          .where('route', isEqualTo: route)
          .where('isOnline', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error finding travel buddies: $e');
      return [];
    }
  }

  // Complaint operations
  static Future<String> createComplaint({
    required String userId,
    required String category,
    required String description,
    required String busNumber,
    required String source,
    required String destination,
  }) async {
    try {
      final docRef = await complaints.add({
        'userId': userId,
        'category': category,
        'description': description,
        'busNumber': busNumber,
        'source': source,
        'destination': destination,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Complaint created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating complaint: $e');
      rethrow;
    }
  }

  // Bus route operations
  static Future<List<Map<String, dynamic>>> getBusRoutes() async {
    try {
      final querySnapshot = await busRoutes.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting bus routes: $e');
      return [];
    }
  }

  // Real-time listeners
  static Stream<List<Map<String, dynamic>>> getUserTicketsStream(String userId) {
    return tickets
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getUserPassesStream(String userId) {
    return passes
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getUserBookingsStream(String userId) {
    return bookings
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getTravelBuddiesStream(String route) {
    return travelBuddies
        .where('route', isEqualTo: route)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}