import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Manages location permissions for the Orbit Live app
/// Ensures proper GPS access before starting live tracking
class LocationPermissionManager {
  /// Ensures location permissions are granted before allowing live tracking
  /// Returns true if permissions are granted, false otherwise
  static Future<bool> ensureLocationPermissions(BuildContext context) async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog(context);
        return false;
      }

      // 2. Check existing permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      // 3. Handle different permission states
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedMessage(context);
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog(context);
        return false;
      }

      // 4. Permission granted (whileInUse or always)
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        _showPermissionGrantedMessage(context);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error checking location permissions: $e');
      _showPermissionErrorMessage(context, e.toString());
      return false;
    }
  }

  /// Shows dialog when location services are disabled
  static void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('GPS Disabled'),
            ],
          ),
          content: const Text(
            'Location services are disabled. Please enable GPS in your device settings to use live tracking.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Shows message when permission is denied
  static void _showPermissionDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_disabled_outlined, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Location permission denied. Live tracking disabled.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// Shows dialog when permission is permanently denied
  static void _showPermissionDeniedForeverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Permission Required'),
            ],
          ),
          content: const Text(
            'Location permission is permanently denied. Please go to app settings and enable location access to use live tracking.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Shows success message when permission is granted
  static void _showPermissionGrantedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('✅ Location permission granted! Live tracking enabled.'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows error message when permission check fails
  static void _showPermissionErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Permission check failed: $error'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Quick check if location permissions are currently granted
  static Future<bool> hasLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('❌ Error checking location permission: $e');
      return false;
    }
  }
}