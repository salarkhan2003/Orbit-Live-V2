import '../domain/conductor_auth_data.dart';
import '../../../shared/utils/retry_mechanism.dart';
import '../../../shared/utils/network_handler.dart';

/// Service for handling conductor authentication operations
class ConductorAuthService with RetryCapable, NetworkCapable {
  /// Authenticates a conductor with login credentials
  static Future<ConductorAuthResult> login(ConductorAuthData authData) async {
    final service = ConductorAuthService();
    
    return service.executeNetworkOperationWithRetry(() async {
      try {
        // Validate input data
        if (!authData.isLogin) {
          throw ConductorAuthException('Invalid authentication mode for login');
        }
        
        final validationErrors = authData.validate();
        if (validationErrors.isNotEmpty) {
          throw ConductorAuthException(validationErrors.first);
        }
        
        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Mock authentication logic
        if (await _validateCredentials(authData.employeeId, authData.password)) {
          return ConductorAuthResult.success(
            employeeId: authData.employeeId,
            fullName: 'Mock Driver', // In real app, this would come from API
            phoneNumber: '+1234567890',
          );
        } else {
          throw ConductorAuthException('Invalid employee ID or password');
        }
      } catch (e) {
        if (e is ConductorAuthException) {
          rethrow;
        }
        if (e is NetworkException) {
          throw ConductorAuthException('Network error during login: ${e.message}');
        }
        throw ConductorAuthException('Login failed: ${e.toString()}');
      }
    }, 
    operationName: 'Conductor Login',
    requiresInternet: true,
    );
  }
  
  /// Registers a new conductor account
  static Future<ConductorAuthResult> signup(ConductorAuthData authData) async {
    final service = ConductorAuthService();
    
    return service.executeNetworkOperationWithRetry(() async {
      try {
        // Validate input data
        if (authData.isLogin) {
          throw ConductorAuthException('Invalid authentication mode for signup');
        }
        
        final validationErrors = authData.validate();
        if (validationErrors.isNotEmpty) {
          throw ConductorAuthException(validationErrors.first);
        }
        
        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Mock signup logic
        if (await _isEmployeeIdAvailable(authData.employeeId)) {
          return ConductorAuthResult.success(
            employeeId: authData.employeeId,
            fullName: authData.fullName!,
            phoneNumber: authData.phoneNumber!,
          );
        } else {
          throw ConductorAuthException('Employee ID is already registered');
        }
      } catch (e) {
        if (e is ConductorAuthException) {
          rethrow;
        }
        if (e is NetworkException) {
          throw ConductorAuthException('Network error during signup: ${e.message}');
        }
        throw ConductorAuthException('Signup failed: ${e.toString()}');
      }
    },
    operationName: 'Conductor Signup',
    requiresInternet: true,
    );
  }
  
  /// Validates conductor credentials (mock implementation)
  static Future<bool> _validateCredentials(String employeeId, String password) async {
    // Mock validation - in real app, this would call an API
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Accept any employee ID with password length >= 6
    return employeeId.isNotEmpty && password.length >= 6;
  }
  
  /// Checks if employee ID is available for registration (mock implementation)
  static Future<bool> _isEmployeeIdAvailable(String employeeId) async {
    // Mock availability check - in real app, this would call an API
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate some employee IDs being taken
    final takenIds = ['admin', 'test', 'demo', '123'];
    return !takenIds.contains(employeeId.toLowerCase());
  }
  
  /// Validates employee ID format and availability
  static Future<String?> validateEmployeeId(String employeeId) async {
    if (employeeId.isEmpty) {
      return 'Employee ID is required';
    }
    
    if (employeeId.length < 3) {
      return 'Employee ID must be at least 3 characters';
    }
    
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!regex.hasMatch(employeeId)) {
      return 'Employee ID can only contain letters, numbers, hyphens, and underscores';
    }
    
    try {
      final isAvailable = await _isEmployeeIdAvailable(employeeId);
      if (!isAvailable) {
        return 'Employee ID is already registered';
      }
    } catch (e) {
      return 'Unable to verify employee ID availability';
    }
    
    return null; // No errors
  }
  
  /// Resets password for a conductor (mock implementation)
  static Future<void> resetPassword(String employeeId) async {
    if (employeeId.isEmpty) {
      throw ConductorAuthException('Employee ID is required for password reset');
    }
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock success - in real app, this would send reset email/SMS
  }
}

/// Result of conductor authentication operation
class ConductorAuthResult {
  /// Employee ID
  final String employeeId;
  
  /// Full name of the conductor
  final String fullName;
  
  /// Phone number
  final String phoneNumber;
  
  /// Whether the operation was successful
  final bool isSuccess;
  
  /// Error message if operation failed
  final String? errorMessage;
  
  const ConductorAuthResult({
    required this.employeeId,
    required this.fullName,
    required this.phoneNumber,
    this.isSuccess = true,
    this.errorMessage,
  });
  
  /// Creates a successful result
  factory ConductorAuthResult.success({
    required String employeeId,
    required String fullName,
    required String phoneNumber,
  }) {
    return ConductorAuthResult(
      employeeId: employeeId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      isSuccess: true,
    );
  }
  
  /// Creates a failed result
  factory ConductorAuthResult.failure(String errorMessage) {
    return ConductorAuthResult(
      employeeId: '',
      fullName: '',
      phoneNumber: '',
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
  
  @override
  String toString() {
    return 'ConductorAuthResult('
        'employeeId: $employeeId, '
        'fullName: $fullName, '
        'phoneNumber: $phoneNumber, '
        'isSuccess: $isSuccess, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Exception thrown during conductor authentication operations
class ConductorAuthException implements Exception {
  /// Error message
  final String message;
  
  /// Error code (optional)
  final String? code;
  
  const ConductorAuthException(this.message, [this.code]);
  
  @override
  String toString() {
    return code != null 
        ? 'ConductorAuthException($code): $message'
        : 'ConductorAuthException: $message';
  }
}