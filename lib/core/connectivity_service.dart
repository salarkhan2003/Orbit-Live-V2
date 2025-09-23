import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService with ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _isLowBandwidth = false;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus.any((result) => result != ConnectivityResult.none);
  bool get isLowBandwidth => _isLowBandwidth;

  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _updateConnectionStatus(connectivityResult);
    } catch (e) {
      // Handle error
      print('Error initializing connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus = result;
    // For mobile connections, we assume low bandwidth
    _isLowBandwidth = result.any((r) => r == ConnectivityResult.mobile);
    notifyListeners();
  }

  // Method to check if we should use low bandwidth mode
  bool shouldUseLowBandwidthMode() {
    return _isLowBandwidth || _connectionStatus.every((result) => result == ConnectivityResult.none);
  }

  // Method to get appropriate image quality based on connection
  String getImageQuality() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'high';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'low';
    } else {
      return 'none';
    }
  }

  // Method to get appropriate data refresh interval based on connection
  Duration getRefreshInterval() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Duration(seconds: 10); // Refresh every 10 seconds on WiFi
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Duration(seconds: 30); // Refresh every 30 seconds on mobile
    } else {
      return Duration(minutes: 1); // Refresh every minute when offline
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}