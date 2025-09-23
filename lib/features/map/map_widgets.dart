import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class CustomMarker extends StatelessWidget {
  final gmaps.LatLng position;
  final String title;
  final String snippet;

  const CustomMarker({
    super.key,
    required this.position,
    required this.title,
    required this.snippet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        Icons.location_on,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // Helper method to get the actual Marker for GoogleMap
  gmaps.Marker toMarker() {
    return gmaps.Marker(
      markerId: gmaps.MarkerId(title),
      position: position,
      infoWindow: gmaps.InfoWindow(title: title, snippet: snippet),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueViolet),
    );
  }
}

class AnimatedPolyline extends StatelessWidget {
  final List<gmaps.LatLng> points;
  final Color color;

  const AnimatedPolyline({
    super.key,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
      ),
      child: CustomPaint(
        painter: PolylinePainter(points: points, color: color),
      ),
    );
  }

  // Helper method to get the actual Polyline for GoogleMap
  gmaps.Polyline toPolyline() {
    return gmaps.Polyline(
      polylineId: gmaps.PolylineId('animated'),
      points: points,
      color: color,
      width: 5,
    );
  }
}

class PolylinePainter extends CustomPainter {
  final List<gmaps.LatLng> points;
  final Color color;

  PolylinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (points.length < 2) return;

    final path = Path();
    path.moveTo(0, 0);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(size.width * i / points.length, size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
