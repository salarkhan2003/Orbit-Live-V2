import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/localization_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_animations.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../domain/user_role.dart';
import '../../travel_buddy/presentation/providers/travel_buddy_provider.dart';

/// Enhanced role selection screen with modern, stylish UI/UX
class EnhancedRoleSelectionScreen extends StatefulWidget {
  const EnhancedRoleSelectionScreen({super.key});

  @override
  State<EnhancedRoleSelectionScreen> createState() => _EnhancedRoleSelectionScreenState();
}

class _EnhancedRoleSelectionScreenState extends State<EnhancedRoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _buttonPulseAnimation;
  
  UserRole? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _cardController = AnimationController(
      duration: OrbitLiveAnimations.longDuration,
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Create animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: OrbitLiveAnimations.bounceCurve),
    );
    
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: OrbitLiveAnimations.cardSlideCurve),
    );
    
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Start animations with stagger
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _cardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    super.dispose();
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
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _skipSelection() {
    // Show role selection dialog instead of directly navigating
    _showRoleSelectionDialog();
  }
  
  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Role',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Please select your role to continue as a guest:',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectAndNavigateAsGuest(UserRole.passenger);
              },
              child: Text('Passenger'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectAndNavigateAsGuest(UserRole.driver);
              },
              child: Text('Driver'),
            ),
          ],
        );
      },
    );
  }
  
  void _selectAndNavigateAsGuest(UserRole role) {
    // Create authenticated guest user and navigate based on selected role
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = 'guest_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
    
    authProvider.setAuthenticatedUser(
      id: userId,
      email: 'guest@orbitlive.com',
      firstName: 'Guest',
      lastName: role == UserRole.passenger ? 'Passenger' : 'Driver',
      phoneNumber: '',
      role: role,
    );
    
    // Initialize travel buddy provider for the guest user
    final travelBuddyProvider = Provider.of<TravelBuddyProvider>(context, listen: false);
    travelBuddyProvider.initialize(userId);
    
    if (role == UserRole.passenger) {
      Navigator.pushReplacementNamed(context, '/passenger');
    } else {
      Navigator.pushReplacementNamed(context, '/driver');
    }
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              OrbitLiveColors.primaryBlue,
              OrbitLiveColors.primaryTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: _isLoading ? _buildLoadingState() : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedBackgroundPainter(
            animationValue: _backgroundAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
          SizedBox(height: 16),
          Text(
            'Setting up your experience...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header section
          _buildHeader(),
          
          const SizedBox(height: 40),
          
          // Role cards section
          _buildRoleCards(),
          
          const SizedBox(height: 40),
          
          // Action buttons section
          _buildActionButtons(),
          
          const SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardController, curve: const Interval(0.0, 0.5)),
      ),
      child: Column(
        children: [
          // App logo/branding
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Orbit Live',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Keep white for contrast on gradient background
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Subtitle
          Text(
            'Choose your role to get started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white, // Keep white for contrast on gradient background
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Language selector
          _buildLanguageSelector(),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<Locale>(
        icon: const Icon(
          Icons.language,
          color: Colors.white,
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
        style: const TextStyle(
          color: Colors.black, // Changed from Colors.black to ensure visibility
          fontSize: 16,
        ),
      ),
    );
  }
  
  Widget _buildRoleCards() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: ScaleTransition(
        scale: _cardScaleAnimation,
        child: Column(
          children: [
            // Passenger Card
            _buildRoleCard(
              title: 'Passenger',
              subtitle: 'Book tickets and track buses in real-time',
              description: 'Find your perfect ride with live tracking, ticket booking, and travel buddy features',
              icon: Icons.person,
              gradientColors: const [Colors.blue, Colors.lightBlue],
              onTap: () => _selectRole(UserRole.passenger),
              isSelected: _selectedRole == UserRole.passenger,
            ),
            
            const SizedBox(height: 25),
            
            // Driver Card
            _buildRoleCard(
              title: 'Driver',
              subtitle: 'Manage trips and routes efficiently',
              description: 'Track your passengers, manage schedules, and optimize your routes with our driver tools',
              icon: Icons.drive_eta,
              gradientColors: const [Colors.green, Colors.lightGreen],
              onTap: () => _selectRole(UserRole.driver),
              isSelected: _selectedRole == UserRole.driver,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? gradientColors.first.withValues(alpha: 0.5) 
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: isSelected ? 20 : 10,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action button (Next/Continue)
        ScaleTransition(
          scale: _buttonPulseAnimation,
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _selectedRole != null ? _submitRole : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: OrbitLiveColors.primaryTeal,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBackgroundColor: Colors.white30,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Continue as ${_selectedRole?.displayName ?? 'Selected Role'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Secondary actions row
        Row(
          children: [
            // Skip button
            Expanded(
              child: TextButton(
                onPressed: _skipSelection,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 15),
            
            // Sign Up button
            Expanded(
              child: OutlinedButton(
                onPressed: _navigateToSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 15),
        
        // Login button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _navigateToLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          '© 2025 Orbit Live',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'All rights reserved',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for animated background elements
class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw animated circles
    for (int i = 0; i < 15; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final radius = 5 + (progress * 10);
      final x = (size.width * 0.1) + (i * size.width * 0.08) % size.width;
      final y = (size.height * 0.2) + (progress * size.height * 0.6);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}