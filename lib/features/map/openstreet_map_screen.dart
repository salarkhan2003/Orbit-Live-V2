import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/connectivity_service.dart';
import '../../core/data_cache_service.dart';

class OpenStreetMapScreen extends StatefulWidget {
  final String userRole;

  const OpenStreetMapScreen({super.key, required this.userRole});

  @override
  _OpenStreetMapScreenState createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  late MapController _mapController;
  late Timer _locationUpdateTimer;
  late Timer _busUpdateTimer;
  StreamSubscription? _connectivitySubscription;
  
  bool _isLoading = true;
  bool _isLowBandwidth = false;
  List<Marker> _busMarkers = [];
  List<Polyline> _routePolylines = [];
  List<Marker> _stopMarkers = [];
  LatLng _currentLocation = LatLng(12.9716, 77.5946); // Default to Bangalore
  double _mapZoom = 13.0;
  
  // Mock data for buses
  List<Map<String, dynamic>> _mockBuses = [
    {
      'id': 'bus_1',
      'number': 'KA-01-A-1234',
      'location': LatLng(12.9716, 77.5946),
      'route': 'Route 101',
      'occupancy': 0.6,
      'nextStop': 'Mall Road',
      'eta': 5,
      'from': 'Central Station',
    },
    {
      'id': 'bus_2',
      'number': 'KA-01-B-5678',
      'location': LatLng(12.9616, 77.5846),
      'route': 'Route 202',
      'occupancy': 0.3,
      'nextStop': 'University',
      'eta': 12,
      'from': 'Airport',
    },
    {
      'id': 'bus_3',
      'number': 'KA-01-C-9012',
      'location': LatLng(12.9816, 77.6046),
      'route': 'Route 303',
      'occupancy': 0.8,
      'nextStop': 'Hospital',
      'eta': 8,
      'from': 'Railway Station',
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    _isLowBandwidth = connectivityService.shouldUseLowBandwidthMode();
    
    // Fix the connectivity subscription
    connectivityService.addListener(() {
      setState(() {
        _isLowBandwidth = connectivityService.shouldUseLowBandwidthMode();
      });
      
      // Adjust update frequency based on connectivity
      _restartTimers();
    });
  }

  void _restartTimers() {
    _locationUpdateTimer.cancel();
    _busUpdateTimer.cancel();
    
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    final updateInterval = connectivityService.getRefreshInterval();
    
    _locationUpdateTimer = Timer.periodic(updateInterval, (timer) {
      _updateCurrentLocation();
    });
    
    _busUpdateTimer = Timer.periodic(updateInterval, (timer) {
      _updateBusLocations();
    });
  }

  Future<void> _initializeMap() async {
    // Check for cached data first
    final cachedStops = await DataCacheService.getCachedBusStops();
    final cachedRoutes = await DataCacheService.getCachedBusRoutes();
    
    if (cachedStops != null && cachedRoutes != null) {
      // Use cached data
      _createMarkersFromCachedData(cachedStops, cachedRoutes);
    } else {
      // Load fresh data
      await _loadMapData();
    }
    
    // Set up location and bus update timers
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    final updateInterval = connectivityService.getRefreshInterval();
    
    _locationUpdateTimer = Timer.periodic(updateInterval, (timer) {
      _updateCurrentLocation();
    });
    
    _busUpdateTimer = Timer.periodic(updateInterval, (timer) {
      _updateBusLocations();
    });
    
    setState(() {
      _isLoading = false;
    });
  }

  void _createMarkersFromCachedData(List<dynamic> stops, List<dynamic> routes) {
    // Create stop markers from cached data
    _stopMarkers = stops.map((stop) {
      return Marker(
        point: LatLng(stop['lat'], stop['lng']),
        child: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: _isLowBandwidth ? 20 : 30,
        ),
      );
    }).toList();
    
    // Create route polylines from cached data
    _routePolylines = routes.map((route) {
      final points = (route['points'] as List).map((point) {
        return LatLng(point['lat'], point['lng']);
      }).toList();
      
      return Polyline(
        points: points,
        strokeWidth: _isLowBandwidth ? 2 : 4,
        color: Colors.blue.withValues(alpha: 0.7),
      );
    }).toList();
    
    // Create bus markers
    _createBusMarkers();
  }

