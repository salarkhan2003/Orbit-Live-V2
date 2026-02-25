import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../services/twilio_otp_service.dart';
import '../../../main.dart';
import '../domain/user_role.dart';
import '../../passenger/presentation/passenger_dashboard.dart';

/// Clean Passenger Login with OTP verification using Twilio
class PassengerOtpLoginScreen extends StatefulWidget {
  const PassengerOtpLoginScreen({super.key});

  @override
  State<PassengerOtpLoginScreen> createState() => _PassengerOtpLoginScreenState();
}

class _PassengerOtpLoginScreenState extends State<PassengerOtpLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  int _resendTimer = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit mobile number');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await TwilioOtpService.sendOtp(phone);
      
      if (success) {
        setState(() {
          _otpSent = true;
          _resendTimer = 30;
        });
        _startResendTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        setState(() => _errorMessage = 'Failed to send OTP. Please try again.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    
    if (otp.isEmpty || otp.length != 6) {
      setState(() => _errorMessage = 'Enter the 6-digit OTP');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await TwilioOtpService.verifyOtp(phone, otp);
      
      if (success) {
        // Login successful - create user session
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setAuthenticatedUser(
          id: 'passenger_${phone}_${DateTime.now().millisecondsSinceEpoch}',
          email: '$phone@orbitlive.passenger',
          firstName: 'Passenger',
          lastName: phone.substring(phone.length - 4),
          phoneNumber: phone,
          role: UserRole.passenger,
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PassengerDashboard()),
          );
        }
      } else {
        setState(() => _errorMessage = 'Invalid OTP. Please try again.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setAuthenticatedUser(
      id: 'guest_passenger_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@orbitlive.com',
      firstName: 'Guest',
      lastName: 'Passenger',
      phoneNumber: '',
      role: UserRole.passenger,
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PassengerDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.directions_bus, size: 50, color: Color(0xFF1565C0)),
                ),
                
                const SizedBox(height: 24),
                
                const Text('Passenger Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(_otpSent ? 'Enter the OTP sent to your phone' : 'Login with your mobile number', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                
                const SizedBox(height: 40),
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Number Input
                      if (!_otpSent) ...[
                        const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: '10-digit mobile number',
                            prefixIcon: const Icon(Icons.phone),
                            prefixText: '+91 ',
                            counterText: '',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ],
                      
                      // OTP Input
                      if (_otpSent) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('+91 ${_phoneController.text}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _otpSent = false),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: '• • • • • •',
                            counterText: '',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Didn't receive OTP? ", style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: _resendTimer > 0 ? null : _sendOtp,
                              child: Text(_resendTimer > 0 ? 'Resend in ${_resendTimer}s' : 'Resend OTP'),
                            ),
                          ],
                        ),
                      ],
                      
                      // Error Message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))),
                          ]),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_otpSent ? 'Verify OTP' : 'Send OTP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Guest Mode
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Column(
                    children: [
                      const Text('Demo Mode', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _continueAsGuest,
                          icon: const Icon(Icons.person_outline, color: Colors.white),
                          label: const Text('Continue as Guest', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Back button
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text('Back to Role Selection', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

