import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../core/localization_service.dart';
import '../core/connectivity_service.dart';
import '../features/auth/domain/user_role.dart';
import '../features/map/openstreet_map_screen.dart';
import '../features/complaint/presentation/complaint_screen.dart';

class PassengerNavigationDrawer extends StatelessWidget {
  const PassengerNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ConnectivityService>(
      builder: (context, authProvider, connectivityService, child) {
        final user = authProvider.user;
        if (user == null) return SizedBox.shrink();

        return Drawer(
          child: Column(
            children: [
              // Drawer Header
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade400],
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
                              Icons.person,
                              size: 35,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.role?.displayName ?? '',
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
                            builder: (context) => OpenStreetMapScreen(userRole: 'passenger'),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.confirmation_number,
                      title: context.translate('book_ticket'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ticket booking feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.card_membership,
                      title: context.translate('my_passes'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pass management feature coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.emergency,
                      title: context.translate('sos'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Emergency assistance feature coming soon')),
                        );
                      },
                      isEmergency: true,
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
                            builder: (context) => ComplaintScreen(userRole: UserRole.passenger),
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
              ? Colors.red.withOpacity(0.1)
              : isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEmergency
              ? Colors.red
              : isDestructive
                  ? Colors.red
                  : Colors.blue,
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
    Navigator.pushNamedAndRemoveUntil(context, '/role-selection-splash', (route) => false);
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
                return ListTile(
                  title: Text(languages[index]['name']!),
                  onTap: () {
                    localizationProvider.setLocaleByLanguageCode(languages[index]['code']!);
                    Navigator.pop(context);
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