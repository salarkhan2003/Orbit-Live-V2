import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/connectivity_service.dart';
import '../../../services/live_telemetry_service.dart';

class DriverTripScreen extends StatefulWidget {
  final String vehicleId;
  final String driverId;
  final String routeId;
  final String routeName;

  const DriverTripScreen({
    super.key,
    required this.vehicleId,
    required this.driverId,
    required this.routeId,
    required this.routeName,
  });

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen>
    with TickerProviderStateMixin {
  // State
  bool _isLoading = false;
  bool _isTripActive = false;
  bool _isBroadcasting = false;
  String? _currentTripId;
  String? _errorMessage;

  // Telemetry info
  double _currentLat = 0.0;
  double _currentLon = 0.0;
  double _currentSpeed = 0.0;
  int _currentHeading = 0;
  int _telemetrySentCount = 0;
  DateTime? _lastTelemetryTime;
  DateTime? _tripStartTime;

  // GPS stream
  StreamSubscription<Position>? _positionSubscription;
  Timer? _telemetryTimer;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }


  @override
  void dispose() {
    _pulseController.dispose();
    _positionSubscription?.cancel();
    _telemetryTimer?.cancel();
    super.dispose();
  }

  /// Check and request location permissions
  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable GPS.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied. Cannot track trip.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permission permanently denied. Please enable in settings.');
      return false;
    }

    return true;
  }

  /// Start trip and begin GPS broadcasting
  Future<void> _startTrip() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Start live telemetry tracking
      final tripId = 'TRIP-${DateTime.now().millisecondsSinceEpoch}';
      final success = await LiveTelemetryService.startTracking(
        vehicleId: widget.vehicleId,
        routeId: widget.routeId,
      );
      
      if (!success) {
        throw Exception('Failed to start GPS tracking');
      }

      // Get position for UI display
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Start GPS stream for UI updates only (LiveTelemetryService handles Firebase)
      _startGpsStream(tripId);

      setState(() {
        _currentTripId = tripId;
        _isTripActive = true;
        _isBroadcasting = true;
        _tripStartTime = DateTime.now();
        _currentLat = position.latitude;
        _currentLon = position.longitude;
        _telemetrySentCount = 1;
        _lastTelemetryTime = DateTime.now();
      });

      _showSuccess('Trip started! Broadcasting to Control Room');
    } catch (e) {
      _showError('Failed to start trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Start GPS position stream with 5-10 second interval
  void _startGpsStream(String tripId) {
    // Position stream with distance filter
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen(
      (Position position) {
        setState(() {
          _currentLat = position.latitude;
          _currentLon = position.longitude;
          _currentSpeed = position.speed * 3.6; // m/s to km/h
          _currentHeading = position.heading.round();
        });
      },
      onError: (error) {
        debugPrint('GPS error: $error');
      },
    );

    // Timer to send telemetry every 5-10 seconds (adaptive based on speed)
    _telemetryTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isTripActive) {
        timer.cancel();
        return;
      }

      // Battery optimization: slower updates when nearly stationary
      final interval = _currentSpeed < 5 ? 15 : 5;
      if (timer.tick % (interval ~/ 5) != 0 && _currentSpeed < 5) {
        return; // Skip this tick for slow speed
      }

      await _sendTelemetryUpdate(tripId);
    });
  }


  /// Update UI telemetry counter (LiveTelemetryService handles actual Firebase updates)
  Future<void> _sendTelemetryUpdate(String tripId) async {
    try {
      // LiveTelemetryService is already handling Firebase updates automatically
      // This just updates the UI counter
      setState(() {
        _telemetrySentCount++;
        _lastTelemetryTime = DateTime.now();
        _isBroadcasting = LiveTelemetryService.isTracking;
      });
    } catch (e) {
      debugPrint('Telemetry UI update error: $e');
    }
  }

  /// End trip and stop broadcasting
  Future<void> _endTrip() async {
    if (_currentTripId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Stop GPS stream
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _telemetryTimer?.cancel();
      _telemetryTimer = null;

      // Stop live telemetry tracking
      await LiveTelemetryService.stopTracking();

      setState(() {
        _isTripActive = false;
        _isBroadcasting = false;
        _currentTripId = null;
        _tripStartTime = null;
      });

      _showSuccess('Trip ended. Stopped broadcasting.');
    } catch (e) {
      _showError('Failed to end trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Control', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  connectivity.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: connectivity.isConnected ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBroadcastStatus(),
            const SizedBox(height: 20),
            _buildTripInfo(),
            const SizedBox(height: 20),
            _buildTripControls(),
            if (_isTripActive) ...[
              const SizedBox(height: 20),
              _buildTelemetryInfo(),
              const SizedBox(height: 20),
              _buildTripStats(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              _buildErrorCard(),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildBroadcastStatus() {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        final isOnline = connectivity.isConnected;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isBroadcasting
                      ? (isOnline
                          ? [Colors.green.shade600, Colors.green.shade400]
                          : [Colors.orange.shade600, Colors.orange.shade400])
                      : [Colors.grey.shade600, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isBroadcasting
                            ? (isOnline ? Colors.green : Colors.orange)
                            : Colors.grey)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: _isBroadcasting ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isBroadcasting ? Icons.cell_tower : Icons.cell_tower_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isBroadcasting
                                ? 'Live: Broadcasting to Control Room'
                                : 'Offline: Not Broadcasting',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isBroadcasting
                                ? (isOnline ? 'GPS telemetry active' : 'Buffering offline')
                                : 'Start trip to begin broadcasting',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isBroadcasting)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.greenAccent : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? 'LIVE' : 'OFFLINE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTripInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.info_outline, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Text('Trip Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Vehicle ID', widget.vehicleId),
          _buildInfoRow('Driver ID', widget.driverId),
          _buildInfoRow('Route', '${widget.routeId} - ${widget.routeName}'),
          if (_currentTripId != null) _buildInfoRow('Trip ID', _currentTripId!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }


  Widget _buildTripControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.play_circle_outline, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text('Trip Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading || _isTripActive ? null : _startTrip,
                  icon: _isLoading && !_isTripActive
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isLoading && !_isTripActive ? 'Starting...' : 'Start Trip',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading || !_isTripActive ? null : _endTrip,
                  icon: _isLoading && _isTripActive
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.stop),
                  label: Text(
                    _isLoading && _isTripActive ? 'Ending...' : 'End Trip',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.satellite_alt, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              const Text('Live Telemetry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTelemetryCard('Latitude', _currentLat.toStringAsFixed(6), Icons.location_on, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildTelemetryCard('Longitude', _currentLon.toStringAsFixed(6), Icons.location_on, Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTelemetryCard('Speed', '${_currentSpeed.toStringAsFixed(1)} km/h', Icons.speed, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildTelemetryCard('Heading', '$_currentHeading°', Icons.explore, Colors.purple)),
            ],
          ),
          if (_lastTelemetryTime != null) ...[
            const SizedBox(height: 12),
            Text(
              'Last update: ${_lastTelemetryTime!.hour.toString().padLeft(2, '0')}:${_lastTelemetryTime!.minute.toString().padLeft(2, '0')}:${_lastTelemetryTime!.second.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }


  Widget _buildTripStats() {
    final duration = _tripStartTime != null ? DateTime.now().difference(_tripStartTime!) : Duration.zero;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.analytics, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              const Text('Trip Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Duration', _formatDuration(duration), Icons.timer, Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Updates Sent', _telemetrySentCount.toString(), Icons.upload, Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _errorMessage = null),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }
}
