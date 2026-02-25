import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'network_handler.dart';

/// Enhanced connectivity service with offline mode and network quality monitoring
class EnhancedConnectivityService with ChangeNotifier {
  late StreamSubscription<NetworkStatus> _networkSubscription;
  NetworkStatus? _currentStatus;
  bool _isOfflineMode = false;
  final List<VoidCallback> _connectionListeners = [];
  final List<VoidCallback> _disconnectionListeners = [];
  
  // Getters
  NetworkStatus? get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus?.isConnected ?? false;
  bool get isOfflineMode => _isOfflineMode;
  ConnectionQuality get connectionQuality => _currentStatus?.quality ?? ConnectionQuality.unknown;
  bool get isWifi => _currentStatus?.isWifi ?? false;
  bool get isMobile => _currentStatus?.isMobile ?? false;
  bool get hasHighQualityConnection => connectionQuality == ConnectionQuality.high;
  
  EnhancedConnectivityService() {
    _initializeConnectivity();
  }
  
  void _initializeConnectivity() {
    // Listen to network status changes
    _networkSubscription = NetworkHandler.createConnectivityStream().listen(
      _onNetworkStatusChanged,
      onError: _onNetworkError,
    );
    
    // Initial connectivity check
    _performInitialConnectivityCheck();
  }
  
  Future<void> _performInitialConnectivityCheck() async {
    try {
      final hasInternet = await NetworkHandler.hasInternetConnection();
      final quality = await NetworkHandler.getConnectionQuality();
      final connectivityResults = await Connectivity().checkConnectivity();
      
      _currentStatus = NetworkStatus(
        connectivityResults: connectivityResults,
        hasInternet: hasInternet,
        quality: quality,
        timestamp: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initial connectivity check: $e');
    }
  }
  
  void _onNetworkStatusChanged(NetworkStatus status) {
    final wasConnected = _currentStatus?.isConnected ?? false;
    _currentStatus = status;
    
    // Notify connection state changes
    if (!wasConnected && status.isConnected) {
      _notifyConnectionRestored();
    } else if (wasConnected && !status.isConnected) {
      _notifyConnectionLost();
    }
    
    notifyListeners();
  }
  
  void _onNetworkError(dynamic error) {
    debugPrint('Network monitoring error: $error');
    // Handle network monitoring errors gracefully
  }
  
  void _notifyConnectionRestored() {
    for (final listener in _connectionListeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error in connection listener: $e');
      }
    }
  }
  
