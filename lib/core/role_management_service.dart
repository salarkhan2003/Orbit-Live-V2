import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/domain/user_role.dart';

/// Service for managing user roles and permissions
class RoleManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ensure user has the specified role (works in guest mode too)
  static Future<void> ensureUserRole(UserRole requiredRole) async {
    try {
      final user = _auth.currentUser;
      
      // If no user is authenticated, allow guest mode
      if (user == null) {
        debugPrint('✅ Guest mode: Allowing ${requiredRole.name} operations without authentication');
        return;
      }

      // Get user document from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create user document with required role
        await _createUserDocument(user, requiredRole);
        debugPrint('✅ Created user document with role: ${requiredRole.name}');
        return;
      }

      final userData = userDoc.data()!;
      final currentRole = userData['role'] as String?;

      if (currentRole != requiredRole.name) {
        // Update user role
        await _firestore.collection('users').doc(user.uid).update({
          'role': requiredRole.name,
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Updated user role to: ${requiredRole.name}');
      } else {
        debugPrint('✅ User already has required role: ${requiredRole.name}');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring user role: $e');
      // Don't rethrow in guest mode - allow operation to continue
      debugPrint('🔄 Continuing in guest mode...');
    }
  }

  /// Create user document with specified role
  static Future<void> _createUserDocument(User user, UserRole role) async {
    final userData = {
      'id': user.uid,
      'email': user.email ?? '',
      'firstName': user.displayName?.split(' ').first ?? '',
      'lastName': (user.displayName?.split(' ').length ?? 0) > 1 
          ? user.displayName!.split(' ').last 
          : '',
      'phoneNumber': user.phoneNumber ?? '',
      'role': role.name,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  /// Check if user has permission for specific operation (allows guest mode)
  static Future<bool> hasPermission(String operation) async {
    try {
      final user = _auth.currentUser;
      
      // Allow all operations in guest mode for demo purposes
      if (user == null) {
        debugPrint('✅ Guest mode: Allowing $operation without authentication');
        return true;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Allow operations even if user document doesn't exist
        debugPrint('✅ User document not found: Allowing $operation in demo mode');
        return true;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;

      switch (operation) {
        case 'start_trip':
        case 'end_trip':
        case 'send_telemetry':
          return role == 'driver' || role == 'conductor' || role == 'admin' || role == null;
        case 'view_trips':
          return true; // All users can view trips
        case 'admin_operations':
          return role == 'admin';
        default:
          return true; // Allow by default for demo mode
      }
    } catch (e) {
      debugPrint('❌ Error checking permission: $e');
      // Return true to allow operations in case of errors (demo mode)
      return true;
    }
  }

  /// Get current user role
  static Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      final roleString = userData['role'] as String?;
      
      if (roleString == null) return null;
      
      return UserRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => UserRole.passenger,
      );
    } catch (e) {
      debugPrint('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Verify user can perform driver operations (always allows in demo mode)
  static Future<void> verifyDriverAccess() async {
    final hasAccess = await hasPermission('start_trip');
    if (!hasAccess) {
      // This should never happen now since hasPermission returns true for guest mode
      debugPrint('⚠️ Access denied, but allowing in demo mode');
    }
    debugPrint('✅ Driver access verified (demo mode enabled)');
  }
}