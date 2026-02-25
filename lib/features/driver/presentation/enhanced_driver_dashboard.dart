import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../services/driver_service.dart';
import '../../../services/live_telemetry_service.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../core/connectivity_service.dart';
import 'driver_login_page.dart';

class EnhancedDriverDashboard extends StatefulWidget {
  const EnhancedDriverDashboard({super.key});

  @override
  State<EnhancedDriverDashboard> createState() => _EnhancedDriverDashboardState();
}

class _EnhancedDriverDashboardState extends State<EnhancedDriverDashboard> with TickerProviderStateMixin {
  final _vehicleIdController = TextEditingController(text: 'APSRTC-VEH-');
  final _capacityController = TextEditingController(text: '40');
  late MapController _mapController;
  late AnimationController _pulseController;

  String _selectedRoute = 'RJ-12';
  String _source = 'Guntur Central';
  String _destination = 'Vijayawada';

  double? _currentLat;
  double? _currentLon;
  StreamSubscription<Position>? _positionSubscription;
  bool _gpsEnabled = false;

  int _currentTabIndex = 0;
  bool _isStartingTrip = false;
  bool _isEndingTrip = false;

  final List<String> _routes = ['RJ-12', 'RJ-15', 'RJ-20', 'AC-EXPRESS-1', 'AC-EXPRESS-2'];
  final List<String> _depots = ['Guntur Central', 'Vijayawada', 'Tenali', 'Mangalagiri', 'Amaravati'];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _initializeGPS();
  }

  Future<void> _initializeGPS() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) await Geolocator.requestPermission();
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() => _gpsEnabled = serviceEnabled);
      if (serviceEnabled) {
        final position = await Geolocator.getCurrentPosition();
        setState(() { _currentLat = position.latitude; _currentLon = position.longitude; });
        _positionSubscription = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5)).listen((p) => setState(() { _currentLat = p.latitude; _currentLon = p.longitude; }));
      }
    } catch (e) { debugPrint('[DRIVER_DASH] GPS init error: $e'); }
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _capacityController.dispose();
    _positionSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverService>(builder: (context, driverService, _) {
      return Scaffold(
        appBar: _buildAppBar(context, driverService),
        body: IndexedStack(index: _currentTabIndex, children: [
          _buildDashboardTab(context, driverService),
          _buildMapTab(context, driverService),
          _buildPaymentsTab(context, driverService),
          _buildProfileTab(context, driverService),
        ]),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: driverService.isOnTrip ? _buildEmergencyFab(context) : null,
      );
    });
  }

  AppBar _buildAppBar(BuildContext context, DriverService driverService) {
    return AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Driver Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(driverService.currentEmployee?.name ?? 'Guest Driver', style: const TextStyle(fontSize: 12)),
      ]),
      backgroundColor: OrbitLiveColors.primaryTeal,
      foregroundColor: Colors.white,
      actions: [
        _buildStatusChip(_gpsEnabled ? 'GPS' : 'OFF', _gpsEnabled ? Icons.gps_fixed : Icons.gps_off, _gpsEnabled ? Colors.green : Colors.red),
        Consumer<ConnectivityService>(builder: (ctx, c, _) => _buildStatusChip('', c.isLowBandwidth ? Icons.wifi_off : Icons.wifi, c.isLowBandwidth ? Colors.orange : Colors.green)),
        IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
      ],
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color == Colors.green ? Colors.greenAccent : (color == Colors.red ? Colors.redAccent : Colors.orangeAccent)),
        if (label.isNotEmpty) ...[const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: Colors.white))],
      ]),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (i) => setState(() => _currentTabIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: OrbitLiveColors.primaryTeal,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildEmergencyFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(context),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.emergency),
      label: const Text('EMERGENCY'),
    );
  }

  Widget _buildDashboardTab(BuildContext context, DriverService driverService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildTripStatusCard(driverService),
        const SizedBox(height: 16),
        if (!driverService.isOnTrip) _buildStartTripCard(context, driverService) else _buildActiveTripCard(context, driverService),
        const SizedBox(height: 16),
        if (driverService.isOnTrip) ...[_buildSeatManagementCard(context, driverService), const SizedBox(height: 16)],
        _buildQuickActionsCard(context, driverService),
      ]),
    );
  }

  Widget _buildTripStatusCard(DriverService driverService) {
    final status = driverService.tripStatus;
    Color statusColor; String statusText; IconData statusIcon;
    switch (status) {
      case 'on_trip': statusColor = Colors.green; statusText = 'On Trip'; statusIcon = Icons.play_circle_fill; break;
      case 'paused': statusColor = Colors.orange; statusText = 'Paused'; statusIcon = Icons.pause_circle; break;
      case 'completed': statusColor = Colors.blue; statusText = 'Completed'; statusIcon = Icons.check_circle; break;
      default: statusColor = Colors.grey; statusText = 'Not Started'; statusIcon = Icons.stop_circle;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(statusIcon, color: Colors.white, size: 32)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Trip Status', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (driverService.isOnTrip && driverService.currentTrip != null) Text('Vehicle: ${driverService.currentTrip!.vehicleId}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
        if (driverService.isOnTrip) _buildLiveIndicator(),
      ]),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(animation: _pulseController, builder: (ctx, _) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2 + (_pulseController.value * 0.1)), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    ));
  }

  Widget _buildStartTripCard(BuildContext context, DriverService driverService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.play_circle_outline, color: OrbitLiveColors.primaryTeal), const SizedBox(width: 8), const Text('Start New Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        TextField(controller: _vehicleIdController, decoration: InputDecoration(labelText: 'Vehicle ID', hintText: 'APSRTC-VEH-XXX', prefixIcon: const Icon(Icons.directions_bus), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _selectedRoute, decoration: InputDecoration(labelText: 'Route', prefixIcon: const Icon(Icons.route), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: _routes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _selectedRoute = v!)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(value: _source, decoration: InputDecoration(labelText: 'From', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true), items: _depots.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(), onChanged: (v) => setState(() => _source = v!))),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: DropdownButtonFormField<String>(value: _destination, decoration: InputDecoration(labelText: 'To', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true), items: _depots.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(), onChanged: (v) => setState(() => _destination = v!))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _capacityController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Bus Capacity', prefixIcon: const Icon(Icons.event_seat), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(onPressed: _isStartingTrip ? null : () => _startTrip(context, driverService), icon: _isStartingTrip ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow), label: Text(_isStartingTrip ? 'Starting...' : 'Start Trip', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, DriverService driverService) {
    final trip = driverService.currentTrip;
    if (trip == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.info_outline, color: OrbitLiveColors.primaryTeal), const SizedBox(width: 8), const Text('Active Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        _infoRow('Vehicle', trip.vehicleId, Icons.directions_bus),
        _infoRow('Route', trip.routeId, Icons.route),
        _infoRow('From', trip.source, Icons.location_on),
        _infoRow('To', trip.destination, Icons.flag),
        _infoRow('Duration', trip.formattedDuration, Icons.timer),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(onPressed: _isEndingTrip ? null : () => _endTrip(context, driverService), icon: _isEndingTrip ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.stop), label: Text(_isEndingTrip ? 'Ending...' : 'End Trip', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 8), Text('$label:', style: TextStyle(color: Colors.grey[600])), const SizedBox(width: 8), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)))]));
  }

  Widget _buildSeatManagementCard(BuildContext context, DriverService driverService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.event_seat, color: OrbitLiveColors.primaryTeal), const SizedBox(width: 8), const Text('Live Seat Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _seatStat('Capacity', driverService.totalCapacity, Colors.blue),
          _seatStat('Boarded', driverService.seatsBoarded, Colors.green),
          _seatStat('Available', driverService.seatsAvailable, driverService.seatsAvailable > 10 ? Colors.green : Colors.orange),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: driverService.totalCapacity > 0 ? driverService.seatsBoarded / driverService.totalCapacity : 0, minHeight: 12, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(driverService.seatsAvailable > 10 ? Colors.green : Colors.orange))),
        const SizedBox(height: 20),
        Row(children: [
          _seatBtn('-1', Colors.red, () => driverService.removePassengers(1)),
          const SizedBox(width: 8),
          _seatBtn('+1', Colors.green, () => driverService.addPassengers(1)),
          const SizedBox(width: 8),
          _seatBtn('+10', Colors.blue, () => driverService.addPassengers(10)),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(onPressed: () => _showSetExactDialog(context, driverService), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Set Exact'))),
        ]),
      ]),
    );
  }

  Widget _seatStat(String label, int value, Color color) => Column(children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), const SizedBox(height: 4), Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color))]);
  Widget _seatBtn(String label, Color color, VoidCallback onPressed) => ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(56, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildQuickActionsCard(BuildContext context, DriverService driverService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _actionChip('Report Delay', Icons.access_time, Colors.orange, () => _showReportDelayDialog(context, driverService)),
          _actionChip('Scan Pass', Icons.qr_code_scanner, Colors.purple, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Scanner coming soon')))),
          _actionChip('Manual Board', Icons.person_add, Colors.blue, () => _showManualBoardingDialog(context, driverService)),
          _actionChip('Reduced Service', Icons.warning, Colors.amber, () => _requestReducedService(context, driverService)),
        ]),
      ]),
    );
  }

  Widget _actionChip(String label, IconData icon, Color color, VoidCallback onPressed) => ActionChip(avatar: Icon(icon, size: 18, color: color), label: Text(label), onPressed: onPressed, backgroundColor: color.withValues(alpha: 0.1), side: BorderSide(color: color.withValues(alpha: 0.3)));

  Widget _buildMapTab(BuildContext context, DriverService driverService) {
    final lat = _currentLat ?? 16.3067;
    final lon = _currentLon ?? 80.4365;
    return Stack(children: [
      FlutterMap(mapController: _mapController, options: MapOptions(initialCenter: LatLng(lat, lon), initialZoom: 15), children: [
        TileLayer(urlTemplate: 'https://api.olamaps.io/tiles/v1/styles/default-light-standard/{z}/{x}/{y}.png?api_key=aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK', userAgentPackageName: 'com.orbit.live', fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        if (_currentLat != null && _currentLon != null) MarkerLayer(markers: [Marker(point: LatLng(_currentLat!, _currentLon!), child: AnimatedBuilder(animation: _pulseController, builder: (ctx, _) => Stack(alignment: Alignment.center, children: [Container(width: 50 + (_pulseController.value * 20), height: 50 + (_pulseController.value * 20), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.3 * (1 - _pulseController.value)), shape: BoxShape.circle)), Container(width: 44, height: 44, decoration: BoxDecoration(color: driverService.isOnTrip ? Colors.green : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.directions_bus, color: Colors.white, size: 24))])))]),
      ]),
      Positioned(right: 16, bottom: 16, child: FloatingActionButton.small(heroTag: 'center', onPressed: () { if (_currentLat != null && _currentLon != null) _mapController.move(LatLng(_currentLat!, _currentLon!), 15); }, child: const Icon(Icons.my_location))),
    ]);
  }

  Widget _buildPaymentsTab(BuildContext context, DriverService driverService) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.qr_code, color: OrbitLiveColors.primaryTeal), const SizedBox(width: 8), const Text('Generate Ticket QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: driverService.isOnTrip ? () => _showGenerateQRDialog(context, driverService) : null, icon: const Icon(Icons.qr_code_2), label: const Text('Generate Payment QR'), style: ElevatedButton.styleFrom(backgroundColor: OrbitLiveColors.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
        if (!driverService.isOnTrip) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Start a trip to generate payment QR', style: TextStyle(color: Colors.grey, fontSize: 12))),
      ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Payments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_payStat('Collected', '₹1,250', Colors.green), _payStat('Pending', '₹350', Colors.orange), _payStat('Settled', '₹900', Colors.blue)]),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('EOD Report export coming soon'))), icon: const Icon(Icons.download), label: const Text('Export EOD Report'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44))),
      ])),
    ]));
  }

  Widget _payStat(String label, String value, Color color) => Column(children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))]);

  Widget _buildProfileTab(BuildContext context, DriverService driverService) {
    final emp = driverService.currentEmployee;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(children: [
        CircleAvatar(radius: 40, backgroundColor: OrbitLiveColors.primaryTeal, child: const Icon(Icons.person, size: 40, color: Colors.white)),
        const SizedBox(height: 12),
        Text(emp?.name ?? 'Guest Driver', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(emp?.employeeId ?? 'GUEST', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Chip(label: Text((emp?.role ?? 'DRIVER').toUpperCase()), backgroundColor: OrbitLiveColors.primaryTeal.withValues(alpha: 0.1)),
        const SizedBox(height: 16),
        if (emp != null) ...[_profileRow('Depot', emp.depot), _profileRow('Routes', emp.assignedRoutes.join(', '))],
      ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Compliance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.timer, color: Colors.blue), title: const Text('Duty Hours Today'), subtitle: const Text('6h 30m'), trailing: Chip(label: const Text('OK', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)),
        ListTile(leading: const Icon(Icons.coffee, color: Colors.orange), title: const Text('Last Break'), subtitle: const Text('2h ago'), trailing: TextButton(onPressed: () {}, child: const Text('Log Break'))),
        ListTile(leading: const Icon(Icons.camera_alt, color: Colors.purple), title: const Text('Log Incident'), subtitle: const Text('Capture photo & report'), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident logging coming soon')))),
      ])),
    ]));
  }

  Widget _profileRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))]));

  Future<void> _startTrip(BuildContext context, DriverService driverService) async {
    final vehicleId = _vehicleIdController.text.trim();
    final capacity = int.tryParse(_capacityController.text) ?? 40;
    if (vehicleId.isEmpty || !vehicleId.startsWith('APSRTC-VEH-')) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid Vehicle ID'), backgroundColor: Colors.red)); return; }
    if (!_gpsEnabled) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable GPS first'), backgroundColor: Colors.orange)); return; }
    setState(() => _isStartingTrip = true);
    final success = await driverService.startTrip(vehicleId: vehicleId, routeId: _selectedRoute, source: _source, destination: _destination, capacity: capacity);
    setState(() => _isStartingTrip = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Trip started!' : 'Failed'), backgroundColor: success ? Colors.green : Colors.red));
  }

  Future<void> _endTrip(BuildContext context, DriverService driverService) async {
    setState(() => _isEndingTrip = true);
    final summary = await driverService.endTrip();
    setState(() => _isEndingTrip = false);
    if (summary != null && mounted) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Trip Completed')]), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Duration: ${summary['total_time_formatted']}'), Text('Passengers: ${summary['seats_sold']}'), Text('Occupancy: ${summary['occupancy_rate']}%')]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
    }
  }

  void _showSetExactDialog(BuildContext context, DriverService driverService) {
    final c = TextEditingController(text: driverService.seatsBoarded.toString());
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Set Exact Passengers'), content: TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () { driverService.setExactPassengers(int.tryParse(c.text) ?? 0); Navigator.pop(ctx); }, child: const Text('Set'))]));
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Row(children: [Icon(Icons.emergency, color: Colors.red), SizedBox(width: 8), Text('Emergency Alert')]), content: const Text('Send emergency alert to control room?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async { Navigator.pop(ctx); final ds = Provider.of<DriverService>(context, listen: false); final s = await ds.sendEmergencyAlert(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s ? 'Alert sent!' : 'Failed'), backgroundColor: s ? Colors.green : Colors.red)); }, child: const Text('Send Alert', style: TextStyle(color: Colors.white)))]));
  }

  void _showReportDelayDialog(BuildContext context, DriverService driverService) {
    final rc = TextEditingController(); final dc = TextEditingController(text: '10');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Report Delay'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: rc, decoration: const InputDecoration(labelText: 'Reason')), const SizedBox(height: 12), TextField(controller: dc, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Delay (minutes)'))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () async { await driverService.reportAlert(reason: rc.text, delayMinutes: int.tryParse(dc.text) ?? 10); Navigator.pop(ctx); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reported'), backgroundColor: Colors.green)); }, child: const Text('Submit'))]));
  }

  void _showManualBoardingDialog(BuildContext context, DriverService driverService) {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Manual Boarding'), content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Passenger Name/ID')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () async { await driverService.recordManualBoarding(c.text); Navigator.pop(ctx); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recorded'), backgroundColor: Colors.green)); }, child: const Text('Record'))]));
  }

  void _requestReducedService(BuildContext context, DriverService driverService) async {
    final s = await driverService.requestReducedService();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s ? 'Reduced service requested' : 'Failed'), backgroundColor: s ? Colors.green : Colors.red));
  }

  void _showGenerateQRDialog(BuildContext context, DriverService driverService) {
    String fromStop = _source; String toStop = _destination; final fc = TextEditingController(text: '50');
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDs) => AlertDialog(title: const Text('Generate Ticket QR'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: fromStop, decoration: const InputDecoration(labelText: 'From'), items: _depots.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (v) => setDs(() => fromStop = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: toStop, decoration: const InputDecoration(labelText: 'To'), items: _depots.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (v) => setDs(() => toStop = v!)),
      const SizedBox(height: 12),
      TextField(controller: fc, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fare (₹)', prefixText: '₹')),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(ctx); _showQRCode(context, driverService, fromStop, toStop, fc.text); }, child: const Text('Generate'))])));
  }

  void _showQRCode(BuildContext context, DriverService driverService, String from, String to, String fare) {
    final t = driverService.currentTrip;
    final qr = '{"trip":"${t?.tripId}","route":"${t?.routeId}","vehicle":"${t?.vehicleId}","conductor":"${driverService.currentEmployee?.employeeId ?? 'GUEST'}","from":"$from","to":"$to","fare":$fare,"ts":${DateTime.now().millisecondsSinceEpoch}}';
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Ticket QR'), content: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: QrImageView(data: qr, size: 200)), const SizedBox(height: 16), Text('$from → $to', style: const TextStyle(fontWeight: FontWeight.bold)), Text('Fare: ₹$fare', style: const TextStyle(color: Colors.green, fontSize: 18))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))]));
  }

  Future<void> _logout(BuildContext context) async {
    final ds = Provider.of<DriverService>(context, listen: false);
    await ds.logout();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverLoginPage()));
  }
}

