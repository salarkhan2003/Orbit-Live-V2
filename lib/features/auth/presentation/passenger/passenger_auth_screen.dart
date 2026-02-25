import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../main.dart' as main;
import '../../../../core/clerk_auth_service.dart';
import '../../../../shared/orbit_live_colors.dart';
import '../../../../shared/orbit_live_text_styles.dart';
import '../../domain/user_role.dart';

class PassengerAuthScreen extends StatefulWidget {
  const PassengerAuthScreen({super.key});

  @override
  State<PassengerAuthScreen> createState() => _PassengerAuthScreenState();
}

class _PassengerAuthScreenState extends State<PassengerAuthScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOtpSent = false;
  String _verificationId = '';
  String _errorMessage = '';
  String _successMessage = '';
  
  // Optimization: Add a flag to prevent multiple simultaneous requests
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneAuth() async {
    // Prevent multiple simultaneous requests
    if (_isProcessing || !_phoneFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isProcessing = true; // Set processing flag
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await AuthService.sendPhoneVerification(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification completed
          try {
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            final user = userCredential.user;
            
            if (user != null && mounted) {
              await _completeUserSetup(user);
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _errorMessage = e.toString();
                _isLoading = false;
                _isProcessing = false; // Reset processing flag
              });
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _errorMessage = e.message ?? 'Phone verification failed';
              _isLoading = false;
              _isProcessing = false; // Reset processing flag
            });
          }
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
              _isLoading = false;
              _isProcessing = false; // Reset processing flag
              _successMessage = 'OTP sent to your phone';
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    }
  }

  Future<void> _handleOtpVerification() async {
    // Prevent multiple simultaneous requests
    if (_isProcessing || !_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isProcessing = true; // Set processing flag
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null && mounted) {
        await _completeUserSetup(user);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Invalid OTP';
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    }
  }

  Future<void> _completeUserSetup(User user) async {
    try {
      // Check if user exists in Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create new user document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email ?? '',
          'firstName': '',
          'lastName': '',
          'phoneNumber': '+91${_phoneController.text}',
          'role': UserRole.passenger.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update phone number if it exists but is different
        final userData = doc.data()!;
        if (userData['phoneNumber'] != '+91${_phoneController.text}') {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'phoneNumber': '+91${_phoneController.text}',
          });
        }
      }
      
      if (mounted) {
        // Get updated user data from Firestore
        final updatedDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = updatedDoc.data()!;
        
        final authProvider = Provider.of<main.AuthProvider>(context, listen: false);
        authProvider.setAuthenticatedUser(
          id: user.uid,
          email: userData['email'] ?? user.email ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '+91${_phoneController.text}',
          role: UserRole.passenger,
        );
        
        setState(() {
          _successMessage = 'Login successful!';
          _isProcessing = false; // Reset processing flag
        });
        
        // Navigate to passenger dashboard after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/passenger');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error setting up user: ${e.toString()}';
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Prevent multiple simultaneous requests
    if (_isProcessing) return;
    
    setState(() {
      _isLoading = true;
      _isProcessing = true; // Set processing flag
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Use the static method directly instead of through provider
      final authUser = await AuthService.signInWithGoogle();
      
      if (authUser != null && mounted) {
        final authProvider = Provider.of<main.AuthProvider>(context, listen: false);
        authProvider.setAuthenticatedUser(
          id: authUser.id,
          email: authUser.email,
          firstName: authUser.firstName,
          lastName: authUser.lastName,
          phoneNumber: authUser.phoneNumber,
          role: authUser.role ?? UserRole.passenger,
        );
        
        setState(() {
          _successMessage = 'Google sign-in successful!';
          _isProcessing = false; // Reset processing flag
        });
        
        // Navigate to passenger dashboard after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/passenger');
          }
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in was cancelled';
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error during Google sign-in: ${e.toString()}';
          _isLoading = false;
          _isProcessing = false; // Reset processing flag
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: OrbitLiveColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: OrbitLiveColors.black),
                    ),
                    const Spacer(),
                    Text(
                      _isOtpSent ? 'Verify OTP' : 'Passenger Login',
                      style: OrbitLiveTextStyles.headerTitle.copyWith(color: OrbitLiveColors.black),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Logo - simplified for better performance
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: OrbitLiveColors.mediumGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 56,
                    color: OrbitLiveColors.black,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  _isOtpSent ? 'Enter OTP sent to your phone' : 'Login to Your Account',
                  style: OrbitLiveTextStyles.cardTitle.copyWith(
                    color: OrbitLiveColors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Messages
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                if (_successMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      _successMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Form - simplified rebuild logic
                Expanded(
                  child: _buildForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    // Simplified widget rebuild logic
    return _isOtpSent ? _buildOtpForm() : _buildPhoneForm();
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixText: '+91 ',
              prefixStyle: const TextStyle(
                color: OrbitLiveColors.black,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.phone, color: OrbitLiveColors.darkGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: OrbitLiveColors.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: OrbitLiveColors.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: OrbitLiveColors.primaryTeal),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            style: const TextStyle(color: OrbitLiveColors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 30),
          
          // Send OTP button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitLiveColors.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Divider with OR
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: OrbitLiveColors.mediumGray,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: OrbitLiveColors.darkGray,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: OrbitLiveColors.mediumGray,
                  thickness: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Google Sign In button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: OrbitLiveColors.mediumGray),
                elevation: 2,
              ),
              icon: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.g_mobiledata,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  color: OrbitLiveColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Form(
      key: _otpFormKey,
      child: Column(
        children: [
          // OTP field
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: const Icon(Icons.lock, color: OrbitLiveColors.darkGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: OrbitLiveColors.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: OrbitLiveColors.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: OrbitLiveColors.primaryTeal),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              counterText: '',
            ),
            style: const TextStyle(color: OrbitLiveColors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter OTP';
              }
              if (value.length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 30),
          
          // Verify OTP button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleOtpVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitLiveColors.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Verify OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Resend OTP button
          TextButton(
            onPressed: _isLoading ? null : _handlePhoneAuth,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: OrbitLiveColors.primaryTeal,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Back to phone input
          TextButton(
            onPressed: () {
              setState(() {
                _isOtpSent = false;
                _errorMessage = '';
                _successMessage = '';
                _otpController.clear();
              });
            },
            child: const Text(
              'Change Phone Number',
              style: TextStyle(
                color: OrbitLiveColors.primaryTeal,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}