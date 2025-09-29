import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/connectivity_service.dart';
import '../../../core/localization_service.dart';
import '../../auth/domain/user_role.dart';
import '../../map/openstreet_map_screen.dart';
import '../../../shared/passenger_navigation_drawer.dart';

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
    OpenStreetMapScreen(userRole: 'passenger'),
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
        shadowColor: Colors.blue.withOpacity(0.3),
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
              color: Colors.black.withOpacity(0.1),
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
          color: color.withOpacity(0.1),
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
          colors: [Colors.blue, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.2),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Consumer<ConnectivityService>(
                    builder: (context, connectivityService, child) {
                      return Text(
                        connectivityService.shouldUseLowBandwidthMode()
                            ? 'Optimized for low bandwidth'
                            : 'Track your buses and manage your travels',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, color: Colors.blue, size: 25),
                ),
                SizedBox(width: 12),
                Text(
                  'Find Your Bus',
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'From',
                  hintText: 'Enter starting point',
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
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
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to map screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenStreetMapScreen(userRole: 'passenger'),
                    ),
                  );
                },
                icon: Icon(Icons.directions_bus, size: 22),
                label: Text(
                  'Search Buses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: context.translate('live_tracking'),
                icon: Icons.map,
                color: Colors.green,
                onTap: () => _navigateToLiveTracking(context),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                context,
                title: context.translate('book_ticket'),
                icon: Icons.confirmation_number,
                color: Colors.orange,
                onTap: () => _navigateToBookTicket(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: context.translate('my_passes'),
                icon: Icons.card_membership,
                color: Colors.purple,
                onTap: () => _navigateToMyPasses(context),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'TravelBuddy',
                icon: Icons.people,
                color: Colors.teal,
                onTap: () => _navigateToTravelBuddy(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: context.translate('sos'),
                icon: Icons.emergency,
                color: Colors.red,
                onTap: () => _navigateToSOS(context),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
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
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 35,
                  color: color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLiveTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpenStreetMapScreen(userRole: 'passenger'),
      ),
    );
  }

  void _navigateToBookTicket(BuildContext context) {
    Navigator.pushNamed(context, '/ticket-booking');
  }

  void _navigateToMyPasses(BuildContext context) {
    Navigator.pushNamed(context, '/pass-application');
  }

  void _navigateToSOS(BuildContext context) {
    // Show actual emergency assistance
    _showFeatureDialog(context, 'SOS', 'Emergency assistance feature is now available.');
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
            color: Colors.grey.withOpacity(0.2),
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
                    color: Colors.green.withOpacity(0.1),
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
            // Simplified map view
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildSimplifiedMap(),
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

  Widget _buildSimplifiedMap() {
    return Stack(
      children: [
        // Map background
        Container(
          color: Colors.blue[50],
          child: Center(
            child: Icon(
              Icons.map,
              size: 50,
              color: Colors.blue[300],
            ),
          ),
        ),
        // Route line
        CustomPaint(
          painter: RoutePainter(),
          size: Size(double.infinity, double.infinity),
        ),
        // Bus markers
        Positioned(
          left: 50,
          top: 80,
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 70,
          top: 120,
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // User location
        Positioned(
          left: 100,
          bottom: 60,
          child: Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 30,
          ),
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
            color: Colors.grey.withOpacity(0.2),
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
                    color: Colors.orange.withOpacity(0.1),
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
                          color: Colors.orange.withOpacity(0.1),
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
                  _showFeatureDialog(context, 'All Tickets', 'View all tickets feature is now available.');
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
            color: Colors.grey.withOpacity(0.2),
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
                    color: Colors.purple.withOpacity(0.1),
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
                  _showFeatureDialog(context, 'Manage Passes', 'Pass management feature is now available.');
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
              color: Colors.grey.withOpacity(0.1),
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
                colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
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
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
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
