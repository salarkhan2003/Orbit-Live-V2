import 'package:flutter/foundation.dart';

/// Ola Maps configuration
/// API Key is used for the Ola Maps JS SDK
/// Do NOT put OAuth Client Secret in this file - keep it server-side only
class OlaMapsConfig {
  // Ola Maps Project details
  static const String projectName = 'ORBIT LIVE MAPS';
  static const String projectId = 'c6ef34e6-83ff-4a81-a51a-cd823c92cf34';

  // API Key for Maps (safe for client-side use)
  static const String apiKey = 'aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK';

  // Default map center (Andhra Pradesh - Guntur area)
  static const double defaultLat = 16.3067;
  static const double defaultLon = 80.4365;
  static const double defaultZoom = 13.0;

  // Ola Maps SDK URL
  static const String sdkUrl = 'https://api.olamaps.io/tiles/vector/v1/styles/default/style.json';

  // Get the tile URL for Ola Maps
  static String get tileStyleUrl {
    return '$sdkUrl?api_key=$apiKey';
  }

  /// Generate HTML for WebView-based Ola Maps
  /// This creates a full HTML page that loads Ola Maps JS SDK
  static String generateMapHtml({
    double centerLat = defaultLat,
    double centerLon = defaultLon,
    double zoom = defaultZoom,
    List<Map<String, dynamic>> busStops = const [],
    List<Map<String, dynamic>> buses = const [],
    Map<String, dynamic>? userLocation,
  }) {
    // Generate bus stop markers
    final busStopMarkersJs = busStops.map((stop) {
      return '''
        new ola.Marker({
          color: '#2196F3',
        })
        .setLngLat([${stop['lon']}, ${stop['lat']}])
        .setPopup(new ola.Popup().setHTML('<b>${_escapeHtml(stop['name'] ?? 'Bus Stop')}</b>'))
        .addTo(map);
      ''';
    }).join('\n');

    // Generate bus markers with route labels
    final busMarkersJs = buses.map((bus) {
      final color = bus['busType'] == 'AC' ? '#4CAF50' : '#FF5722';
      final label = _escapeHtml('${bus['routeId']} / ${bus['vehicleId']}');
      return '''
        var busMarker_${bus['vehicleId'].toString().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')} = new ola.Marker({
          color: '$color',
        })
        .setLngLat([${bus['lon']}, ${bus['lat']}])
        .setPopup(new ola.Popup().setHTML('<b>$label</b><br>Status: ${_escapeHtml(bus['status'] ?? 'Unknown')}<br>Last update: ${_escapeHtml(bus['formattedTime'] ?? 'N/A')}'))
        .addTo(map);
        busMarker_${bus['vehicleId'].toString().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.getElement().addEventListener('click', function() {
          window.flutter_inappwebview.callHandler('onBusTap', '${bus['vehicleId']}');
        });
      ''';
    }).join('\n');

    // Generate user location marker
    final userMarkerJs = userLocation != null ? '''
      new ola.Marker({
        color: '#2962FF',
      })
      .setLngLat([${userLocation['lon']}, ${userLocation['lat']}])
      .setPopup(new ola.Popup().setHTML('<b>Your Location</b>'))
      .addTo(map);
    ''' : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Orbit Live Map</title>
  <script src="https://unpkg.com/olamaps-js-sdk@1.0.3/dist/olamaps-js-sdk.umd.js"></script>
  <link href="https://unpkg.com/olamaps-js-sdk@1.0.3/dist/style.css" rel="stylesheet" />
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; }
    #map { width: 100%; height: 100%; }
    .bus-marker {
      width: 30px;
      height: 30px;
      background-color: #FF5722;
      border-radius: 50%;
      border: 3px solid white;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
    }
    .bus-marker.ac { background-color: #4CAF50; }
    .bus-marker svg { width: 18px; height: 18px; fill: white; }
    .user-marker {
      width: 20px;
      height: 20px;
      background-color: #2962FF;
      border-radius: 50%;
      border: 3px solid white;
      box-shadow: 0 0 0 8px rgba(41, 98, 255, 0.3);
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0% { box-shadow: 0 0 0 0 rgba(41, 98, 255, 0.4); }
      70% { box-shadow: 0 0 0 15px rgba(41, 98, 255, 0); }
      100% { box-shadow: 0 0 0 0 rgba(41, 98, 255, 0); }
    }
    .stop-marker {
      width: 24px;
      height: 24px;
      background-color: #2196F3;
      border-radius: 50%;
      border: 2px solid white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    const olaMaps = new OlaMapsSDK.OlaMaps({
      apiKey: '$apiKey'
    });
    
    const map = olaMaps.init({
      container: 'map',
      center: [$centerLon, $centerLat],
      zoom: $zoom,
      style: "https://api.olamaps.io/tiles/vector/v1/styles/default-light-standard/style.json"
    });
    
    map.on('load', function() {
      // Add bus stop markers
      $busStopMarkersJs
      
      // Add bus markers
      $busMarkersJs
      
      // Add user location marker
      $userMarkerJs
      
      // Notify Flutter that map is ready
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onMapReady');
      }
    });
    
    // Function to update bus positions (called from Flutter)
    window.updateBusPositions = function(busesJson) {
      // This will be called from Flutter to update bus positions
      console.log('Updating bus positions:', busesJson);
    };
    
    // Function to center map on location
    window.centerMap = function(lat, lon, zoom) {
      map.flyTo({ center: [lon, lat], zoom: zoom || 15 });
    };
  </script>
</body>
</html>
''';
  }

  /// Escape HTML special characters
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Debug print configuration
  static void printConfig() {
    debugPrint('[OLA_MAPS] Project: $projectName');
    debugPrint('[OLA_MAPS] Project ID: $projectId');
    debugPrint('[OLA_MAPS] API Key: ${apiKey.substring(0, 10)}...');
  }
}

