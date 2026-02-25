import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/vehicle_telemetry.dart';
import '../../../services/passenger_telemetry_service.dart';
import '../../../shared/orbit_live_colors.dart';

class LiveTrackBusPage extends StatefulWidget {
  const LiveTrackBusPage({super.key});

  @override
  State<LiveTrackBusPage> createState() => _LiveTrackBusPageState();
}

class _LiveTrackBusPageState extends State<LiveTrackBusPage> with TickerProviderStateMixin {
  final PassengerTelemetryService _telemetryService = PassengerTelemetryService();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  late MapController _mapController;
  late AnimationController _pulseController;
  bool _isMapReady = false;
  double? _userLat;
  double? _userLon;
  StreamSubscription<Position>? _locationSubscription;
  String? _selectedBusType;
  bool _accessibilityFilter = false;
  bool _lowCrowdFilter = false;

  final List<Map<String, dynamic>> _busStops = [
    {'name': 'Guntur Central', 'lat': 16.3067, 'lon': 80.4365},
    {'name': 'RTC Bus Stand', 'lat': 16.2987, 'lon': 80.4425},
    {'name': 'Lakshmipuram', 'lat': 16.3127, 'lon': 80.4285},
    {'name': 'Namburu', 'lat': 16.2927, 'lon': 80.4505},
    {'name': 'Amaravati Road', 'lat': 16.3207, 'lon': 80.4205},
    {'name': 'Gurazala', 'lat': 16.2857, 'lon': 80.4585},
    {'name': 'Pedakakani', 'lat': 16.3287, 'lon': 80.4125},
    {'name': 'Kollipara', 'lat': 16.2787, 'lon': 80.4665},
    {'name': 'Mangalagiri', 'lat': 16.3367, 'lon': 80.4045},
    {'name': 'Tenali', 'lat': 16.2717, 'lon': 80.4745},
    {'name': 'Vijayawada', 'lat': 16.5062, 'lon': 80.6480},
    {'name': 'Narasaraopet', 'lat': 16.2346, 'lon': 80.0478},
  ];

