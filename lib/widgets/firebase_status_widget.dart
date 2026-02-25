import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Widget to show Firebase connection status and project info
class FirebaseStatusWidget extends StatefulWidget {
  const FirebaseStatusWidget({super.key});

  @override
  State<FirebaseStatusWidget> createState() => _FirebaseStatusWidgetState();
}

class _FirebaseStatusWidgetState extends State<FirebaseStatusWidget> {
  bool _isConnected = false;
  String _connectionStatus = 'Testing...';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      await FirebaseDatabase.instance.ref('test/mobile-connection').set({
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'project_id': Firebase.app().options.projectId,
        'test': true,
      });
      
      await FirebaseDatabase.instance.ref('test/mobile-connection').remove();
      
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected ✓';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectId = Firebase.app().options.projectId ?? 'Unknown';
    final isCorrectProject = projectId == 'orbit-live-3836f';

    return Card(
      color: isCorrectProject && _isConnected 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrectProject && _isConnected 
                      ? Icons.cloud_done 
                      : Icons.cloud_off,
                  color: isCorrectProject && _isConnected 
                      ? Colors.green 
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Firebase Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Project: $projectId'),
            Text('Status: $_connectionStatus'),
            if (!isCorrectProject)
              const Text(
                'ERROR: Wrong project! Should be orbit-live-3836f',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}