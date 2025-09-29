import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/localization_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/orbit_live_animations.dart';
import '../../../shared/orbit_live_theme.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/components/role_card.dart';
import '../../../shared/components/app_header.dart';
import '../domain/user_role.dart';

/// Modern role selection page with Orbit Live branding and design
class OrbitLiveRoleSelectionPage extends StatefulWidget {
  const OrbitLiveRoleSelectionPage({super.key});

  @override
  State<OrbitLiveRoleSelectionPage> createState() => _OrbitLiveRoleSelectionPageState();
}

class _OrbitLiveRoleSelectionPageState extends State<OrbitLiveRoleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  UserRole? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: OrbitLiveAnimations.standardDuration,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: OrbitLiveAnimations.mediumDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: OrbitLiveAnimations.longDuration,
      vsync: this,
    );
    
    // Create animations
    _fadeAnimation = OrbitLiveAnimations.createFadeAnimation(_fadeController);
    _slideAnimation = OrbitLiveAnimations.createSlideAnimation(
      _slideController,
      begin: const Offset(0.0, 0.3),
    );
    _scaleAnimation = OrbitLiveAnimations.createScaleAnimation(
      _scaleController,
      begin: 0.8,
      end: 1.0,
      curve: OrbitLiveAnimations.bounceCurve,
    );
    
    // Start animations
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  Future<void> _selectRole(UserRole role) async {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _submitRole() async {
    if (_selectedRole == null) {
      _showErrorSnackBar('Please select a role first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // If user is already authenticated, update their role
      if (authProvider.user != null) {
        await authProvider.setRole(_selectedRole!);
        
        // Navigate based on selected role
        if (!mounted) return;
        switch (_selectedRole) {
          case UserRole.passenger:
            Navigator.pushReplacementNamed(context, '/passenger');
            break;
          case UserRole.driver:
            Navigator.pushReplacementNamed(context, '/driver');
            break;
          case null:
            break;
        }
      } else {
        // If not authenticated, navigate to auth screens
        if (!mounted) return;
        switch (_selectedRole) {
          case UserRole.passenger:
            Navigator.pushReplacementNamed(context, '/passenger-auth');
            break;
          case UserRole.driver:
            Navigator.pushReplacementNamed(context, '/enhanced-conductor-login');
            break;
          case null:
            break;
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to set role: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      ),
    );
  }
  
  void _skipSelection() {
    // Allow guest access - create authenticated guest user and navigate to passenger mode
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setAuthenticatedUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@orbitlive.com',
      firstName: 'Guest',
      lastName: 'User',
      phoneNumber: '',
      role: UserRole.passenger,
    );
    Navigator.pushReplacementNamed(context, '/passenger');
  }
  
  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }
  
  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
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
          child: _isLoading ? _buildLoadingState() : _buildMainContent(),
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(OrbitLiveColors.primaryTeal),
          ),
          SizedBox(height: 16),
          Text(
            'Setting up your role...',
            style: OrbitLiveTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Column(
      children: [
        // Header section
        Expanded(
          flex: 2,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),
        ),
        
        // Role cards section
        Expanded(
          flex: 3,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildRoleCards(),
          ),
        ),
        
        // Action buttons section
        Expanded(
          flex: 1,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildActionButtons(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Language selector
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLanguageSelector(),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Orbit Live branding
          AppHeader(
            title: 'Orbit Live',
            subtitle: 'Choose your role to get started',
            centerContent: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<Locale>(
        icon: const Icon(
          Icons.language,
          color: OrbitLiveColors.darkGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (locale) {
          Provider.of<LocalizationProvider>(context, listen: false).setLocale(locale);
        },
        itemBuilder: (context) => [
          _buildLanguageMenuItem(context, const Locale('en', 'US'), 'english'),
          _buildLanguageMenuItem(context, const Locale('pa', 'IN'), 'punjabi'),
          _buildLanguageMenuItem(context, const Locale('hi', 'IN'), 'hindi'),
          _buildLanguageMenuItem(context, const Locale('te', 'IN'), 'telugu'),
          _buildLanguageMenuItem(context, const Locale('ta', 'IN'), 'tamil'),
          _buildLanguageMenuItem(context, const Locale('ml', 'IN'), 'malayalam'),
          _buildLanguageMenuItem(context, const Locale('kn', 'IN'), 'kannada'),
          _buildLanguageMenuItem(context, const Locale('mr', 'IN'), 'marathi'),
          _buildLanguageMenuItem(context, const Locale('bn', 'IN'), 'bengali'),
        ],
      ),
    );
  }
  
  PopupMenuItem<Locale> _buildLanguageMenuItem(
    BuildContext context,
    Locale locale,
    String translationKey,
  ) {
    return PopupMenuItem(
      value: locale,
      child: Text(
        context.translate(translationKey),
        style: OrbitLiveTextStyles.bodyMedium,
      ),
    );
  }
  
  Widget _buildRoleCards() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Role cards in a responsive layout
          Builder(
            builder: (context) {
              final screenType = ResponsiveHelper.getScreenType(context);
              switch (screenType) {
                case ScreenType.mobile:
                  // Mobile layout - stacked vertically
                  return Column(
                    children: [
                      _buildPassengerCard(),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                      _buildDriverCard(),
                    ],
                  );
                case ScreenType.tablet:
                case ScreenType.desktop:
                case ScreenType.largeDesktop:
                  // Tablet/Desktop layout - side by side
                  return Row(
                    children: [
                      Expanded(child: _buildPassengerCard()),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                      Expanded(child: _buildDriverCard()),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPassengerCard() {
    return RoleCard(
      title: 'Passenger',
      subtitle: 'Book tickets and track buses',
      gradientColors: const [Colors.blue, Colors.lightBlue],
      illustration: const Icon(Icons.person, size: 48, color: Colors.white),
      isSelected: _selectedRole == UserRole.passenger,
      onTap: () => _selectRole(UserRole.passenger),
      animationController: _scaleController,
    );
  }
  
  Widget _buildDriverCard() {
    return RoleCard(
      title: 'Driver',
      subtitle: 'Manage trips and routes',
      gradientColors: const [Colors.green, Colors.lightGreen],
      illustration: const Icon(Icons.drive_eta, size: 48, color: Colors.white),
      isSelected: _selectedRole == UserRole.driver,
      onTap: () => _selectRole(UserRole.driver),
      animationController: _scaleController,
    );
  }
  
  Widget _buildActionButtons() {
    return Container(
      padding: context.responsivePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Primary action button (Next/Continue)
          Semantics(
            label: _selectedRole != null 
                ? 'Continue with ${_selectedRole?.displayName} role' 
                : 'Continue button, select a role first',
            hint: _selectedRole != null 
                ? 'Proceed to next step' 
                : 'Please select a role before continuing',
            button: true,
            enabled: _selectedRole != null,
            child: SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveButtonHeight(context),
              child: ElevatedButton(
                onPressed: _selectedRole != null ? _submitRole : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                  ),
                  disabledBackgroundColor: OrbitLiveColors.mediumGray,
                ),
                child: Text(
                  'Continue',
                  style: OrbitLiveTextStyles.buttonLarge,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Secondary actions row
          Row(
            children: [
              // Skip button
              Expanded(
                child: Semantics(
                  label: 'Skip role selection',
                  hint: 'Continue as guest without selecting a role',
                  button: true,
                  child: TextButton(
                    onPressed: _skipSelection,
                    style: TextButton.styleFrom(
                      foregroundColor: OrbitLiveColors.darkGray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Skip',
                      style: OrbitLiveTextStyles.buttonMedium.copyWith(
                        color: OrbitLiveColors.darkGray,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Sign Up button
              Expanded(
                child: Semantics(
                  label: 'Sign up for new account',
                  hint: 'Create a new account',
                  button: true,
                  child: OutlinedButton(
                    onPressed: _navigateToSignUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OrbitLiveColors.primaryTeal,
                      side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: OrbitLiveTextStyles.buttonMedium,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Login button
              Expanded(
                child: Semantics(
                  label: 'Login to existing account',
                  hint: 'Sign in with existing credentials',
                  button: true,
                  child: OutlinedButton(
                    onPressed: _navigateToLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OrbitLiveColors.primaryBlue,
                      side: const BorderSide(color: OrbitLiveColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: OrbitLiveTextStyles.buttonMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}