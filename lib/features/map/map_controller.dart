import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_styles.dart';

class MapController {
  static GoogleMapController? _mapController;

  static void initialize(GoogleMapController controller) {
    _mapController = controller;
  }

  static Future<void> setMapStyle(String style) async {
    if (_mapController != null) {
      await _mapController!.setMapStyle(style);
    }
  }

  static Future<void> setDarkTheme() async {
    await setMapStyle(MapStyles.darkMapStyle);
  }

  static Future<void> setLightTheme() async {
    await setMapStyle(MapStyles.lightMapStyle);
  }

  static Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(cameraUpdate);
    }
  }

  static Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    if (_mapController != null) {
      await _mapController!.moveCamera(cameraUpdate);
    }
  }
}
