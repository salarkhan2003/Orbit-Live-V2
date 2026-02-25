import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../shared/orbit_live_colors.dart';
import '../domain/user_role.dart';
import '../../travel_buddy/presentation/providers/travel_buddy_provider.dart';

/// Modern, stylish role selection screen with enhanced UI/UX
class StylishRoleSelectionScreen extends StatefulWidget {
  const StylishRoleSelectionScreen({super.key});

  @override
  State<StylishRoleSelectionScreen> createState() => _StylishRoleSelectionScreenState();
}

class _StylishRoleSelectionScreenState extends State<StylishRoleSelectionScreen>
    with TickerProviderStateMixin {
  UserRole? _selectedRole;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    // Start animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
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
        child: SafeArea(
          child: _isLoading 
            ? _buildLoadingState() 
            : Stack(
                children: [
                  // Background pattern
                  _buildBackgroundPattern(),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 40),
                        
                        // Role cards
                        Expanded(
                          child: _buildRoleCards(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
  
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(),
      ),
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
  
  Widget _buildHeader() {
    return Column(
      children: [
        // App logo with animation
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_bus,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 25),
        
        // Title with gradient text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white70],
          ).createShader(bounds),
          child: Text(
            'Orbit Live',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Subtitle
        Text(
          'Choose your role to get started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRoleCards() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Passenger Card with enhanced styling
          _buildEnhancedRoleCard(
            title: 'Passenger',
            subtitle: 'Book tickets, track buses, and find travel buddies',
            icon: Icons.person,
            gradientColors: const [Colors.blue, Colors.lightBlue],
            onTap: () => _selectRole(UserRole.passenger),
            isSelected: _selectedRole == UserRole.passenger,
          ),
          
          const SizedBox(height: 25),
          
          // Driver Card with enhanced styling
          _buildEnhancedRoleCard(
            title: 'Driver',
            subtitle: 'Manage trips, track passengers, and optimize routes',
            icon: Icons.drive_eta,
            gradientColors: const [Colors.green, Colors.lightGreen],
            onTap: () => _selectRole(UserRole.driver),
            isSelected: _selectedRole == UserRole.driver,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return ScaleTransition(
      scale: isSelected ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isSelected 
                  ? [gradientColors[1], gradientColors[0]] 
                  : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? gradientColors.first.withValues(alpha: 0.5) 
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: isSelected ? 25 : 15,
                spreadRadius: isSelected ? 3 : 0,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container with enhanced styling
              Container(
                width: 130,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 50,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white70 : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: 25),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 24,
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
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _selectedRole != null ? _submitRole : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: OrbitLiveColors.primaryTeal,
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBackgroundColor: Colors.white30,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Continue as ${_selectedRole?.displayName ?? 'Selected Role'}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
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
}

/// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw animated circles in a grid pattern
    for (int i = 0; i < 30; i++) {
      final x = (i * 50) % size.width;
      final y = (i * 40) % size.height;
      final radius = 8.0 + (i % 4);
      
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}