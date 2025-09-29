import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'retry_mechanism.dart';

/// Enhanced network handling utility with connectivity checks and timeout management
class NetworkHandler {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _shortTimeout = Duration(seconds: 10);
  static const Duration _longTimeout = Duration(seconds: 60);
  
  /// Checks if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // If no connectivity, return false immediately
      if (connectivityResult.every((result) => result == ConnectivityResult.none)) {
        return false;
      }
      
      // Test actual internet connectivity with a ping
      return await _testInternetConnectivity();
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }
  
  /// Tests actual internet connectivity by attempting to reach a reliable host
  static Future<bool> _testInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Internet connectivity test failed: $e');
      return false;
    }
  }
  
  /// Executes a network operation with proper timeout and connectivity checks
  static Future<T> executeWithConnectivityCheck<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    bool requiresInternet = true,
    String? operationName,
  }) async {
    // Check connectivity if required
    if (requiresInternet) {
      final hasConnection = await hasInternetConnection();
      if (!hasConnection) {
        throw NetworkException(
          'No internet connection available',
          NetworkErrorType.noConnection,
        );
      }
    }
    
    // Execute operation with timeout
    try {
      return await operation().timeout(
        timeout ?? _defaultTimeout,
        onTimeout: () {
          throw NetworkException(
            'Operation timed out${operationName != null ? ' for $operationName' : ''}',
            NetworkErrorType.timeout,
          );
        },
      );
    } on SocketException catch (e) {
      throw NetworkException(
        'Network error: ${e.message}',
        NetworkErrorType.socketError,
      );
    } on TimeoutException catch (e) {
      throw NetworkException(
        'Request timed out: ${e.message}',
        NetworkErrorType.timeout,
      );
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
        'Network operation failed: ${e.toString()}',
        NetworkErrorType.unknown,
      );
    }
  }
  
  /// Executes a network operation with retry logic and connectivity checks
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    RetryConfig? retryConfig,
    bool requiresInternet = true,
    String? operationName,
  }) async {
    final config = retryConfig ?? RetryMechanism.networkRetryConfig();
    
    return config.execute(() async {
      return executeWithConnectivityCheck(
        operation,
        timeout: timeout,
        requiresInternet: requiresInternet,
        operationName: operationName,
      );
    });
  }
  
  /// Gets appropriate timeout based on connection type
  static Future<Duration> getAdaptiveTimeout() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return _shortTimeout; // Faster timeout for WiFi
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return _defaultTimeout; // Standard timeout for mobile
      } else {
        return _longTimeout; // Longer timeout for poor connections
      }
    } catch (e) {
      return _defaultTimeout;
    }
  }
  
  /// Checks if current connection is suitable for heavy operations
  static Future<bool> isSuitableForHeavyOperations() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // WiFi is always suitable
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return true;
      }
      
      // Mobile connections depend on signal strength (simplified check)
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        // In a real app, you might check signal strength here
        return await hasInternetConnection();
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Gets connection quality information
  static Future<ConnectionQuality> getConnectionQuality() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = await hasInternetConnection();
      
      if (!hasInternet) {
        return ConnectionQuality.none;
      }
      
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return ConnectionQuality.high;
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return ConnectionQuality.medium;
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return ConnectionQuality.high;
      }
      
      return ConnectionQuality.low;
    } catch (e) {
      return ConnectionQuality.unknown;
    }
  }
  
  /// Waits for internet connection to become available
  static Future<void> waitForConnection({
    Duration maxWait = const Duration(minutes: 2),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < maxWait) {
      if (await hasInternetConnection()) {
        return;
      }
      
      await Future.delayed(checkInterval);
    }
    
    throw NetworkException(
      'Failed to establish internet connection within ${maxWait.inSeconds} seconds',
      NetworkErrorType.timeout,
    );
  }
  
  /// Creates a stream that monitors connectivity changes
  static Stream<NetworkStatus> createConnectivityStream() {
    return Connectivity().onConnectivityChanged.asyncMap((connectivityResults) async {
      final hasInternet = await hasInternetConnection();
      final quality = await getConnectionQuality();
      
      return NetworkStatus(
        connectivityResults: connectivityResults,
        hasInternet: hasInternet,
        quality: quality,
        timestamp: DateTime.now(),
      );
    });
  }
}

/// Network exception with specific error types
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  final dynamic originalError;
  
  const NetworkException(this.message, this.type, [this.originalError]);
  
  @override
  String toString() {
    return 'NetworkException(${type.name}): $message';
  }
}

/// Types of network errors
enum NetworkErrorType {
  noConnection,
  timeout,
  socketError,
  serverError,
  unknown,
}

/// Connection quality levels
enum ConnectionQuality {
  none,
  low,
  medium,
  high,
  unknown,
}

/// Network status information
class NetworkStatus {
  final List<ConnectivityResult> connectivityResults;
  final bool hasInternet;
  final ConnectionQuality quality;
  final DateTime timestamp;
  
  const NetworkStatus({
    required this.connectivityResults,
    required this.hasInternet,
    required this.quality,
    required this.timestamp,
  });
  
  bool get isConnected => hasInternet;
  bool get isWifi => connectivityResults.contains(ConnectivityResult.wifi);
  bool get isMobile => connectivityResults.contains(ConnectivityResult.mobile);
  bool get isEthernet => connectivityResults.contains(ConnectivityResult.ethernet);
  
  @override
  String toString() {
    return 'NetworkStatus('
        'connected: $hasInternet, '
        'quality: ${quality.name}, '
        'types: ${connectivityResults.map((r) => r.name).join(', ')}'
        ')';
  }
}

/// Mixin for classes that need network handling capabilities
mixin NetworkCapable {
  /// Executes operation with network checks
  Future<T> executeNetworkOperation<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    bool requiresInternet = true,
    String? operationName,
  }) {
    return NetworkHandler.executeWithConnectivityCheck(
      operation,
      timeout: timeout,
      requiresInternet: requiresInternet,
      operationName: operationName,
    );
  }
  
  /// Executes operation with retry and network checks
  Future<T> executeNetworkOperationWithRetry<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    RetryConfig? retryConfig,
    bool requiresInternet = true,
    String? operationName,
  }) {
    return NetworkHandler.executeWithRetry(
      operation,
      timeout: timeout,
      retryConfig: retryConfig,
      requiresInternet: requiresInternet,
      operationName: operationName,
    );
  }
  
  /// Checks if network is available
  Future<bool> isNetworkAvailable() {
    return NetworkHandler.hasInternetConnection();
  }
  
  /// Gets connection quality
  Future<ConnectionQuality> getConnectionQuality() {
    return NetworkHandler.getConnectionQuality();
  }
}