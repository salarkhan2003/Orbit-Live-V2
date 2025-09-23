import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/guest_navigation_drawer.dart';
import '../../../core/localization_service.dart';
import '../../../main.dart';

class GuestDashboard extends StatefulWidget {
  const GuestDashboard({super.key});

  @override
  _GuestDashboardState createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${context.translate('dashboard')} - Guest'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => _showCreateAccountDialog(context),
            tooltip: 'Create Account',
          ),
        ],
      ),
      drawer: GuestNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuestWelcomeCard(context),
            SizedBox(height: 20),
            _buildLimitedFeaturesCard(context),
            SizedBox(height: 20),
            _buildPublicInfoCard(context),
            SizedBox(height: 20),
            _buildCreateAccountPrompt(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Guest!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Explore public transport information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showCreateAccountDialog(context),
              child: Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitedFeaturesCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Available Features (Guest Mode)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.map,
              title: 'View Routes',
              subtitle: 'Browse available bus routes',
              enabled: true,
              onTap: () => _showFeature('Route information'),
            ),
            _buildFeatureItem(
              icon: Icons.schedule,
              title: 'Bus Schedules',
              subtitle: 'Check bus timings',
              enabled: true,
              onTap: () => _showFeature('Schedule information'),
            ),
            _buildFeatureItem(
              icon: Icons.location_on,
              title: 'Bus Stops',
              subtitle: 'Find nearby bus stops',
              enabled: true,
              onTap: () => _showFeature('Bus stop information'),
            ),
            Divider(),
            Text(
              'Limited Features - Create Account to Unlock:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            _buildFeatureItem(
              icon: Icons.confirmation_number,
              title: 'Book Tickets',
              subtitle: 'Digital ticket booking',
              enabled: false,
              onTap: () => _showCreateAccountDialog(context),
            ),
            _buildFeatureItem(
              icon: Icons.card_membership,
              title: 'Passes',
              subtitle: 'Monthly/annual passes',
              enabled: false,
              onTap: () => _showCreateAccountDialog(context),
            ),
            _buildFeatureItem(
              icon: Icons.history,
              title: 'Travel History',
              subtitle: 'Track your journeys',
              enabled: false,
              onTap: () => _showCreateAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? Colors.blue : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey,
          fontWeight: enabled ? FontWeight.normal : FontWeight.w300,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: enabled
        ? Icon(Icons.arrow_forward_ios, size: 16)
        : Icon(Icons.lock, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPublicInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Public Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green.shade50,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: Colors.green.shade400,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Public Route Map',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View all available bus routes',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountPrompt(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.star,
              size: 48,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Unlock Full Features!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create an account to access ticket booking, passes, live tracking, and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _createAccount(),
                    child: Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _login(),
                    child: Text('Login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFeature(String feature) {
    // Instead of showing "Coming soon", provide actual functionality or explanation
    if (feature == 'Route information') {
      Navigator.pushNamed(context, '/map');
    } else if (feature == 'Schedule information') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus schedules are available after login')),
      );
    } else if (feature == 'Bus stop information') {
      Navigator.pushNamed(context, '/map');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This feature is available after login')),
      );
    }
  }

  void _showCreateAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Account'),
        content: Text('Create an account to unlock all features including ticket booking, passes, and personalized experience.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createAccount();
            },
            child: Text('Sign Up Now'),
          ),
        ],
      ),
    );
  }

  void _createAccount() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.disableGuestMode();
    Navigator.pushNamed(context, '/signup');
  }

  void _login() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.disableGuestMode();
    Navigator.pushNamed(context, '/login');
  }
}
