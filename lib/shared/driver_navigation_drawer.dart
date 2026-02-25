import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../core/localization_service.dart';
import '../core/connectivity_service.dart';
import '../features/auth/domain/user_role.dart';
import '../features/map/enhanced_map_screen.dart';
import '../features/complaint/presentation/complaint_screen.dart';

class DriverNavigationDrawer extends StatelessWidget {
  const DriverNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ConnectivityService>(
      builder: (context, authProvider, connectivityService, child) {
        final user = authProvider.user;
        // Remove the null check that was preventing the drawer from showing
        // The drawer should show for both authenticated and guest users

        return Drawer(
          child: Column(
            children: [
              // Drawer Header
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DrawerHeader(
                  decoration: BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.drive_eta,
                              size: 35,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user != null ? '${user.firstName} ${user.lastName}' : 'Guest Driver',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.role?.displayName ?? 'Driver',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                if (connectivityService.shouldUseLowBandwidthMode())
                                  Text(
                                    'Low Bandwidth Mode',
                                    style: TextStyle(
                                      color: Colors.yellow[200],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard,
                      title: context.translate('dashboard'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        // We're already on dashboard, so no navigation needed
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.map,
                      title: context.translate('live_tracking'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnhancedMapScreen(userRole: 'driver'),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.route,
                      title: context.translate('route_selection'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Route selection feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.history,
                      title: context.translate('trip_logs'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Trip logs feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      title: context.translate('passenger_count'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passenger count feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.warning,
                      title: context.translate('sos'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('SOS broadcast feature coming soon')),
                        );
                      },
                      isEmergency: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.directions_bus,
                      title: context.translate('manage_routes'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Route management feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      title: context.translate('manage_passengers'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passenger management feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.report_problem,
                      title: context.translate('raise_complaint'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintScreen(userRole: UserRole.driver),
                          ),
                        );
                      },
                    ),

                    Divider(),

                    // Settings and Logout
                    _buildMenuItem(
                      context,
                      icon: Icons.language,
                      title: context.translate('language'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        _showLanguageSelectionDialog(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: context.translate('settings'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Settings feature coming soon')),
                        );
                      },
                    ),
                    if (user != null) // Only show logout for authenticated users
                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: context.translate('logout'),
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          _logout(context, authProvider);
                        },
                        isDestructive: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isEmergency = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEmergency
              ? Colors.red.withValues(alpha: 0.1)
              : isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEmergency
              ? Colors.red
              : isDestructive
                  ? Colors.red
                  : Colors.green,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
  }
  
  void _showLanguageSelectionDialog(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    
    // Use fixed language names instead of translating them
    List<Map<String, String>> languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ'},
      {'code': 'hi', 'name': 'हिंदी'},
      {'code': 'te', 'name': 'తెలుగు'},
      {'code': 'ta', 'name': 'தமிழ்'},
      {'code': 'ml', 'name': 'മലയാളം'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ'},
      {'code': 'mr', 'name': 'मराठी'},
      {'code': 'bn', 'name': 'বাংলা'},
    ];
    
    // Get current locale to highlight selected language
    final currentLocale = localizationProvider.currentLocale;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final isSelected = currentLocale.languageCode == languages[index]['code'];
                return ListTile(
                  title: Text(languages[index]['name']!),
                  trailing: isSelected 
                    ? Icon(Icons.check, color: Colors.green) 
                    : null,
                  tileColor: isSelected 
                    ? Colors.blue.withValues(alpha: 0.1) 
                    : null,
                  onTap: () {
                    localizationProvider.setLocaleByLanguageCode(languages[index]['code']!);
                    Navigator.pop(context);
                    // Show a snackbar to indicate language change
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language changed to ${languages[index]['name']} successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Rebuild the entire app to apply language changes to all screens
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()), // Rebuild entire app
                      (route) => false,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}