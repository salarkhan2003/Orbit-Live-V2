import 'dart:async';
import 'dart:math';

/// Utility for implementing retry mechanisms with exponential backoff
class RetryMechanism {
  /// Executes a function with retry logic and exponential backoff
  static Future<T> execute<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;
    
    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // If this was the last attempt, rethrow the error
        if (attempt > maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(currentDelay);
        
        // Calculate next delay with exponential backoff and jitter
        currentDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * backoffMultiplier).round(),
            maxDelay.inMilliseconds,
          ),
        );
        
        // Add jitter to prevent thundering herd
        final jitter = Random().nextDouble() * 0.1 * currentDelay.inMilliseconds;
        currentDelay = Duration(
          milliseconds: currentDelay.inMilliseconds + jitter.round(),
        );
      }
    }
    
    // This should never be reached, but just in case
    throw StateError('Retry mechanism failed unexpectedly');
  }
  
  /// Predefined retry conditions for common scenarios
  static bool shouldRetryNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Retry on network-related errors
    if (errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket')) {
      return true;
    }
    
    // Retry on server errors (5xx)
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }
    
    // Don't retry on client errors (4xx)
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404')) {
      return false;
    }
    
    return false;
  }
  
  /// Predefined retry conditions for authentication errors
  static bool shouldRetryAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Don't retry on credential errors
    if (errorString.contains('invalid credentials') ||
        errorString.contains('wrong password') ||
        errorString.contains('unauthorized')) {
      return false;
    }
    
    // Don't retry on account issues
    if (errorString.contains('account disabled') ||
        errorString.contains('account suspended') ||
        errorString.contains('user not found')) {
      return false;
    }
    
    // Retry on temporary issues
    if (errorString.contains('server error') ||
        errorString.contains('service unavailable') ||
        errorString.contains('timeout')) {
      return true;
    }
    
    return false;
  }
  
  /// Creates a retry configuration for network operations
  static RetryConfig networkRetryConfig() {
    return RetryConfig(
      maxRetries: 3,
      initialDelay: const Duration(seconds: 1),
      backoffMultiplier: 2.0,
      maxDelay: const Duration(seconds: 10),
      shouldRetry: shouldRetryNetworkError,
    );
  }
  
  /// Creates a retry configuration for authentication operations
  static RetryConfig authRetryConfig() {
    return RetryConfig(
      maxRetries: 2,
      initialDelay: const Duration(milliseconds: 500),
      backoffMultiplier: 1.5,
      maxDelay: const Duration(seconds: 5),
      shouldRetry: shouldRetryAuthError,
    );
  }
  
  /// Creates a retry configuration for critical operations
  static RetryConfig criticalRetryConfig() {
    return RetryConfig(
      maxRetries: 5,
      initialDelay: const Duration(milliseconds: 200),
      backoffMultiplier: 1.8,
      maxDelay: const Duration(seconds: 15),
      shouldRetry: (error) => true, // Retry all errors for critical operations
    );
  }
}

/// Configuration class for retry mechanisms
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxRetries;
  
  /// Initial delay before first retry
  final Duration initialDelay;
  
  /// Multiplier for exponential backoff
  final double backoffMultiplier;
  
  /// Maximum delay between retries
  final Duration maxDelay;
  
  /// Function to determine if an error should trigger a retry
  final bool Function(dynamic error)? shouldRetry;
  
  const RetryConfig({
    required this.maxRetries,
    required this.initialDelay,
    required this.backoffMultiplier,
    required this.maxDelay,
    this.shouldRetry,
  });
  
  /// Executes an operation with this retry configuration
  Future<T> execute<T>(Future<T> Function() operation) {
    return RetryMechanism.execute(
      operation,
      maxRetries: maxRetries,
      initialDelay: initialDelay,
      backoffMultiplier: backoffMultiplier,
      maxDelay: maxDelay,
      shouldRetry: shouldRetry,
    );
  }
}

/// Mixin for classes that need retry functionality
mixin RetryCapable {
  /// Executes an operation with network retry logic
  Future<T> retryNetworkOperation<T>(Future<T> Function() operation) {
    return RetryMechanism.networkRetryConfig().execute(operation);
  }
  
  /// Executes an operation with auth retry logic
  Future<T> retryAuthOperation<T>(Future<T> Function() operation) {
    return RetryMechanism.authRetryConfig().execute(operation);
  }
  
  /// Executes an operation with critical retry logic
  Future<T> retryCriticalOperation<T>(Future<T> Function() operation) {
    return RetryMechanism.criticalRetryConfig().execute(operation);
  }
  
  /// Executes an operation with custom retry configuration
  Future<T> retryWithConfig<T>(
    Future<T> Function() operation,
    RetryConfig config,
  ) {
    return config.execute(operation);
  }
}