import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class GuestNavigationDrawer extends StatelessWidget {
  const GuestNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade600,
              Colors.deepOrange.shade700,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade700,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.person_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Limited Access',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Home
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Already on home screen, just close drawer
              },
            ),
            
            Divider(color: Colors.white.withOpacity(0.3)),
            
            // View Routes
            ListTile(
              leading: Icon(Icons.map, color: Colors.white),
              title: Text(
                'View Routes',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/map');
              },
            ),
            
            // Bus Schedules
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.white),
              title: Text(
                'Bus Schedules',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Schedules available after login')),
                );
              },
            ),
            
            // Bus Stops
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text(
                'Bus Stops',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/map');
              },
            ),
            
            Divider(color: Colors.white.withOpacity(0.3)),
            
            // Create Account
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.white),
              title: Text(
                'Create Account',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showCreateAccountDialog(context);
              },
            ),
            
            // Login
            ListTile(
              leading: Icon(Icons.login, color: Colors.white),
              title: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _login(context);
              },
            ),
            
            Divider(color: Colors.white.withOpacity(0.3)),
            
            // About
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text(
                'About',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            
            // Help
            ListTile(
              leading: Icon(Icons.help, color: Colors.white),
              title: Text(
                'Help',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateAccountDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.disableGuestMode();
    Navigator.pushNamed(context, '/signup');
  }
  
  void _login(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.disableGuestMode();
    Navigator.pushNamed(context, '/login');
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Orbit Live'),
        content: Text(
          'Orbit Live is a public transport tracking and booking application that helps passengers and drivers manage their journeys efficiently.\n\n'
          'Guest users have limited access to features. Create an account to unlock full functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help'),
        content: Text(
          'As a guest user, you can:\n'
          '• View public bus routes\n'
          '• Locate bus stops\n\n'
          'To access additional features like ticket booking, passes, and personalized tracking, please create an account or log in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}