import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../auth/domain/user_role.dart';

class RoleSelectionSplashScreen extends StatefulWidget {
  const RoleSelectionSplashScreen({super.key});

  @override
  _RoleSelectionSplashScreenState createState() => _RoleSelectionSplashScreenState();
}

class _RoleSelectionSplashScreenState extends State<RoleSelectionSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  String? _selectedRole;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations after a delay
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with animated elements
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Hero(
                          tag: 'app_icon',
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.directions_bus,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Choose Your Role',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Select how you want to use the app',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Role Selection Cards
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 25),

                          // Passenger Card
                          _buildRoleCard(
                            context: context,
                            title: 'I am a Passenger',
                            subtitle: 'Book tickets, track buses, manage passes',
                            icon: Icons.person,
                            color: Colors.blue,
                            gradient: [Colors.blue, Colors.blue.shade300],
                            isSelected: _selectedRole == 'passenger',
                            onTap: () => _selectRole('passenger'),
                          ),

                          SizedBox(height: 25),

                          // Driver/Conductor Card
                          _buildRoleCard(
                            context: context,
                            title: 'I am a Driver/Conductor',
                            subtitle: 'Manage trips, track passengers, handle routes',
                            icon: Icons.drive_eta,
                            color: Colors.green,
                            gradient: [Colors.green, Colors.green.shade300],
                            isSelected: _selectedRole == 'driver',
                            onTap: () => _selectRole('driver'),
                          ),

                          SizedBox(height: 35),

                          // Next Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _selectedRole != null
                                  ? () => _navigateToNextScreen()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.deepPurple,
                                elevation: 10,
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 25),

                          // Skip option
                          TextButton(
                            onPressed: () => _showSkipDialog(),
                            child: Text(
                              'Skip - Use App Without Registration',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
              ? [gradient[1], gradient[0]] 
              : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? color.withOpacity(0.4) 
                : Colors.grey.withOpacity(0.2),
              blurRadius: isSelected ? 25 : 15,
              offset: Offset(0, isSelected ? 15 : 10),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected 
                    ? [Colors.white, Colors.white70] 
                    : [color.withOpacity(0.1), color.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 45,
                color: isSelected ? color : color.withOpacity(0.8),
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Show checkmark when selected
            if (isSelected)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: color,
                  size: 32,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _navigateToNextScreen() {
    if (_selectedRole == 'passenger') {
      _selectPassengerRole();
    } else if (_selectedRole == 'driver') {
      _selectDriverRole();
    }
  }

  void _selectPassengerRole() {
    // Navigate to passenger login screen
    Navigator.pushReplacementNamed(context, '/passenger-auth');
  }

  void _selectDriverRole() {
    // Navigate to driver login screen
    Navigator.pushReplacementNamed(context, '/driver-login');
  }

  void _showSkipDialog() {
    // Show a dialog to select role without registration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Your Role',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select your role to use the app without registration:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.blue, size: 28),
                ),
                title: Text(
                  'Passenger',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPassengerWithoutRegistration();
                },
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.drive_eta, color: Colors.green, size: 28),
                ),
                title: Text(
                  'Driver/Conductor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToDriverWithoutRegistration();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPassengerWithoutRegistration() {
    // Create a temporary user with passenger role for non-registered users
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setGuestUser(UserRole.passenger);
    
    // Navigate to passenger dashboard without registration
    Navigator.pushReplacementNamed(context, '/passenger');
  }

  void _navigateToDriverWithoutRegistration() {
    // For drivers, we still require login even when skipping initial registration
    Navigator.pushReplacementNamed(context, '/driver-login');
  }
}