  List<String> _sourceSuggestions = [];
  List<String> _destinationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _telemetryService.addListener(_onTelemetryUpdate);
    _telemetryService.startListening();
    await _getUserLocation();
    setState(() => _isMapReady = true);
  }

  void _onTelemetryUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      setState(() {
        _userLat = position.latitude;
        _userLon = position.longitude;
      });

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position position) {
        setState(() {
          _userLat = position.latitude;
          _userLon = position.longitude;
        });
      });
    } catch (e) {
      debugPrint('[LIVE_TRACK] Error getting location: $e');
    }
  }

  void _onBusTap(VehicleTelemetry vehicle) => _showBusDetailsSheet(vehicle);

  void _showBusDetailsSheet(VehicleTelemetry vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BusDetailsSheet(
        vehicle: vehicle,
        userLat: _userLat,
        userLon: _userLon,
        onNavigate: () => _navigateToBus(vehicle),
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _navigateToBus(VehicleTelemetry vehicle) async {
    if (_userLat == null || _userLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get your location. Please enable GPS.'), backgroundColor: Colors.orange),
      );
      return;
    }
    final url = 'https://www.google.com/maps/dir/?api=1&origin=$_userLat,$_userLon&destination=${vehicle.lat},${vehicle.lon}&travelmode=walking';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _centerOnUser() {
    if (_userLat != null && _userLon != null) _mapController.move(LatLng(_userLat!, _userLon!), 15);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Buses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Bus Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                FilterChip(label: const Text('All'), selected: _selectedBusType == null, onSelected: (s) { setModalState(() => _selectedBusType = null); setState(() {}); _telemetryService.setBusTypeFilter(null); }),
                FilterChip(label: const Text('AC'), selected: _selectedBusType == 'AC', onSelected: (s) { setModalState(() => _selectedBusType = s ? 'AC' : null); setState(() {}); _telemetryService.setBusTypeFilter(s ? 'AC' : null); }),
                FilterChip(label: const Text('Non-AC'), selected: _selectedBusType == 'Non-AC', onSelected: (s) { setModalState(() => _selectedBusType = s ? 'Non-AC' : null); setState(() {}); _telemetryService.setBusTypeFilter(s ? 'Non-AC' : null); }),
              ]),
              const SizedBox(height: 16),
              SwitchListTile(title: const Text('Wheelchair Accessible'), value: _accessibilityFilter, onChanged: (v) { setModalState(() => _accessibilityFilter = v); setState(() {}); _telemetryService.setAccessibilityFilter(v); }),
              SwitchListTile(title: const Text('Low Crowd'), value: _lowCrowdFilter, onChanged: (v) { setModalState(() => _lowCrowdFilter = v); setState(() {}); _telemetryService.setLowCrowdFilter(v); }),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: OrbitLiveColors.primaryTeal, foregroundColor: Colors.white), child: const Text('Apply Filters'))),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSourceSuggestions(String query) {
    if (query.isEmpty) { setState(() => _sourceSuggestions = []); return; }
    setState(() => _sourceSuggestions = _busStops.where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase())).map((s) => s['name'] as String).toList());
  }

  void _updateDestinationSuggestions(String query) {
    if (query.isEmpty) { setState(() => _destinationSuggestions = []); return; }
    setState(() => _destinationSuggestions = _busStops.where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase())).map((s) => s['name'] as String).toList());
  }

  @override
  void dispose() {
    _telemetryService.removeListener(_onTelemetryUpdate);
    _telemetryService.stopListening();
    _locationSubscription?.cancel();
    _sourceController.dispose();
    _destinationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          if (!_isMapReady) Container(color: Colors.white, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading Map...')]))),
          SafeArea(child: Column(children: [_buildSearchBar(), if (_telemetryService.availableRoutes.isNotEmpty) _buildRoutesChips()])),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
          Positioned(right: 16, bottom: 200, child: Column(children: [
            _buildMapButton(Icons.my_location, _centerOnUser),
            const SizedBox(height: 8),
            _buildMapButton(Icons.filter_list, _showFilters),
            const SizedBox(height: 8),
            _buildMapButton(Icons.refresh, () => _telemetryService.refresh()),
          ])),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final centerLat = _userLat ?? 16.3067;
    final centerLon = _userLon ?? 80.4365;
    final buses = _telemetryService.filteredVehicles;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: LatLng(centerLat, centerLon), initialZoom: 13.0),
      children: [
        TileLayer(urlTemplate: 'https://api.olamaps.io/tiles/v1/styles/default-light-standard/{z}/{x}/{y}.png?api_key=aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK', userAgentPackageName: 'com.orbit.live', fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(markers: _busStops.map((stop) => Marker(point: LatLng(stop['lat'], stop['lon']), child: GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stop: ${stop['name']}'))), child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.location_on, color: Colors.white, size: 14))))).toList()),
        MarkerLayer(markers: buses.map((bus) {
          final isAC = bus.busType == 'AC';
          return Marker(
            point: LatLng(bus.lat, bus.lon),
            child: GestureDetector(
              onTap: () => _onBusTap(bus),
              child: AnimatedBuilder(animation: _pulseController, builder: (context, child) => Stack(alignment: Alignment.center, children: [
                Container(width: 40 + (_pulseController.value * 10), height: 40 + (_pulseController.value * 10), decoration: BoxDecoration(color: (isAC ? Colors.green : Colors.orange).withValues(alpha: 0.3 * (1 - _pulseController.value)), shape: BoxShape.circle)),
                Container(width: 36, height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: isAC ? [Colors.green, Colors.green.shade700] : [Colors.orange, Colors.orange.shade700]), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.directions_bus, color: Colors.white, size: 20)),
                Positioned(top: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)), child: Text(bus.routeId.length > 6 ? bus.routeId.substring(0, 6) : bus.routeId, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
              ])),
            ),
          );
        }).toList()),
        if (_userLat != null && _userLon != null) MarkerLayer(markers: [Marker(point: LatLng(_userLat!, _userLon!), child: AnimatedBuilder(animation: _pulseController, builder: (context, child) => Stack(alignment: Alignment.center, children: [Container(width: 30 + (_pulseController.value * 20), height: 30 + (_pulseController.value * 20), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.3 * (1 - _pulseController.value)), shape: BoxShape.circle)), Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)))])))]),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 8, 16, 0), child: Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          const Expanded(child: Text('Live Track Bus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 4), Text('${_telemetryService.activeVehicles.length} Live', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12))])),
        ])),
        const Divider(height: 1),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 12), Expanded(child: TextField(controller: _sourceController, decoration: const InputDecoration(hintText: 'From', border: InputBorder.none, isDense: true), onChanged: _updateSourceSuggestions))])),
        if (_sourceSuggestions.isNotEmpty) _buildSuggestionsList(_sourceSuggestions, (s) { _sourceController.text = s; setState(() => _sourceSuggestions = []); }),
        Padding(padding: const EdgeInsets.only(left: 20), child: Row(children: [Container(width: 1, height: 20, color: Colors.grey[300])])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 12), Expanded(child: TextField(controller: _destinationController, decoration: const InputDecoration(hintText: 'To', border: InputBorder.none, isDense: true), onChanged: _updateDestinationSuggestions))])),
        if (_destinationSuggestions.isNotEmpty) _buildSuggestionsList(_destinationSuggestions, (s) { _destinationController.text = s; setState(() => _destinationSuggestions = []); }),
      ]),
    );
  }

  Widget _buildSuggestionsList(List<String> suggestions, Function(String) onSelect) {
    return Container(constraints: const BoxConstraints(maxHeight: 150), child: ListView.builder(shrinkWrap: true, itemCount: suggestions.length, itemBuilder: (context, index) => ListTile(dense: true, leading: const Icon(Icons.location_on, size: 20), title: Text(suggestions[index]), onTap: () => onSelect(suggestions[index]))));
  }

  Widget _buildRoutesChips() {
    final routes = _telemetryService.availableRoutes;
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 40, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: routes.length, itemBuilder: (context, index) => Container(margin: const EdgeInsets.only(right: 8), child: Chip(label: Text('${routes[index]} (${_telemetryService.getBusCountForRoute(routes[index])})'), backgroundColor: Colors.white, side: const BorderSide(color: Colors.blue)))));
  }

  Widget _buildBottomBar() {
    final vehicles = _telemetryService.filteredVehicles;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Nearby Buses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), if (_telemetryService.isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))]),
        const SizedBox(height: 12),
        if (vehicles.isEmpty) _buildEmptyState() else SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: vehicles.length, itemBuilder: (context, index) => _buildBusCard(vehicles[index]))),
      ])),
    );
  }

  Widget _buildEmptyState() {
    return Container(padding: const EdgeInsets.all(20), child: Column(children: [Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey[400]), const SizedBox(height: 8), Text(_telemetryService.error != null ? 'Error loading buses' : 'No active buses', style: TextStyle(color: Colors.grey[600])), if (_telemetryService.error != null) TextButton(onPressed: () => _telemetryService.refresh(), child: const Text('Retry'))]));
  }

  Widget _buildBusCard(VehicleTelemetry vehicle) {
    final isAC = vehicle.busType == 'AC';
    return GestureDetector(
      onTap: () => _onBusTap(vehicle),
      child: Container(
        width: 160, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isAC ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: isAC ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.directions_bus, color: isAC ? Colors.green : Colors.orange, size: 20), const SizedBox(width: 6), Expanded(child: Text(vehicle.routeId, style: TextStyle(fontWeight: FontWeight.bold, color: isAC ? Colors.green[700] : Colors.orange[700]), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 4),
          Text(vehicle.vehicleId, style: TextStyle(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isAC ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(4)), child: Text(isAC ? 'AC' : 'Non-AC', style: const TextStyle(color: Colors.white, fontSize: 10))), const Spacer(), Text('Live', style: TextStyle(color: Colors.green[600], fontSize: 11, fontWeight: FontWeight.w600))]),
        ]),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return Material(elevation: 4, borderRadius: BorderRadius.circular(12), color: Colors.white, child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(12), child: Container(width: 48, height: 48, alignment: Alignment.center, child: Icon(icon, color: OrbitLiveColors.primaryTeal))));
  }
}

