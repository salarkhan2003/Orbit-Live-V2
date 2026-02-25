import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../domain/user_role.dart';
import '../../travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../../../main.dart';

/// Improved role selection screen with clean, modern UI/UX
class ImprovedRoleSelectionScreen extends StatefulWidget {
  const ImprovedRoleSelectionScreen({super.key});

  @override
  State<ImprovedRoleSelectionScreen> createState() => _ImprovedRoleSelectionScreenState();
}

class _ImprovedRoleSelectionScreenState extends State<ImprovedRoleSelectionScreen>
    with TickerProviderStateMixin {
  UserRole? _selectedRole;
  bool _isLoading = false;

  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Simplified animation controllers for better performance
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30), // Slower repeat for less CPU usage
      vsync: this,
    )..repeat();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced duration
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(seconds: 3), // Slower repeat
      vsync: this,
    )..repeat(reverse: true);
    
    // Simplified animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    _cardScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Start animations with minimal stagger
    Future.delayed(const Duration(milliseconds: 100), () {
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
            Navigator.pushReplacementNamed(context, '/driver-login');
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

  // Language selection method
  void _showLanguageSelector() {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocalizationService.localizedValues[localizationProvider.currentLocale.languageCode]?['language'] ?? 'Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              
              // Language options
              ...LocalizationService.supportedLocales.map((locale) {
                final languageName = LocalizationService.localizedValues[locale.languageCode]?['language'] ?? locale.languageCode;
                final isSelected = localizationProvider.currentLocale.languageCode == locale.languageCode;
                
                return ListTile(
                  title: Text(
                    languageName!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? OrbitLiveColors.primaryTeal : Colors.black87,
                    ),
                  ),
                  trailing: isSelected 
                    ? Icon(Icons.check, color: OrbitLiveColors.primaryTeal) 
                    : null,
                  onTap: () {
                    // Simple locale change without complex state management
                    localizationProvider.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading 
            ? _buildLoadingState() 
            : Stack(
                children: [
                  // Animated background
                  _buildAnimatedBackground(),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Header with language selector
                        _buildHeaderWithLanguageSelector(),
                        
                        const SizedBox(height: 20),
                        
                        // Role cards
                        Expanded(
                          child: _buildRoleCards(),
                        ),
                        
                        const SizedBox(height: 16),
                        
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
  
  Widget _buildHeaderWithLanguageSelector() {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    
    return Column(
      children: [
        // Top bar with language selector
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _showLanguageSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocalizationService.localizedValues[localizationProvider.currentLocale.languageCode]?['language'] ?? 'Language',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // App logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_bus,
            size: 56,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Title
        Text(
          'Orbit Live',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          LocalizationService.localizedValues[localizationProvider.currentLocale.languageCode]?['select_role'] ?? 'Choose your role to get started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRoleCards() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: ScaleTransition(
        scale: _cardScaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Passenger Card
            _buildRoleCard(
              title: 'Passenger',
              description: 'Book tickets, track buses in real-time, and find travel buddies',
              icon: Icons.person,
              color: Color(0xFF3498db),
              onTap: () => _selectRole(UserRole.passenger),
              isSelected: _selectedRole == UserRole.passenger,
            ),
            
            const SizedBox(height: 16),
            
            // Conductor Card (changed from Driver Card)
            _buildRoleCard(
              title: 'Conductor',
              description: 'Manage trips, track passengers, and optimize your routes',
              icon: Icons.drive_eta,
              color: Color(0xFF2ecc71),
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
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? color.withValues(alpha: 0.4) 
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: isSelected ? 16 : 10,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withValues(alpha: 0.2) 
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? color : Colors.white70,
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.black87 : Colors.white70,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action button with shorter text to prevent overlay issues
        ScaleTransition(
          scale: _buttonPulseAnimation,
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _selectedRole != null ? _submitRole : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF2575FC),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.white30,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                _selectedRole != null 
                  ? 'Continue as ${_selectedRole!.displayName}' 
                  : 'Select Role',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary actions row
        Row(
          children: [
            // Skip button
            Expanded(
              child: TextButton(
                onPressed: _skipSelection,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Sign Up button
            Expanded(
              child: OutlinedButton(
                onPressed: _navigateToSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 10),
        
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final radius = 5 + (progress * 15);
      final x = (size.width * 0.1) + (i * size.width * 0.1) % size.width;
      final y = (size.height * 0.2) + (progress * size.height * 0.6);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}