import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../features/auth/domain/user_role.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final UserRole? role;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.role,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> init() async {
    // Initialize any required services
  }

  static Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Try to get user data from Firestore first
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return AuthUser(
            id: user.uid,
            email: data['email'] ?? user.email ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            role: UserRole.values.firstWhere(
              (e) => e.name == data['role'],
              orElse: () => UserRole.passenger,
            ),
          );
        } else {
          // Fallback to basic user info
          return AuthUser(
            id: user.uid,
            email: user.email ?? '',
            firstName: '',
            lastName: '',
            phoneNumber: '',
            role: UserRole.passenger, // Default role
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<AuthUser?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Get user data from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return AuthUser(
            id: user.uid,
            email: data['email'] ?? user.email ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            role: UserRole.values.firstWhere(
              (e) => e.name == data['role'],
              orElse: () => UserRole.passenger,
            ),
          );
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  static Future<AuthUser?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'firstName': '',
          'lastName': '',
          'phoneNumber': '',
          'role': UserRole.passenger.name, // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return AuthUser(
          id: user.uid,
          email: email,
          firstName: '',
          lastName: '',
          phoneNumber: '',
          role: UserRole.passenger,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  static Future<AuthUser?> signInWithGoogle() async {
    try {
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Check if user already exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          // Create new user document with proper data
          final firstName = user.displayName?.split(' ').first ?? '';
          final lastName = (user.displayName?.split(' ').length ?? 0) > 1 
              ? user.displayName!.split(' ').last 
              : '';
          
          await _firestore.collection('users').doc(user.uid).set({
            'id': user.uid,
            'email': user.email ?? '',
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': '',
            'role': UserRole.passenger.name, // Default role
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Get updated user data
        final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
        if (updatedDoc.exists) {
          final data = updatedDoc.data()!;
          return AuthUser(
            id: user.uid,
            email: data['email'] ?? user.email ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            role: UserRole.values.firstWhere(
              (e) => e.name == data['role'],
              orElse: () => UserRole.passenger,
            ),
          );
        } else {
          // Fallback if document doesn't exist
          return AuthUser(
            id: user.uid,
            email: user.email ?? '',
            firstName: user.displayName?.split(' ').first ?? '',
            lastName: user.displayName?.split(' ').last ?? '',
            phoneNumber: '',
            role: UserRole.passenger,
          );
        }
      }
      return null;
    } catch (e) {
      print('Google sign in error: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  static Future<void> setRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.name,
      });
    } catch (e) {
      print('Error setting user role: $e');
      rethrow;
    }
  }

  static Future<void> sendPhoneVerification({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  static Future<User?> signInWithPhone({
    required String phoneNumber,
    required String verificationCode,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Phone sign in error: $e');
      rethrow;
    }
  }
}