class _BusDetailsSheet extends StatelessWidget {
  final VehicleTelemetry vehicle;
  final double? userLat;
  final double? userLon;
  final VoidCallback onNavigate;
  final VoidCallback onClose;

  const _BusDetailsSheet({required this.vehicle, this.userLat, this.userLon, required this.onNavigate, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isAC = vehicle.busType == 'AC';
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isAC ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.directions_bus, color: isAC ? Colors.green : Colors.orange, size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(vehicle.vehicleId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('Route: ${vehicle.routeId}', style: TextStyle(color: Colors.grey[600]))])),
            IconButton(icon: const Icon(Icons.close), onPressed: onClose),
          ]),
          const SizedBox(height: 20),
          Row(children: [_buildInfoItem(Icons.access_time, 'Last Update', vehicle.formattedTime), _buildInfoItem(Icons.speed, 'Speed', '${vehicle.speed?.toStringAsFixed(0) ?? '--'} km/h'), _buildInfoItem(Icons.event_seat, 'Seats', '${vehicle.seatsAvailable ?? '--'}')]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: vehicle.status == 'in_transit' ? Colors.green : Colors.orange, shape: BoxShape.circle)), const SizedBox(width: 8), Text('Status: ${vehicle.status}', style: const TextStyle(fontWeight: FontWeight.w500)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isAC ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(8)), child: Text(isAC ? 'AC' : 'Non-AC', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)))])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: onNavigate, icon: const Icon(Icons.navigation), label: const Text('Navigate to this Bus'), style: ElevatedButton.styleFrom(backgroundColor: OrbitLiveColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share coming soon'))), icon: const Icon(Icons.share), label: const Text('Share'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/travel-buddy', arguments: {'route': vehicle.routeId}); }, icon: const Icon(Icons.people), label: const Text('Find Buddy'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
          ]),
        ])),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ]),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(child: Column(children: [Icon(icon, color: Colors.grey[600], size: 20), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]));
  }
}

