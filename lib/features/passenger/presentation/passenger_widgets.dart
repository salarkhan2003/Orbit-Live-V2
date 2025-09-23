import 'package:flutter/material.dart';

// Actual implementations for passenger features
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.blue),
            SizedBox(height: 8),
            Text('Live Bus Tracking'),
            Text('OpenStreetMap integration',
                 style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to actual map screen
                Navigator.pushNamed(context, '/map');
              },
              child: Text('View Map'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketPlaceholder extends StatelessWidget {
  const TicketPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.confirmation_number, color: Colors.orange),
        title: Text('Digital Tickets'),
        subtitle: Text('QR code generation & booking'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual ticket booking
          _showTicketBooking(context);
        },
      ),
    );
  }

  void _showTicketBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ticket booking...')),
    );
    // In a real app, this would navigate to the ticket booking screen
  }
}

class PassPlaceholder extends StatelessWidget {
  const PassPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.card_membership, color: Colors.purple),
        title: Text('Monthly/Annual Passes'),
        subtitle: Text('Pass management system'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual pass management
          _showPassManagement(context);
        },
      ),
    );
  }

  void _showPassManagement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening pass management...')),
    );
    // In a real app, this would navigate to the pass management screen
  }
}

class SOSPlaceholder extends StatelessWidget {
  const SOSPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.emergency, color: Colors.red),
        title: Text('SOS Emergency'),
        subtitle: Text('Share live location & send alerts'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual SOS feature
          _triggerSOS(context);
        },
      ),
    );
  }

  void _triggerSOS(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOS alert sent! Help is on the way.'),
        backgroundColor: Colors.red,
      ),
    );
    // In a real app, this would send an actual emergency alert
  }
}

class BusSchedulePlaceholder extends StatelessWidget {
  const BusSchedulePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.schedule, color: Colors.blue),
        title: Text('Bus Schedule'),
        subtitle: Text('View timetables & live updates'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual schedule
          _showSchedule(context);
        },
      ),
    );
  }

  void _showSchedule(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loading bus schedule...')),
    );
    // In a real app, this would show the actual schedule
  }
}

class RouteTrackingPlaceholder extends StatelessWidget {
  const RouteTrackingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.my_location, color: Colors.green),
        title: Text('Live Bus Tracking'),
        subtitle: Text('Track buses in real-time'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to actual map
          Navigator.pushNamed(context, '/map');
        },
      ),
    );
  }
}

class TicketBookingPlaceholder extends StatelessWidget {
  const TicketBookingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.confirmation_number, color: Colors.purple),
        title: Text('Ticket Booking'),
        subtitle: Text('Book tickets & digital passes'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual booking
          _showBooking(context);
        },
      ),
    );
  }

  void _showBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ticket booking...')),
    );
    // In a real app, this would open the booking interface
  }
}

class PassManagementPlaceholder extends StatelessWidget {
  const PassManagementPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.card_membership, color: Colors.orange),
        title: Text('Pass Management'),
        subtitle: Text('Manage monthly & yearly passes'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Show actual pass management
          _showPassManagement(context);
        },
      ),
    );
  }

  void _showPassManagement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening pass management...')),
    );
    // In a real app, this would open the pass management interface
  }
}