  Future<void> _loadMapData() async {
    // Simulate API call with delay
    await Future.delayed(Duration(seconds: 1));
    
    // Create mock stop markers
    _stopMarkers = [
      Marker(
        point: LatLng(12.9716, 77.5946),
        child: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: _isLowBandwidth ? 20 : 30,
        ),
      ),
      Marker(
        point: LatLng(12.9616, 77.5846),
        child: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: _isLowBandwidth ? 20 : 30,
        ),
      ),
      Marker(
        point: LatLng(12.9816, 77.6046),
        child: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: _isLowBandwidth ? 20 : 30,
        ),
      ),
    ];
    
    // Create mock route polylines
    _routePolylines = [
      Polyline(
        points: [
          LatLng(12.9716, 77.5946),
          LatLng(12.9616, 77.5846),
          LatLng(12.9516, 77.5746),
        ],
        strokeWidth: _isLowBandwidth ? 2 : 4,
        color: Colors.blue.withValues(alpha: 0.7),
      ),
      Polyline(
        points: [
          LatLng(12.9816, 77.6046),
          LatLng(12.9716, 77.5946),
          LatLng(12.9616, 77.5846),
        ],
        strokeWidth: _isLowBandwidth ? 2 : 4,
        color: Colors.green.withValues(alpha: 0.7),
      ),
    ];
    
    // Create bus markers
    _createBusMarkers();
    
    // Cache the data for offline use
    try {
      final stopsData = [
        {'lat': 12.9716, 'lng': 77.5946},
        {'lat': 12.9616, 'lng': 77.5846},
        {'lat': 12.9816, 'lng': 77.6046},
      ];
      
      final routesData = [
        {
          'points': [
            {'lat': 12.9716, 'lng': 77.5946},
            {'lat': 12.9616, 'lng': 77.5846},
            {'lat': 12.9516, 'lng': 77.5746},
          ]
        },
        {
          'points': [
            {'lat': 12.9816, 'lng': 77.6046},
            {'lat': 12.9716, 'lng': 77.5946},
            {'lat': 12.9616, 'lng': 77.5846},
          ]
        },
      ];
      
      await DataCacheService.cacheBusStops(stopsData);
      await DataCacheService.cacheBusRoutes(routesData);
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  void _createBusMarkers() {
    setState(() {
      _busMarkers = _mockBuses.map((bus) {
        return Marker(
          point: bus['location'],
          child: GestureDetector(
            onTap: () => _showBusDetails(bus),
            child: Container(
              width: _isLowBandwidth ? 30 : 40,
              height: _isLowBandwidth ? 30 : 40,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: _isLowBandwidth ? 1 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: _isLowBandwidth ? 2 : 4,
                    offset: Offset(0, _isLowBandwidth ? 1 : 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  bus['number'].toString().substring(9), // Last 4 digits
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isLowBandwidth ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList();
    });
  }

  void _updateCurrentLocation() {
    // In a real app, this would get the actual GPS location
    // For demo, we'll just simulate movement
    setState(() {
      _currentLocation = LatLng(
        _currentLocation.latitude + 0.0001,
        _currentLocation.longitude + 0.0001,
      );
    });
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
          'eta': (bus['eta'] - 1).clamp(0, 60),
        };
      }).toList();
    });
    
    // Recreate bus markers with updated locations
    _createBusMarkers();
  }

  void _showBusDetails(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bus Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Bus Number: ${bus['number']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Route: ${bus['route']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'From: ${bus['from']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Next Stop: ${bus['nextStop']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'ETA: ${bus['eta']} minutes',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Occupancy: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: bus['occupancy'],
                      child: Container(
                        decoration: BoxDecoration(
                          color: bus['occupancy'] > 0.8 
                            ? Colors.red 
                            : bus['occupancy'] > 0.5 
                              ? Colors.orange 
                              : Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${(bus['occupancy'] * 100).round()}%',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToBus(bus);
                  },
                  child: Text('Navigate to Bus'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToBus(Map<String, dynamic> bus) {
    // Center map on the selected bus
    _mapController.move(bus['location'], 16.0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to bus ${bus['number']}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _busUpdateTimer.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking'),
        actions: [
          if (_isLowBandwidth)
            IconButton(
              icon: Icon(Icons.network_check, color: Colors.orange),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Low bandwidth mode active. Using cached data.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // Fix the MapOptions parameters
                    initialCenter: _currentLocation,
                    initialZoom: _mapZoom,
                    maxZoom: _isLowBandwidth ? 15 : 18,
                    minZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isLowBandwidth
                          ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.orbit_live',
                      // Reduce tile loading for low bandwidth
                      keepBuffer: _isLowBandwidth ? 2 : 4,
                    ),
                    MarkerLayer(
                      markers: _stopMarkers,
                    ),
                    MarkerLayer(
                      markers: _busMarkers,
                    ),
                    PolylineLayer(
                      polylines: _routePolylines,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          child: Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: _isLowBandwidth ? 20 : 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isLowBandwidth ? Icons.network_cell : Icons.network_wifi,
                          color: _isLowBandwidth ? Colors.orange : Colors.green,
                        ),
                        SizedBox(width: 5),
                        Text(
                          _isLowBandwidth ? 'Low Bandwidth' : 'Good Connection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isLowBandwidth ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'locate',
            onPressed: () {
              _mapController.move(_currentLocation, 15.0);
            },
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              // Fix the map controller access
              _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              // Fix the map controller access
              _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
            },
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}