import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/orbit_live_colors.dart';
import 'driver_dashboard.dart';

/// Screen for selecting/entering APSRTC Vehicle ID
class VehicleIdSelectionScreen extends StatefulWidget {
  const VehicleIdSelectionScreen({super.key});

  @override
  State<VehicleIdSelectionScreen> createState() => _VehicleIdSelectionScreenState();
}

class _VehicleIdSelectionScreenState extends State<VehicleIdSelectionScreen> {
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();
  bool _isLoading = false;
  String? _savedVehicleId;

  // Predefined APSRTC vehicle IDs for quick selection
  final List<String> _predefinedVehicleIds = [
    'APSRTC-VEH-001',
    'APSRTC-VEH-002', 
    'APSRTC-VEH-003',
    'APSRTC-VEH-004',
    'APSRTC-VEH-005',
    'APSRTC-VEH-006',
    'APSRTC-VEH-007',
    'APSRTC-VEH-008',
    'APSRTC-VEH-009',
    'APSRTC-VEH-010',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedVehicleId();
  }

  /// Load previously used vehicle ID from storage
  Future<void> _loadSavedVehicleId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('vehicle_id');
      if (savedId != null && savedId.isNotEmpty) {
        setState(() {
          _savedVehicleId = savedId;
          _vehicleIdController.text = savedId;
          _driverIdController.text = 'DRIVER-${savedId.split('-').last}';
        });
      }
    } catch (e) {
      debugPrint('Error loading saved vehicle ID: $e');
    }
  }

  /// Save vehicle ID to storage for future use
  Future<void> _saveVehicleId(String vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vehicle_id', vehicleId);
      debugPrint('Vehicle ID saved: $vehicleId');
    } catch (e) {
      debugPrint('Error saving vehicle ID: $e');
    }
  }

  /// Validate APSRTC vehicle ID format
  bool _isValidVehicleId(String vehicleId) {
    if (vehicleId.isEmpty) return false;
    
    // Must start with APSRTC-VEH- and have at least 3 digits/characters after
    final regex = RegExp(r'^APSRTC-VEH-[A-Z0-9]{3,}$');
    return regex.hasMatch(vehicleId.toUpperCase());
  }

  /// Start trip with selected vehicle ID
  Future<void> _startTrip() async {
    final vehicleId = _vehicleIdController.text.trim().toUpperCase();
    final driverId = _driverIdController.text.trim();

    // Validate vehicle ID
    if (!_isValidVehicleId(vehicleId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid APSRTC Vehicle ID (e.g., APSRTC-VEH-001)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save vehicle ID for future use
      await _saveVehicleId(vehicleId);

      // Navigate to driver dashboard with selected vehicle ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverDashboard(
            customVehicleId: vehicleId,
            customDriverId: driverId.isNotEmpty ? driverId : 'DRIVER-${vehicleId.split('-').last}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitLiveColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Select Vehicle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'APSRTC Vehicle Selection',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Select or enter your vehicle ID to start tracking',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(height: 32),

              // Saved Vehicle ID (if available)
              if (_savedVehicleId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Used Vehicle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _savedVehicleId!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Selection
              const Text(
                'Quick Selection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                height: 120,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _predefinedVehicleIds.length,
                  itemBuilder: (context, index) {
                    final vehicleId = _predefinedVehicleIds[index];
                    final isSelected = _vehicleIdController.text == vehicleId;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _vehicleIdController.text = vehicleId;
                          _driverIdController.text = 'DRIVER-${vehicleId.split('-').last}';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            vehicleId,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Manual Input
              const Text(
                'Or Enter Manually',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Vehicle ID Input
              TextFormField(
                controller: _vehicleIdController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter APSRTC Vehicle ID (e.g., APSRTC-VEH-001)',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.directions_bus, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  // Auto-generate driver ID based on vehicle ID
                  if (value.toUpperCase().startsWith('APSRTC-VEH-')) {
                    final parts = value.toUpperCase().split('-');
                    if (parts.length >= 3) {
                      _driverIdController.text = 'DRIVER-${parts.last}';
                    }
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Driver ID Input
              TextFormField(
                controller: _driverIdController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Driver ID (auto-generated)',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Each vehicle ID creates a separate tracking node in Firebase. Multiple phones can run simultaneously with different IDs.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startTrip,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isLoading ? 'Starting...' : 'Start Driver Dashboard',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: OrbitLiveColors.primaryBlue,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _driverIdController.dispose();
    super.dispose();
  }
}