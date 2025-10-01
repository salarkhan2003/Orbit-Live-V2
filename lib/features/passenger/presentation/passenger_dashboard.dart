import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import '../../../main.dart';
import '../../../core/connectivity_service.dart';
import '../../auth/domain/user_role.dart';
import '../../map/enhanced_map_screen.dart';
import '../../../shared/passenger_navigation_drawer.dart';
import '../../travel_buddy/domain/travel_buddy_models.dart';
import '../../travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../complaint/presentation/complaint_screen.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  _PassengerDashboardState createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _pages = [
    // Home screen with all features
    _HomeScreen(),
    // Map screen
    EnhancedMapScreen(userRole: 'passenger'),
    // Explore screen
    _ExploreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(_currentIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivityService, child) {
              return IconButton(
                icon: Icon(
                  connectivityService.isLowBandwidth 
                    ? Icons.network_cell 
                    : Icons.network_wifi,
                  color: connectivityService.isLowBandwidth 
                    ? Colors.orange 
                    : Colors.green,
                ),
                onPressed: () {
                  _showConnectivityStatus(context, connectivityService);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
        ],
        elevation: 5,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      ),
      drawer: PassengerNavigationDrawer(),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Map';
      case 2:
        return 'Explore';
      default:
        return 'Home';
    }
  }

  void _showConnectivityStatus(BuildContext context, ConnectivityService connectivityService) {
    final isLowBandwidth = connectivityService.shouldUseLowBandwidthMode();
    final connectionType = connectivityService.connectionStatus.toString().split('.').last;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLowBandwidth 
            ? 'Low bandwidth mode: Using cached data and reduced quality' 
            : 'Good connection: Full quality experience',
        ),
        backgroundColor: isLowBandwidth ? Colors.orange : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem(
                'Bus Delayed',
                'Your bus on Route 101 is delayed by 10 minutes',
                Icons.directions_bus,
                Colors.orange,
              ),
              Divider(),
              _buildNotificationItem(
                'New Route Added',
                'Route 404 now connects to the Airport',
                Icons.route,
                Colors.blue,
              ),
              Divider(),
              _buildNotificationItem(
                'Special Offer',
                'Get 20% off on monthly passes this week',
                Icons.card_giftcard,
                Colors.green,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          SizedBox(height: 25),
          _buildRouteSearchCard(context),
          SizedBox(height: 25),
          _buildQuickActions(context),
          SizedBox(height: 25),
          _buildLiveTrackingCard(context),
          SizedBox(height: 25),
          _buildRecentTicketsCard(context),
          SizedBox(height: 25),
          _buildPassesCard(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: OrbitLiveColors.blueGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_bus,
                size: 45,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: OrbitLiveTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Consumer<ConnectivityService>(
                    builder: (context, connectivityService, child) {
                      return Text(
                        connectivityService.shouldUseLowBandwidthMode()
                            ? 'Optimized for low bandwidth'
                            : 'Track your buses and manage your travels',
                        style: OrbitLiveTextStyles.bodyMedium.copyWith(
                          color: Colors.white, // Keep white for contrast on blue gradient
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSearchCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: OrbitLiveColors.tealGradient,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, color: Colors.white, size: 25),
                ),
                SizedBox(width: 12),
                Text(
                  'Find Your Bus',
                  style: OrbitLiveTextStyles.displaySmall.copyWith(
                    color: OrbitLiveColors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'From',
                  hintText: 'Enter starting point',
                  prefixIcon: Icon(Icons.location_on, color: OrbitLiveColors.primaryTeal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  labelStyle: TextStyle(
                    color: OrbitLiveColors.black, // Ensure visibility
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey, // Ensure visibility
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'To',
                  hintText: 'Enter destination',
                  prefixIcon: Icon(Icons.location_on, color: OrbitLiveColors.primaryTeal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  labelStyle: TextStyle(
                    color: OrbitLiveColors.black, // Ensure visibility
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey, // Ensure visibility
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to map screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnhancedMapScreen(userRole: 'passenger'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Search Buses',
                  style: OrbitLiveTextStyles.buttonPrimary.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: OrbitLiveTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: OrbitLiveColors.darkGray,
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel & Booking Section
                _buildSectionHeader('Travel & Booking'),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernQuickActionButton(
                      context,
                      Icons.confirmation_number,
                      'Book Ticket',
                      'Reserve your seat',
                      () => Navigator.pushNamed(context, '/ticket-booking'),
                      OrbitLiveColors.primaryTeal,
                    ),
                    _buildModernQuickActionButton(
                      context,
                      Icons.card_membership,
                      'My Passes',
                      'View & manage passes',
                      () => Navigator.pushNamed(context, '/pass-application'),
                      Colors.purple,
                    ),
                    _buildModernQuickActionButton(
                      context,
                      Icons.people,
                      'Travel Buddy',
                      'Find companions',
                      () => Navigator.pushNamed(context, '/travel-buddy'),
                      Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 25),
                // Safety & Support Section
                _buildSectionHeader('Safety & Support'),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernQuickActionButton(
                      context,
                      Icons.emergency,
                      'SOS',
                      'Emergency help',
                      () => _triggerSOS(context),
                      Colors.red,
                    ),
                    _buildModernQuickActionButton(
                      context,
                      Icons.report_problem,
                      'Complaint',
                      'Report issues',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintScreen(userRole: UserRole.passenger),
                        ),
                      ),
                      Colors.blue,
                    ),
                    _buildModernQuickActionButton(
                      context,
                      Icons.settings,
                      'Settings',
                      'App preferences',
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Settings feature coming soon')),
                      ),
                      Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: OrbitLiveTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: OrbitLiveColors.darkGray,
        ),
      ),
    );
  }

  Widget _buildModernQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onPressed,
    Color color,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100, // Increased width for better touch target
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: OrbitLiveTextStyles.caption.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _triggerSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red),
              SizedBox(width: 10),
              Text('Emergency Assistance'),
            ],
          ),
          content: Text(
            'Are you in immediate danger? This will send your location to emergency services and your travel buddy (if connected).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendSOSAlert(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Send Emergency Alert', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSOSAlert(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Sending emergency alert...'),
            ],
          ),
        );
      },
    );

    try {
      // Get current location (in a real app, this would be actual GPS location)
      // For demo purposes, we'll use a mock location
      final location = TravelBuddyLocation(
        latitude: 16.3067, // Guntur latitude
        longitude: 80.4365, // Guntur longitude
        timestamp: DateTime.now(),
      );

      // Send SOS alert through travel buddy provider
      final travelBuddyProvider = Provider.of<TravelBuddyProvider>(
        context,
        listen: false,
      );
      
      final success = await travelBuddyProvider.sendSOSAlert(
        location: location,
        message: 'Emergency SOS from passenger at Guntur location',
      );

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency alert sent successfully! Help is on the way.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send emergency alert. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending emergency alert: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToTravelBuddy(BuildContext context) {
    Navigator.pushNamed(context, '/travel-buddy');
  }

  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on, color: Colors.green, size: 25),
                ),
                SizedBox(width: 12),
                Text(
                  'Live Tracking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.network_cell, color: Colors.orange, size: 20),
              ],
            ),
            SizedBox(height: 20),
            // OpenStreetMap view
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildOpenStreetMap(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus No: KA-01-A-1234',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Route: Central Station to Airport',
                      style: TextStyle(
                        color: Colors.grey[600], 
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'On Time',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next stop: Mall Road', 
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'ETA: 5 min', 
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenStreetMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(16.3067, 80.4365), // Guntur coordinates
        initialZoom: 13.0,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.none), // Disable interaction for simplicity
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.orbit.live',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(16.3067, 80.4365), // Guntur Central
              width: 80,
              height: 80,
              child: Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 40,
              ),
            ),
            Marker(
              point: LatLng(16.2987, 80.4425), // Tenali
              width: 80,
              height: 80,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '12',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Marker(
              point: LatLng(16.2927, 80.4505), // Mangalagiri
              width: 80,
              height: 80,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '34',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                LatLng(16.3067, 80.4365), // Guntur Central
                LatLng(16.3000, 80.4400),  // Mid point
                LatLng(16.2987, 80.4425),  // Tenali
              ],
              strokeWidth: 4.0,
              color: Colors.blue.withValues(alpha: 0.7),
            ),
            Polyline(
              points: [
                LatLng(16.3067, 80.4365), // Guntur Central
                LatLng(16.2997, 80.4435), // Mid point
                LatLng(16.2927, 80.4505), // Mangalagiri
              ],
              strokeWidth: 4.0,
              color: Colors.green.withValues(alpha: 0.7),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTicketsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_number, color: Colors.orange, size: 25),
                ),
                SizedBox(width: 12),
                Text(
                  'Recent Tickets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.confirmation_number, color: Colors.orange),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket #${1001 + index}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Route: Station to Mall',
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${50 + index * 10}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all-tickets');
                },
                child: Text(
                  'View All Tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.card_membership, color: Colors.purple, size: 25),
                ),
                SizedBox(width: 12),
                Text(
                  'Active Passes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple.shade200!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Pass',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.purple.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valid until: 15 Oct 2025',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹300',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.grey[300],
                    color: Colors.purple,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '15 days remaining',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all-passes');
                },
                child: Text(
                  'Manage Passes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.purple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 25),
          _buildExploreCard(
            context,
            title: 'Bus Routes',
            subtitle: 'Explore all available bus routes in your city',
            icon: Icons.route,
            color: Colors.blue,
            onTap: () => _showFeatureDialog(context, 'Bus Routes', 'Bus routes feature is now available.'),
          ),
          SizedBox(height: 20),
          _buildExploreCard(
            context,
            title: 'Nearby Stops',
            subtitle: 'Find bus stops near your current location',
            icon: Icons.location_on,
            color: Colors.green,
            onTap: () => _showFeatureDialog(context, 'Nearby Stops', 'Nearby stops feature is now available.'),
          ),
          SizedBox(height: 20),
          _buildExploreCard(
            context,
            title: 'Timetables',
            subtitle: 'View detailed schedules for all routes',
            icon: Icons.access_time,
            color: Colors.orange,
            onTap: () => _showFeatureDialog(context, 'Timetables', 'Timetables feature is now available.'),
          ),
          SizedBox(height: 20),
          _buildExploreCard(
            context,
            title: 'Fare Calculator',
            subtitle: 'Calculate fare for your journey',
            icon: Icons.calculate,
            color: Colors.purple,
            onTap: () => _showFeatureDialog(context, 'Fare Calculator', 'Fare calculator feature is now available.'),
          ),
          SizedBox(height: 20),
          _buildExploreCard(
            context,
            title: 'Service Alerts',
            subtitle: 'Get notified about service disruptions',
            icon: Icons.notifications_active,
            color: Colors.red,
            onTap: () => _showFeatureDialog(context, 'Service Alerts', 'Service alerts feature is now available.'),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = ui.Path()
      ..moveTo(20, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.5,
        size.width - 20,
        40,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
