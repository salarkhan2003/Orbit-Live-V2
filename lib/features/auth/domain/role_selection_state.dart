import 'user_role.dart';

/// State class for managing role selection
class RoleSelectionState {
  /// The currently selected role
  final UserRole? selectedRole;
  
  /// Whether a role selection operation is in progress
  final bool isLoading;
  
  /// Error message if role selection failed
  final String? error;
  
  /// Whether the user is in guest mode
  final bool isGuestMode;
  
  /// Whether the role has been confirmed/submitted
  final bool isConfirmed;
  
  const RoleSelectionState({
    this.selectedRole,
    this.isLoading = false,
    this.error,
    this.isGuestMode = false,
    this.isConfirmed = false,
  });
  
  /// Creates a copy of this state with updated values
  RoleSelectionState copyWith({
    UserRole? selectedRole,
    bool? isLoading,
    String? error,
    bool? isGuestMode,
    bool? isConfirmed,
    bool clearError = false,
    bool clearSelectedRole = false,
  }) {
    return RoleSelectionState(
      selectedRole: clearSelectedRole ? null : selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
  
  /// Creates an initial/empty state
  factory RoleSelectionState.initial() {
    return const RoleSelectionState();
  }
  
  /// Creates a loading state
  factory RoleSelectionState.loading({UserRole? selectedRole}) {
    return RoleSelectionState(
      selectedRole: selectedRole,
      isLoading: true,
    );
  }
  
  /// Creates an error state
  factory RoleSelectionState.error(String error, {UserRole? selectedRole}) {
    return RoleSelectionState(
      selectedRole: selectedRole,
      error: error,
      isLoading: false,
    );
  }
  
  /// Creates a success state with confirmed role
  factory RoleSelectionState.success(UserRole role) {
    return RoleSelectionState(
      selectedRole: role,
      isConfirmed: true,
      isLoading: false,
    );
  }
  
  /// Creates a guest mode state
  factory RoleSelectionState.guest() {
    return const RoleSelectionState(
      isGuestMode: true,
      isLoading: false,
    );
  }
  
  /// Whether a role is currently selected
  bool get hasSelectedRole => selectedRole != null;
  
  /// Whether the state represents a successful operation
  bool get isSuccess => !isLoading && error == null && isConfirmed;
  
  /// Whether the state has an error
  bool get hasError => error != null;
  
  /// Whether the user can proceed with the current selection
  bool get canProceed => hasSelectedRole && !isLoading;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RoleSelectionState &&
        other.selectedRole == selectedRole &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isGuestMode == isGuestMode &&
        other.isConfirmed == isConfirmed;
  }
  
  @override
  int get hashCode {
    return selectedRole.hashCode ^
        isLoading.hashCode ^
        error.hashCode ^
        isGuestMode.hashCode ^
        isConfirmed.hashCode;
  }
  
  @override
  String toString() {
    return 'RoleSelectionState('
        'selectedRole: $selectedRole, '
        'isLoading: $isLoading, '
        'error: $error, '
        'isGuestMode: $isGuestMode, '
        'isConfirmed: $isConfirmed'
        ')';
  }
}