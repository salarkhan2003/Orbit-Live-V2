import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/domain/user_role.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      // Initialize Firebase with your project configuration
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAAiH5whjhfoGyw83uwji0Con8nojaXBFA",
          authDomain: "orbit-live.firebaseapp.com",
          projectId: "orbit-live",
          storageBucket: "orbit-live.appspot.com",
          messagingSenderId: "563483124508",
          appId: "1:563483124508:android:9e3f2b3d1e732fe25050d9",
          measurementId: "G-XXXXXXXXXX",
        ),
      );
      _prefs = await SharedPreferences.getInstance();
      print('✅ Firebase initialized successfully with project: orbit-live');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      // Fallback to SharedPreferences only
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static Future<AuthUser?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final roleString = _prefs?.getString('user_role_${firebaseUser.uid}');
        UserRole? role;
        if (roleString == 'passenger') {
          role = UserRole.passenger;
        } else if (roleString == 'driver') {
          role = UserRole.driver;
        }

        return AuthUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: firebaseUser.displayName?.split(' ').first ?? 'User',
          lastName: firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: role,
        );
      }

      // Fallback to local storage for development
      final email = _prefs?.getString('user_email');
      final roleString = _prefs?.getString('user_role');

      if (email == null) return null;

      UserRole? role;
      if (roleString == 'passenger') {
        role = UserRole.passenger;
      } else if (roleString == 'driver') {
        role = UserRole.driver;
      }

      return AuthUser(
        id: 'local_${email.hashCode}',
        email: email,
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+1234567890',
        role: role,
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<AuthUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getCurrentUser();
      }
      throw Exception('Sign in failed');
    } catch (e) {
      print('Firebase sign in error: $e');

      // Fallback to mock authentication for development
      if (email.isNotEmpty && password.length >= 6) {
        await _prefs?.setString('user_email', email);
        return AuthUser(
          id: 'local_${email.hashCode}',
          email: email,
          firstName: 'Test',
          lastName: 'User',
          phoneNumber: '+1234567890',
          role: null,
        );
      }
      throw Exception('Invalid credentials');
    }
  }

  static Future<AuthUser?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getCurrentUser();
      }
      throw Exception('Sign up failed');
    } catch (e) {
      print('Firebase sign up error: $e');

      // Fallback to mock authentication for development
      if (email.isNotEmpty && password.length >= 6) {
        await _prefs?.setString('user_email', email);
        return AuthUser(
          id: 'local_${email.hashCode}',
          email: email,
          firstName: 'New',
          lastName: 'User',
          phoneNumber: '+1234567890',
          role: null,
        );
      }
      throw Exception('Invalid signup data');
    }
  }

  static Future<AuthUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        return await getCurrentUser();
      }
      throw Exception('Google sign in failed');
    } catch (e) {
      print('Google sign in error: $e');
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  static Future<void> setRole(String userId, UserRole role) async {
    try {
      // Store role in local preferences with user ID
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _prefs?.setString('user_role_${currentUser.uid}', role.name);
      } else {
        await _prefs?.setString('user_role', role.name);
      }
    } catch (e) {
      print('Error setting role: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      // Clear local data
      await _prefs?.clear();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Phone authentication methods
  static Future<void> sendPhoneVerification({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber', // Indian phone numbers
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('Phone verification error: $e');
      throw Exception('Failed to send verification code');
    }
  }

  static Future<AuthUser?> signInWithPhone({
    required String phoneNumber,
    required String verificationCode,
    required String verificationId,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Create user with passenger role (since phone auth is for passengers)
        await setRole(userCredential.user!.uid, UserRole.passenger);
        return await getCurrentUser();
      }
      throw Exception('Phone sign in failed');
    } catch (e) {
      print('Phone sign in error: $e');
      throw Exception('Phone sign in failed: ${e.toString()}');
    }
  }
}

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