  void _notifyConnectionLost() {
    for (final listener in _disconnectionListeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error in disconnection listener: $e');
      }
    }
  }
  
  /// Adds a listener for when connection is restored
  void addConnectionListener(VoidCallback listener) {
    _connectionListeners.add(listener);
  }
  
  /// Removes a connection listener
  void removeConnectionListener(VoidCallback listener) {
    _connectionListeners.remove(listener);
  }
  
  /// Adds a listener for when connection is lost
  void addDisconnectionListener(VoidCallback listener) {
    _disconnectionListeners.add(listener);
  }
  
  /// Removes a disconnection listener
  void removeDisconnectionListener(VoidCallback listener) {
    _disconnectionListeners.remove(listener);
  }
  
  /// Enables offline mode
  void enableOfflineMode() {
    if (!_isOfflineMode) {
      _isOfflineMode = true;
      notifyListeners();
    }
  }
  
  /// Disables offline mode
  void disableOfflineMode() {
    if (_isOfflineMode) {
      _isOfflineMode = false;
      notifyListeners();
    }
  }
  
  /// Toggles offline mode
  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }
  
  /// Checks if the current connection is suitable for heavy operations
  Future<bool> isSuitableForHeavyOperations() async {
    if (_isOfflineMode) return false;
    return NetworkHandler.isSuitableForHeavyOperations();
  }
  
  /// Gets appropriate timeout for current connection
  Future<Duration> getAdaptiveTimeout() async {
    return NetworkHandler.getAdaptiveTimeout();
  }
  
  /// Waits for connection to be restored
  Future<void> waitForConnection({
    Duration maxWait = const Duration(minutes: 2),
  }) async {
    if (isConnected && !_isOfflineMode) return;
    
    final completer = Completer<void>();
    late VoidCallback listener;
    
    listener = () {
      if (isConnected && !_isOfflineMode) {
        removeConnectionListener(listener);
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    };
    
    addConnectionListener(listener);
    
    // Set up timeout
    Timer(maxWait, () {
      removeConnectionListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Connection not restored within timeout', maxWait),
        );
      }
    });
    
    return completer.future;
  }
  
  /// Executes an operation with network handling
  Future<T> executeWithNetworkHandling<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    bool requiresInternet = true,
    String? operationName,
    T? fallbackValue,
  }) async {
    // Check offline mode
    if (_isOfflineMode && requiresInternet) {
      if (fallbackValue != null) {
        return fallbackValue;
      }
      throw NetworkException(
        'Operation not available in offline mode',
        NetworkErrorType.noConnection,
      );
    }
    
    try {
      return await NetworkHandler.executeWithConnectivityCheck(
        operation,
        timeout: timeout,
        requiresInternet: requiresInternet,
        operationName: operationName,
      );
    } catch (e) {
      if (fallbackValue != null && e is NetworkException) {
        return fallbackValue;
      }
      rethrow;
    }
  }
  
  /// Gets connection status summary
  String getConnectionStatusSummary() {
    if (_isOfflineMode) {
      return 'Offline Mode';
    }
    
    if (_currentStatus == null) {
      return 'Checking connection...';
    }
    
    if (!_currentStatus!.isConnected) {
      return 'No connection';
    }
    
    final quality = _currentStatus!.quality;
    final type = _currentStatus!.isWifi ? 'WiFi' : 
                 _currentStatus!.isMobile ? 'Mobile' : 
                 _currentStatus!.isEthernet ? 'Ethernet' : 'Unknown';
    
    return '$type (${quality.name} quality)';
  }
  
  /// Gets recommended data usage mode
  DataUsageMode getRecommendedDataUsageMode() {
    if (_isOfflineMode || !isConnected) {
      return DataUsageMode.offline;
    }
    
    switch (connectionQuality) {
      case ConnectionQuality.high:
        return DataUsageMode.full;
      case ConnectionQuality.medium:
        return DataUsageMode.optimized;
      case ConnectionQuality.low:
        return DataUsageMode.minimal;
      default:
        return DataUsageMode.minimal;
    }
  }
  
  /// Forces a connectivity refresh
  Future<void> refreshConnectivity() async {
    await _performInitialConnectivityCheck();
  }
  
  @override
  void dispose() {
    _networkSubscription.cancel();
    _connectionListeners.clear();
    _disconnectionListeners.clear();
    super.dispose();
  }
}

/// Data usage modes based on connection quality
enum DataUsageMode {
  offline,    // No data usage
  minimal,    // Essential data only
  optimized,  // Reduced quality/frequency
  full,       // Full quality/frequency
}

/// Extension methods for easier usage
extension DataUsageModeExtension on DataUsageMode {
  bool get allowsImages => this != DataUsageMode.offline;
  bool get allowsHighQualityImages => this == DataUsageMode.full;
  bool get allowsVideoStreaming => this == DataUsageMode.full;
  bool get allowsFrequentUpdates => this == DataUsageMode.full || this == DataUsageMode.optimized;
  
  Duration get refreshInterval {
    switch (this) {
      case DataUsageMode.offline:
        return const Duration(minutes: 10);
      case DataUsageMode.minimal:
        return const Duration(minutes: 5);
      case DataUsageMode.optimized:
        return const Duration(minutes: 2);
      case DataUsageMode.full:
        return const Duration(seconds: 30);
    }
  }
}