import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/localization_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/orbit_live_animations.dart';
import '../../../shared/orbit_live_theme.dart';
import '../../../shared/components/app_header.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../domain/user_role.dart';
import '../domain/conductor_auth_data.dart';
import '../data/conductor_auth_service.dart';

/// Enhanced conductor authentication screen with modern Orbit Live styling
class EnhancedConductorLoginScreen extends StatefulWidget {
  const EnhancedConductorLoginScreen({super.key});

  @override
  State<EnhancedConductorLoginScreen> createState() => _EnhancedConductorLoginScreenState();
}

class _EnhancedConductorLoginScreenState extends State<EnhancedConductorLoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _formController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formAnimation;
  
  // State variables
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  // Auth data model
  ConductorAuthData get _authData => ConductorAuthData(
    fullName: _isLogin ? null : _nameController.text,
    employeeId: _employeeIdController.text,
    phoneNumber: _isLogin ? null : _phoneController.text,
    password: _passwordController.text,
    isLogin: _isLogin,
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _formController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: OrbitLiveAnimations.standardDuration,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: OrbitLiveAnimations.mediumDuration,
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: OrbitLiveAnimations.longDuration,
      vsync: this,
    );
    
    _fadeAnimation = OrbitLiveAnimations.createFadeAnimation(_fadeController);
    _slideAnimation = OrbitLiveAnimations.createSlideAnimation(
      _slideController,
      begin: const Offset(0.0, 0.5),
    );
    _formAnimation = OrbitLiveAnimations.createScaleAnimation(
      _formController,
      begin: 0.9,
      end: 1.0,
    );
  }
  
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _formController.forward();
    });
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate using the auth data model
    final validationErrors = _authData.validate();
    if (validationErrors.isNotEmpty) {
      setState(() {
        _errorMessage = validationErrors.first;
      });
      _showErrorSnackBar(_errorMessage!);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ConductorAuthResult result;
      
      if (_isLogin) {
        result = await ConductorAuthService.login(_authData);
      } else {
        result = await ConductorAuthService.signup(_authData);
      }
      
      if (result.isSuccess) {
        // Create authenticated user and set role
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Create a proper authenticated user
        authProvider.setAuthenticatedUser(
          id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
          email: '${_authData.employeeId}@orbitlive.com', // Generate email from employee ID
          firstName: _authData.fullName?.split(' ').first ?? 'Conductor',
          lastName: (_authData.fullName?.split(' ').length ?? 0) > 1 ? _authData.fullName!.split(' ').last : '',
          phoneNumber: _authData.phoneNumber ?? '',
          role: UserRole.driver,
        );
        
        // Navigate to the driver dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/driver');
          
          _showSuccessSnackBar(_isLogin ? 'Login successful!' : 'Account created successfully!');
        }
      } else {
        throw ConductorAuthException(result.errorMessage ?? 'Authentication failed');
      }
    } catch (e) {
      String errorMessage;
      if (e is ConductorAuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = _isLogin 
            ? 'Login failed. Please check your credentials.' 
            : 'Signup failed. Please try again.';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
      
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
    
    // Clear form when switching modes
    if (_isLogin) {
      _nameController.clear();
      _phoneController.clear();
    }
  }
  
  void _skipAuthentication() {
    // Set the user role to driver before navigating
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setGuestUser(UserRole.driver);
    
    // Navigate to driver dashboard without login
    Navigator.pushReplacementNamed(context, '/driver');
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OrbitLiveColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OrbitLiveColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _authenticate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: OrbitLiveColors.orangeGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        children: [
          // Header section
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),
          
          const SizedBox(height: 40),
          
          // Form section
          SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _formAnimation,
              child: _buildForm(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Skip button
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSkipButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Back button and title
        AppHeader(
          title: _isLogin ? 'Driver Login' : 'Driver Signup',
          subtitle: 'Enter your credentials to continue',
          showBackButton: true,
          onBackPressed: () {
            Navigator.pushReplacementNamed(context, '/role-selection');
          },
        ),
      ],
    );
  }
  
  Widget _buildForm() {
    return Container(
      padding: ResponsiveHelper.getResponsiveValue(
        context: context,
        mobile: const EdgeInsets.all(20),
        tablet: const EdgeInsets.all(28),
        desktop: const EdgeInsets.all(32),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        boxShadow: [
          BoxShadow(
            color: OrbitLiveColors.shadowMedium,
            blurRadius: context.responsiveElevation * 2.5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: OrbitLiveTextStyles.cardTitle.copyWith(
                color: OrbitLiveColors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _isLogin 
                  ? 'Sign in to your driver account'
                  : 'Fill in your details to get started',
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: OrbitLiveColors.darkGray,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OrbitLiveColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: OrbitLiveColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: OrbitLiveColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: OrbitLiveTextStyles.formError,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Form fields
            ..._buildFormFields(),
            
            const SizedBox(height: 28),
            
            // Submit button
            _buildSubmitButton(),
            
            const SizedBox(height: 20),
            
            // Toggle auth mode
            _buildAuthModeToggle(),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildFormFields() {
    return [
      // Name field (signup only)
      if (!_isLogin) ...[
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
      
      // Employee ID field
      _buildTextField(
        controller: _employeeIdController,
        label: 'Employee ID',
        icon: Icons.badge_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your employee ID';
          }
          if (value.length < 3) {
            return 'Employee ID must be at least 3 characters';
          }
          return null;
        },
      ),
      
      const SizedBox(height: 16),
      
      // Phone field (signup only)
      if (!_isLogin) ...[
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
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
        const SizedBox(height: 16),
      ],
      
      // Password field
      _buildTextField(
        controller: _passwordController,
        label: 'Password',
        icon: Icons.lock_outline,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: OrbitLiveColors.darkGray,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    ];
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: OrbitLiveTextStyles.formInput,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: OrbitLiveTextStyles.formLabel,
        prefixIcon: Icon(icon, color: OrbitLiveColors.darkGray),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrbitLiveColors.error, width: 2),
        ),
        filled: true,
        fillColor: OrbitLiveColors.lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _authenticate,
        style: ElevatedButton.styleFrom(
          backgroundColor: OrbitLiveColors.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: OrbitLiveColors.mediumGray,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLogin ? 'Login' : 'Create Account',
                style: OrbitLiveTextStyles.buttonLarge,
              ),
      ),
    );
  }
  
  Widget _buildAuthModeToggle() {
    return Center(
      child: TextButton(
        onPressed: _toggleAuthMode,
        style: TextButton.styleFrom(
          foregroundColor: OrbitLiveColors.primaryOrange,
        ),
        child: RichText(
          text: TextSpan(
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.darkGray,
            ),
            children: [
              TextSpan(
                text: _isLogin 
                    ? "Don't have an account? " 
                    : "Already have an account? ",
              ),
              TextSpan(
                text: _isLogin ? 'Sign Up' : 'Login',
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: OrbitLiveColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: _skipAuthentication,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'Skip - Continue as Guest',
          style: OrbitLiveTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}