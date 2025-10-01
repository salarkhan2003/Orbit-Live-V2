import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/orbit_live_colors.dart';

class EnhancedMapScreen extends StatefulWidget {
  final String userRole;

  const EnhancedMapScreen({super.key, required this.userRole});

  @override
  _EnhancedMapScreenState createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> with TickerProviderStateMixin {
  late MapController _mapController;
  late Timer _locationUpdateTimer;
  late Timer _busUpdateTimer;
  late AnimationController _pulseController;
  
  bool _isLoading = true;
  bool _isNavigationMode = false;
  bool _locationPermissionGranted = false;
  Map<String, dynamic>? _selectedBus;
  
  List<Marker> _busMarkers = [];
  List<Polyline> _routePolylines = [];
  List<Marker> _stopMarkers = [];
  // Set Guntur as default location (16.3067° N, 80.4365° E)
  LatLng _currentLocation = LatLng(16.3067, 80.4365);
  double _mapZoom = 13.0;
  
  // Mock data for buses
  List<Map<String, dynamic>> _mockBuses = [
    {
      'id': 'bus_1',
      'number': 'GT-01-A-1234',
      'location': LatLng(16.3067, 80.4365),
      'route': 'Route 101',
      'occupancy': 0.6,
      'nextStop': 'RTC Bus Stand',
      'eta': 5,
      'from': 'Guntur Central',
      'to': 'Tenali',
      'speed': 25,
      'stops': [
        {'name': 'Guntur Central', 'time': '08:00', 'passed': true},
        {'name': 'RTC Bus Stand', 'time': '08:15', 'passed': true},
        {'name': 'Namburu', 'time': '08:25', 'passed': false},
        {'name': 'Gurazala', 'time': '08:35', 'passed': false},
        {'name': 'Kollipara', 'time': '08:45', 'passed': false},
        {'name': 'Tenali', 'time': '08:55', 'passed': false},
      ],
      'delay': 0,
      'type': 'AC Volvo',
      'driverContact': '+91 9876543210',
    },
    {
      'id': 'bus_2',
      'number': 'GT-01-B-5678',
      'location': LatLng(16.2987, 80.4425),
      'route': 'Route 202',
      'occupancy': 0.3,
      'nextStop': 'Lakshmipuram',
      'eta': 12,
      'from': 'Guntur Central',
      'to': 'Mangalagiri',
      'speed': 30,
      'stops': [
        {'name': 'Guntur Central', 'time': '08:10', 'passed': true},
        {'name': 'Lakshmipuram', 'time': '08:20', 'passed': false},
        {'name': 'Amaravati Road', 'time': '08:30', 'passed': false},
        {'name': 'Pedakakani', 'time': '08:40', 'passed': false},
        {'name': 'Mangalagiri', 'time': '08:50', 'passed': false},
      ],
      'delay': 5,
      'type': 'Non-AC',
      'driverContact': '+91 9876543211',
    },
    {
      'id': 'bus_3',
      'number': 'GT-01-C-9012',
      'location': LatLng(16.3127, 80.4285),
      'route': 'Route 303',
      'occupancy': 0.8,
      'nextStop': 'Amaravati Road',
      'eta': 8,
      'from': 'Mangalagiri',
      'to': 'Guntur Central',
      'speed': 20,
      'stops': [
        {'name': 'Mangalagiri', 'time': '08:05', 'passed': true},
        {'name': 'Pedakakani', 'time': '08:15', 'passed': true},
        {'name': 'Amaravati Road', 'time': '08:25', 'passed': false},
        {'name': 'Lakshmipuram', 'time': '08:35', 'passed': false},
        {'name': 'Guntur Central', 'time': '08:45', 'passed': false},
      ],
      'delay': -2,
      'type': 'AC Multi-Axle',
      'driverContact': '+91 9876543212',
    },
    // Additional buses for more routes
    {
      'id': 'bus_4',
      'number': 'GT-01-D-3456',
      'location': LatLng(16.3207, 80.4205),
      'route': 'Route 404',
      'occupancy': 0.4,
      'nextStop': 'Pedakakani',
      'eta': 7,
      'from': 'Amaravati Road',
      'to': 'Mangalagiri',
      'speed': 28,
      'stops': [
        {'name': 'Amaravati Road', 'time': '08:15', 'passed': true},
        {'name': 'Pedakakani', 'time': '08:25', 'passed': false},
        {'name': 'Mangalagiri', 'time': '08:35', 'passed': false},
      ],
      'delay': 2,
      'type': 'AC Semi-Sleeper',
      'driverContact': '+91 9876543213',
    },
    {
      'id': 'bus_5',
      'number': 'GT-01-E-7890',
      'location': LatLng(16.2857, 80.4585),
      'route': 'Route 505',
      'occupancy': 0.9,
      'nextStop': 'Kollipara',
      'eta': 15,
      'from': 'Namburu',
      'to': 'Tenali',
      'speed': 22,
      'stops': [
        {'name': 'Namburu', 'time': '08:00', 'passed': true},
        {'name': 'Gurazala', 'time': '08:10', 'passed': false},
        {'name': 'Kollipara', 'time': '08:20', 'passed': false},
        {'name': 'Tenali', 'time': '08:30', 'passed': false},
      ],
      'delay': 3,
      'type': 'Non-AC',
      'driverContact': '+91 9876543214',
    },
  ];

  // Enhanced mock route data for Guntur with more routes
  Map<String, List<LatLng>> _routePaths = {
    'Route 101': [
      LatLng(16.3067, 80.4365),
      LatLng(16.2987, 80.4425),
      LatLng(16.2927, 80.4505),
      LatLng(16.2857, 80.4585),
      LatLng(16.2787, 80.4665),
      LatLng(16.2717, 80.4745),
    ],
    'Route 202': [
      LatLng(16.3067, 80.4365),
      LatLng(16.3127, 80.4285),
      LatLng(16.3207, 80.4205),
      LatLng(16.3287, 80.4125),
      LatLng(16.3367, 80.4045),
    ],
    'Route 303': [
      LatLng(16.3367, 80.4045),
      LatLng(16.3287, 80.4125),
      LatLng(16.3207, 80.4205),
      LatLng(16.3127, 80.4285),
      LatLng(16.3067, 80.4365),
    ],
    'Route 404': [
      LatLng(16.3207, 80.4205),
      LatLng(16.3287, 80.4125),
      LatLng(16.3367, 80.4045),
    ],
    'Route 505': [
      LatLng(16.2927, 80.4505),
      LatLng(16.2857, 80.4585),
      LatLng(16.2787, 80.4665),
      LatLng(16.2717, 80.4745),
    ],
  };

  // Enhanced mock stop data with more stops
  List<Map<String, dynamic>> _mockStops = [
    {'name': 'Guntur Central', 'location': LatLng(16.3067, 80.4365), 'routes': ['Route 101', 'Route 202']},
    {'name': 'RTC Bus Stand', 'location': LatLng(16.2987, 80.4425), 'routes': ['Route 101']},
    {'name': 'Lakshmipuram', 'location': LatLng(16.3127, 80.4285), 'routes': ['Route 202', 'Route 303']},
    {'name': 'Namburu', 'location': LatLng(16.2927, 80.4505), 'routes': ['Route 101', 'Route 505']},
    {'name': 'Amaravati Road', 'location': LatLng(16.3207, 80.4205), 'routes': ['Route 202', 'Route 303', 'Route 404']},
    {'name': 'Gurazala', 'location': LatLng(16.2857, 80.4585), 'routes': ['Route 101', 'Route 505']},
    {'name': 'Pedakakani', 'location': LatLng(16.3287, 80.4125), 'routes': ['Route 202', 'Route 303', 'Route 404']},
    {'name': 'Kollipara', 'location': LatLng(16.2787, 80.4665), 'routes': ['Route 101', 'Route 505']},
    {'name': 'Mangalagiri', 'location': LatLng(16.3367, 80.4045), 'routes': ['Route 202', 'Route 303', 'Route 404']},
    {'name': 'Tenali', 'location': LatLng(16.2717, 80.4745), 'routes': ['Route 101', 'Route 505']},
    {'name': 'Vijayawada Road', 'location': LatLng(16.3157, 80.4305), 'routes': ['Route 202']},
    {'name': 'Ring Road', 'location': LatLng(16.3007, 80.4405), 'routes': ['Route 101']},
    {'name': 'Auto Nagar', 'location': LatLng(16.3257, 80.4155), 'routes': ['Route 202', 'Route 404']},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Initialize map faster by setting initial state
    _isLoading = false;
    
    // Use a delayed future to initialize data without blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    // Request location permission
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    } else {
      // Use default location if permission denied
      _initializeMap();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium), // Use medium accuracy for faster results
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      // Move map to current location
      _mapController.move(_currentLocation, _mapZoom);
      
      _initializeMap();
    } catch (e) {
      // Fallback to default location if unable to get current location
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    // Create enhanced stop markers for Guntur with animations
    _stopMarkers = _mockStops.map((stop) {
      return Marker(
        point: stop['location'],
        child: GestureDetector(
          onTap: () => _onStopTap(stop),
          child: Container(
            width: 30,
            height: 30,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }).toList();
    
    // Create route polylines with different colors for each route
    _routePolylines = _routePaths.entries.map((entry) {
      Color routeColor;
      switch(entry.key) {
        case 'Route 101':
          routeColor = Colors.blue;
          break;
        case 'Route 202':
          routeColor = Colors.green;
          break;
        case 'Route 303':
          routeColor = Colors.purple;
          break;
        case 'Route 404':
          routeColor = Colors.orange;
          break;
        case 'Route 505':
          routeColor = Colors.red;
          break;
        default:
          routeColor = Colors.grey;
      }
      
      return Polyline(
        points: entry.value,
        strokeWidth: 6,
        color: routeColor.withValues(alpha: 0.7),
      );
    }).toList();
    
    // Create bus markers
    _createBusMarkers();
    
    // Set up location and bus update timers
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _updateCurrentLocation();
    });
    
    _busUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _updateBusLocations();
    });
  }

  Widget _buildStopMarker(String name) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  void _createBusMarkers() {
    setState(() {
      _busMarkers = _mockBuses.map((bus) {
        return Marker(
          point: bus['location'],
          child: GestureDetector(
            onTap: () => _onBusTap(bus),
            child: Container(
              width: 45,
              height: 45,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing background
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 45 + (_pulseController.value * 10),
                        height: 45 + (_pulseController.value * 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  // Animated bus icon
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    });
  }

  void _updateCurrentLocation() {
    // In a real app, this would get the actual GPS location
    // For demo, we'll just simulate movement if location permission wasn't granted
    if (!_locationPermissionGranted) {
      setState(() {
        _currentLocation = LatLng(
          _currentLocation.latitude + 0.0001,
          _currentLocation.longitude + 0.0001,
        );
      });
    }
  }

  void _updateBusLocations() {
    // Update mock bus locations
    setState(() {
      _mockBuses = _mockBuses.map((bus) {
        return {
          ...bus,
          'location': LatLng(
            bus['location'].latitude + 0.00005,
            bus['location'].longitude + 0.00005,
          ),
          'eta': (bus['eta'] - 0.1).clamp(0, 60),
        };
      }).toList();
    });
    
    // Recreate bus markers with updated locations
    _createBusMarkers();
  }

  void _onBusTap(Map<String, dynamic> bus) {
    // Show bus info balloon instead of just setting state
    _showBusInfoBalloon(bus);
  }

  void _onStopTap(Map<String, dynamic> stop) {
    // Show stop info balloon instead of just setting state
    _showStopInfoBalloon(stop);
  }

  void _showStopInfoBalloon(Map<String, dynamic> stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Stop header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stop['name'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          // Properly close the modal sheet
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Routes served
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Routes Served:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (stop['routes'] as List<String>).map((route) {
                            Color routeColor;
                            switch(route) {
                              case 'Route 101':
                                routeColor = Colors.blue;
                                break;
                              case 'Route 202':
                                routeColor = Colors.green;
                                break;
                              case 'Route 303':
                                routeColor = Colors.purple;
                                break;
                              case 'Route 404':
                                routeColor = Colors.orange;
                                break;
                              case 'Route 505':
                                routeColor = Colors.red;
                                break;
                              default:
                                routeColor = Colors.grey;
                            }
                            
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: routeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: routeColor),
                              ),
                              child: Text(
                                route,
                                style: TextStyle(
                                  color: routeColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Center map on this stop and close modal
                            _mapController.move(stop['location'], 16.0);
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.center_focus_strong),
                          label: Text('Center on Map'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrbitLiveColors.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBusInfoBalloon(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            // Clear selection when popping
            if (didPop) {
              setState(() {
                _selectedBus = null;
              });
            }
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Bus header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bus ${bus['number']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            // Properly close the modal sheet and clear selection
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedBus = null;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    
                    // Route info
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.route, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${bus['from']} → ${bus['to']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Bus details grid
                    Row(
                      children: [
                        _buildBusDetailItem('Speed', '${bus['speed']} km/h', Icons.speed),
                        _buildBusDetailItem('Occupancy', _getOccupancyText(bus['occupancy']), _getOccupancyIcon(bus['occupancy'])),
                        _buildBusDetailItem('Delay', _getDelayText(bus['delay']), _getDelayIcon(bus['delay'])),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Close modal and start navigation
                              Navigator.of(context).pop();
                              _startNavigation(bus);
                            },
                            icon: Icon(Icons.navigation),
                            label: Text('Navigate Here'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OrbitLiveColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Close current modal and show bus details
                              Navigator.of(context).pop();
                              _showBusDetails(bus);
                            },
                            icon: Icon(Icons.info),
                            label: Text('Bus Info'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: OrbitLiveColors.primaryTeal),
                              foregroundColor: OrbitLiveColors.primaryTeal,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Close modal and share location
                              Navigator.of(context).pop();
                              _shareBusLocation(bus);
                            },
                            icon: Icon(Icons.share),
                            label: Text('Share Location'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green),
                              foregroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Close modal and report issue
                              Navigator.of(context).pop();
                              _reportIssue(bus);
                            },
                            icon: Icon(Icons.report_problem),
                            label: Text('Report Issue'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Add Travel Buddy button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Close modal and find travel buddy
                              Navigator.of(context).pop();
                              _findTravelBuddyForBus(bus);
                            },
                            icon: Icon(Icons.people),
                            label: Text('Find Travel Buddy'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.purple),
                              foregroundColor: Colors.purple,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBusDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getOccupancyText(double occupancy) {
    if (occupancy < 0.4) return 'Low';
    if (occupancy < 0.7) return 'Medium';
    return 'High';
  }

  IconData _getOccupancyIcon(double occupancy) {
    if (occupancy < 0.4) return Icons.person;
    if (occupancy < 0.7) return Icons.people;
    return Icons.group;
  }

  String _getDelayText(int delay) {
    if (delay == 0) return 'On Time';
    if (delay > 0) return '$delay min late';
    return '${delay.abs()} min early';
  }

  IconData _getDelayIcon(int delay) {
    if (delay == 0) return Icons.check_circle;
    if (delay > 0) return Icons.warning;
    return Icons.access_time;
  }

  void _startNavigation(Map<String, dynamic> bus) {
    setState(() {
      _isNavigationMode = true;
      _selectedBus = bus;
    });
    
    // Center map on the selected bus
    _mapController.move(bus['location'], 16.0);
    
    // Show a snackbar to indicate navigation started
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation started for bus ${bus['number']}'),
        backgroundColor: OrbitLiveColors.primaryTeal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showBusDetails(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            // Clear selection when popping
            if (didPop) {
              setState(() {
                _selectedBus = null;
              });
            }
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bus ${bus['number']} Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            // Properly close the modal sheet and clear selection
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedBus = null;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // Bus info
                    _buildDetailRow('Route', bus['route']),
                    _buildDetailRow('Type', bus['type']),
                    _buildDetailRow('Driver Contact', bus['driverContact']),
                    _buildDetailRow('From', bus['from']),
                    _buildDetailRow('To', bus['to']),
                    SizedBox(height: 20),
                    
                    // Stops list
                    Text(
                      'Stops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: bus['stops'].length,
                        itemBuilder: (context, index) {
                          final stop = bus['stops'][index];
                          return ListTile(
                            leading: Icon(
                              stop['passed'] ? Icons.check_circle : Icons.access_time,
                              color: stop['passed'] ? Colors.green : Colors.orange,
                            ),
                            title: Text(stop['name']),
                            trailing: Text(stop['time']),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareBusLocation(Map<String, dynamic> bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing live location of bus ${bus['number']}'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportIssue(Map<String, dynamic> bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reporting issue for bus ${bus['number']}'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _findTravelBuddyForBus(Map<String, dynamic> bus) {
    Navigator.pop(context); // Close the bottom sheet
    
    // Navigate to TravelBuddy screen with route information
    Navigator.pushNamed(
      context, 
      '/travel-buddy',
      arguments: {
        'source': bus['from'] as String? ?? 'Guntur Central',
        'destination': bus['to'] as String? ?? 'Tenali',
      },
    );
  }

  void _findTravelBuddy() {
    // Navigate to travel buddy screen with default route
    Navigator.pushNamed(
      context, 
      '/travel-buddy',
      arguments: {
        'source': 'Guntur Central',
        'destination': 'Tenali',
      },
    );
  }

  

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _busUpdateTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map as background
          _buildMap(),
          
          // Header with controls
          _buildMapHeader(),
          
          // Location button
          _buildLocationButton(),
          
          // Navigation toggle
          _buildNavigationToggle(),
          
          // Remove the details overlay that was causing issues
          // The modal sheets are now used instead
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: _mapZoom,
      ),
      children: [
        // Tile layer with minimalistic style
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.orbit_live',
        ),
        // Route polylines with glowing effect
        PolylineLayer(
          polylines: _routePolylines,
        ),
        // Stop markers
        MarkerLayer(
          markers: _stopMarkers,
        ),
        // Bus markers
        MarkerLayer(
          markers: _busMarkers,
        ),
        // User location marker with enhanced styling
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              child: Container(
                width: 25,
                height: 25,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing circle
                        Container(
                          width: 25 + (_pulseController.value * 15),
                          height: 25 + (_pulseController.value * 15),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Main location marker
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        // Selected route highlight (if any bus is selected)
        if (_selectedBus != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePaths[_selectedBus!['route']]!,
                strokeWidth: 8,
                color: Colors.purple.withValues(alpha: 0.8),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMapHeader() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Tracking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _showRouteSearch,
                    ),
                    IconButton(
                      icon: Icon(Icons.group),
                      onPressed: () {
                        _findTravelBuddy();
                      }, // Add find buddy button
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Track buses in real-time',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteSearch() {
    // Implement route search functionality
  }

  Widget _buildLocationButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'locate',
        onPressed: () {
          _mapController.move(_currentLocation, 15.0);
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildNavigationToggle() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'navigate',
        onPressed: () {
          setState(() {
            _isNavigationMode = !_isNavigationMode;
          });
        },
        child: Icon(
          _isNavigationMode ? Icons.close : Icons.navigation,
        ),
      ),
    );
  }

  
}
