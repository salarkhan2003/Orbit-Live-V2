import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../domain/user_role.dart';
import '../../passenger/presentation/passenger_dashboard.dart';
import '../../driver/presentation/driver_login_page.dart';
import 'passenger_otp_login_screen.dart';

/// Clean Role Selection Screen - Only Passenger and Driver
class CleanRoleSelectionScreen extends StatefulWidget {
  const CleanRoleSelectionScreen({super.key});

  @override
  State<CleanRoleSelectionScreen> createState() => _CleanRoleSelectionScreenState();
}

class _CleanRoleSelectionScreenState extends State<CleanRoleSelectionScreen> with SingleTickerProviderStateMixin {
  UserRole? _selectedRole;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() => _selectedRole = role);
  }

  void _continueWithRole() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role first'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedRole == UserRole.passenger) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerOtpLoginScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverLoginPage()));
    }
  }

  void _continueAsGuest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Continue as Guest'),
        content: const Text('Select your role to continue:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loginAsGuest(UserRole.passenger);
            },
            child: const Text('Passenger'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loginAsGuest(UserRole.driver);
            },
            child: const Text('Driver'),
          ),
        ],
      ),
    );
  }

  void _loginAsGuest(UserRole role) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setAuthenticatedUser(
      id: 'guest_${role.name}_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@orbitlive.com',
      firstName: 'Guest',
      lastName: role == UserRole.passenger ? 'Passenger' : 'Driver',
      phoneNumber: '',
      role: role,
    );

    if (role == UserRole.passenger) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PassengerDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverLoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_bus, size: 56, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Orbit Live',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Choose your role to get started',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const Spacer(),

                  // Role Cards
                  _buildRoleCard(
                    title: 'Passenger',
                    description: 'Track buses, book tickets, find travel buddies',
                    icon: Icons.person,
                    color: const Color(0xFF3498db),
                    isSelected: _selectedRole == UserRole.passenger,
                    onTap: () => _selectRole(UserRole.passenger),
                  ),

                  const SizedBox(height: 16),

                  _buildRoleCard(
                    title: 'Driver / Conductor',
                    description: 'Manage trips, track passengers, handle payments',
                    icon: Icons.drive_eta,
                    color: const Color(0xFF2ecc71),
                    isSelected: _selectedRole == UserRole.driver,
                    onTap: () => _selectRole(UserRole.driver),
                  ),

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedRole != null ? _continueWithRole : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2575FC),
                        disabledBackgroundColor: Colors.white30,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 8,
                      ),
                      child: Text(
                        _selectedRole != null ? 'Continue as ${_selectedRole == UserRole.passenger ? "Passenger" : "Driver"}' : 'Select a Role',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Guest Mode Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Skip / Guest Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: isSelected ? color : Colors.white70),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.white)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 13, color: isSelected ? Colors.black54 : Colors.white70)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

