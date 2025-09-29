/// Data model for conductor authentication form data
class ConductorAuthData {
  /// Full name of the conductor (required for signup)
  final String? fullName;
  
  /// Employee ID (required for both login and signup)
  final String employeeId;
  
  /// Phone number (required for signup)
  final String? phoneNumber;
  
  /// Password (required for both login and signup)
  final String password;
  
  /// Whether this is for login (true) or signup (false)
  final bool isLogin;
  
  const ConductorAuthData({
    this.fullName,
    required this.employeeId,
    this.phoneNumber,
    required this.password,
    this.isLogin = true,
  });
  
  /// Creates a copy of this data with updated values
  ConductorAuthData copyWith({
    String? fullName,
    String? employeeId,
    String? phoneNumber,
    String? password,
    bool? isLogin,
    bool clearFullName = false,
    bool clearPhoneNumber = false,
  }) {
    return ConductorAuthData(
      fullName: clearFullName ? null : fullName ?? this.fullName,
      employeeId: employeeId ?? this.employeeId,
      phoneNumber: clearPhoneNumber ? null : phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      isLogin: isLogin ?? this.isLogin,
    );
  }
  
  /// Creates an empty instance for login
  factory ConductorAuthData.forLogin() {
    return const ConductorAuthData(
      employeeId: '',
      password: '',
      isLogin: true,
    );
  }
  
  /// Creates an empty instance for signup
  factory ConductorAuthData.forSignup() {
    return const ConductorAuthData(
      fullName: '',
      employeeId: '',
      phoneNumber: '',
      password: '',
      isLogin: false,
    );
  }
  
  /// Validates the conductor credentials
  List<String> validate() {
    final errors = <String>[];
    
    // Employee ID validation
    if (employeeId.isEmpty) {
      errors.add('Employee ID is required');
    } else if (employeeId.length < 3) {
      errors.add('Employee ID must be at least 3 characters');
    } else if (!_isValidEmployeeId(employeeId)) {
      errors.add('Employee ID format is invalid');
    }
    
    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters');
    } else if (!_isValidPassword(password)) {
      errors.add('Password must contain at least one letter and one number');
    }
    
    // Signup-specific validations
    if (!isLogin) {
      // Full name validation
      if (fullName == null || fullName!.isEmpty) {
        errors.add('Full name is required for signup');
      } else if (fullName!.length < 2) {
        errors.add('Full name must be at least 2 characters');
      } else if (!_isValidName(fullName!)) {
        errors.add('Full name contains invalid characters');
      }
      
      // Phone number validation
      if (phoneNumber == null || phoneNumber!.isEmpty) {
        errors.add('Phone number is required for signup');
      } else if (!_isValidPhoneNumber(phoneNumber!)) {
        errors.add('Please enter a valid phone number');
      }
    }
    
    return errors;
  }
  
  /// Checks if the data is valid
  bool get isValid => validate().isEmpty;
  
  /// Checks if all required fields are filled
  bool get isComplete {
    if (employeeId.isEmpty || password.isEmpty) {
      return false;
    }
    
    if (!isLogin) {
      return fullName?.isNotEmpty == true && phoneNumber?.isNotEmpty == true;
    }
    
    return true;
  }
  
  /// Converts to a map for API calls
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'employeeId': employeeId,
      'password': password,
      'isLogin': isLogin,
    };
    
    if (!isLogin) {
      map['fullName'] = fullName;
      map['phoneNumber'] = phoneNumber;
    }
    
    return map;
  }
  
  /// Creates an instance from a map
  factory ConductorAuthData.fromMap(Map<String, dynamic> map) {
    return ConductorAuthData(
      fullName: map['fullName'],
      employeeId: map['employeeId'] ?? '',
      phoneNumber: map['phoneNumber'],
      password: map['password'] ?? '',
      isLogin: map['isLogin'] ?? true,
    );
  }
  
  /// Validates employee ID format
  bool _isValidEmployeeId(String employeeId) {
    // Employee ID should be alphanumeric and may contain hyphens or underscores
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return regex.hasMatch(employeeId);
  }
  
  /// Validates password strength
  bool _isValidPassword(String password) {
    // Password should contain at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }
  
  /// Validates full name format
  bool _isValidName(String name) {
    // Name should only contain letters, spaces, hyphens, and apostrophes
    final regex = RegExp(r"^[a-zA-Z\s\-']+$");
    return regex.hasMatch(name);
  }
  
  /// Validates phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check if it's a valid length (10-15 digits)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return false;
    }
    
    // Basic format validation
    final regex = RegExp(r'^[\+]?[0-9\s\-\(\)]+$');
    return regex.hasMatch(phoneNumber);
  }
  
  /// Gets validation error for a specific field
  String? getFieldError(String fieldName) {
    final errors = validate();
    
    switch (fieldName.toLowerCase()) {
      case 'employeeid':
        return errors.firstWhere(
          (error) => error.toLowerCase().contains('employee id'),
          orElse: () => '',
        ).isEmpty ? null : errors.firstWhere(
          (error) => error.toLowerCase().contains('employee id'),
        );
      case 'password':
        return errors.firstWhere(
          (error) => error.toLowerCase().contains('password'),
          orElse: () => '',
        ).isEmpty ? null : errors.firstWhere(
          (error) => error.toLowerCase().contains('password'),
        );
      case 'fullname':
        return errors.firstWhere(
          (error) => error.toLowerCase().contains('full name'),
          orElse: () => '',
        ).isEmpty ? null : errors.firstWhere(
          (error) => error.toLowerCase().contains('full name'),
        );
      case 'phonenumber':
        return errors.firstWhere(
          (error) => error.toLowerCase().contains('phone'),
          orElse: () => '',
        ).isEmpty ? null : errors.firstWhere(
          (error) => error.toLowerCase().contains('phone'),
        );
      default:
        return null;
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ConductorAuthData &&
        other.fullName == fullName &&
        other.employeeId == employeeId &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.isLogin == isLogin;
  }
  
  @override
  int get hashCode {
    return fullName.hashCode ^
        employeeId.hashCode ^
        phoneNumber.hashCode ^
        password.hashCode ^
        isLogin.hashCode;
  }
  
  @override
  String toString() {
    return 'ConductorAuthData('
        'fullName: $fullName, '
        'employeeId: $employeeId, '
        'phoneNumber: $phoneNumber, '
        'password: [HIDDEN], '
        'isLogin: $isLogin'
        ')';
  }
}