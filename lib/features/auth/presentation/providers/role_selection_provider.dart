import 'package:flutter/foundation.dart';
import '../../domain/user_role.dart';
import '../../domain/role_selection_state.dart';

/// Provider for managing role selection state and operations
class RoleSelectionProvider with ChangeNotifier {
  RoleSelectionState _state = RoleSelectionState.initial();
  
  /// Current role selection state
  RoleSelectionState get state => _state;
  
  /// Currently selected role
  UserRole? get selectedRole => _state.selectedRole;
  
  /// Whether a role selection operation is in progress
  bool get isLoading => _state.isLoading;
  
  /// Current error message
  String? get error => _state.error;
  
  /// Whether the user is in guest mode
  bool get isGuestMode => _state.isGuestMode;
  
  /// Whether the role has been confirmed
  bool get isConfirmed => _state.isConfirmed;
  
  /// Whether a role is currently selected
  bool get hasSelectedRole => _state.hasSelectedRole;
  
  /// Whether the user can proceed with current selection
  bool get canProceed => _state.canProceed;
  
  /// Select a role
  void selectRole(UserRole role) {
    _updateState(_state.copyWith(
      selectedRole: role,
      clearError: true,
    ));
  }
  
  /// Clear the selected role
  void clearSelection() {
    _updateState(_state.copyWith(
      clearSelectedRole: true,
      clearError: true,
      isConfirmed: false,
    ));
  }
  
  /// Set loading state
  void setLoading(bool loading) {
    _updateState(_state.copyWith(
      isLoading: loading,
      clearError: loading, // Clear error when starting new operation
    ));
  }
  
  /// Set error state
  void setError(String error) {
    _updateState(_state.copyWith(
      error: error,
      isLoading: false,
    ));
  }
  
  /// Clear error
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }
  
  /// Confirm the selected role
  Future<void> confirmRole() async {
    if (!hasSelectedRole) {
      setError('Please select a role first');
      return;
    }
    
    setLoading(true);
    
    try {
      // Simulate role confirmation process
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateState(RoleSelectionState.success(_state.selectedRole!));
    } catch (e) {
      setError('Failed to confirm role: ${e.toString()}');
    }
  }
  
  /// Enable guest mode
  void enableGuestMode() {
    _updateState(RoleSelectionState.guest());
  }
  
  /// Disable guest mode and return to role selection
  void disableGuestMode() {
    _updateState(RoleSelectionState.initial());
  }
  
  /// Reset to initial state
  void reset() {
    _updateState(RoleSelectionState.initial());
  }
  
  /// Validate role selection
  String? validateSelection() {
    if (!hasSelectedRole) {
      return 'Please select a role to continue';
    }
    
    if (isLoading) {
      return 'Please wait while we process your selection';
    }
    
    return null; // No validation errors
  }
  
  /// Check if a specific role is selected
  bool isRoleSelected(UserRole role) {
    return selectedRole == role;
  }
  
  /// Get display name for selected role
  String? get selectedRoleDisplayName {
    return selectedRole?.displayName;
  }
  
  /// Update state and notify listeners
  void _updateState(RoleSelectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  
}