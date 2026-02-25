enum UserRole {
  passenger,
  driver,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.passenger:
        return 'passenger';
      case UserRole.driver:
        return 'driver';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.passenger:
        return 'Passenger';
      case UserRole.driver:
        return 'Conductor'; // Changed from 'Driver/Conductor' to 'Conductor'
    }
  }

  static UserRole? fromString(String? value) {
    switch (value) {
      case 'passenger':
        return UserRole.passenger;
      case 'driver':
        return UserRole.driver;
      default:
        return null;
    }
  }
}