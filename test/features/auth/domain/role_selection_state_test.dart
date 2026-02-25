import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/auth/domain/role_selection_state.dart';
import 'package:public_transport_tracker/features/auth/domain/user_role.dart';

void main() {
  group('RoleSelectionState', () {
    test('creates initial state correctly', () {
      const state = RoleSelectionState();
      
      expect(state.selectedRole, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isGuestMode, false);
      expect(state.isConfirmed, false);
    });

    test('creates initial state using factory', () {
      final state = RoleSelectionState.initial();
      
      expect(state.selectedRole, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isGuestMode, false);
      expect(state.isConfirmed, false);
    });

    test('creates loading state correctly', () {
      final state = RoleSelectionState.loading(selectedRole: UserRole.passenger);
      
      expect(state.selectedRole, UserRole.passenger);
      expect(state.isLoading, true);
      expect(state.error, isNull);
      expect(state.isConfirmed, false);
    });

    test('creates error state correctly', () {
      const errorMessage = 'Test error';
      final state = RoleSelectionState.error(errorMessage, selectedRole: UserRole.driver);
      
      expect(state.selectedRole, UserRole.driver);
      expect(state.isLoading, false);
      expect(state.error, errorMessage);
      expect(state.isConfirmed, false);
    });

    test('creates success state correctly', () {
      final state = RoleSelectionState.success(UserRole.passenger);
      
      expect(state.selectedRole, UserRole.passenger);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isConfirmed, true);
    });

    test('creates guest state correctly', () {
      final state = RoleSelectionState.guest();
      
      expect(state.selectedRole, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isGuestMode, true);
      expect(state.isConfirmed, false);
    });

    test('copyWith works correctly', () {
      const initialState = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
        error: 'Initial error',
      );

      final newState = initialState.copyWith(
        isLoading: true,
        clearError: true,
      );

      expect(newState.selectedRole, UserRole.passenger);
      expect(newState.isLoading, true);
      expect(newState.error, isNull);
    });

    test('copyWith clears selected role when requested', () {
      const initialState = RoleSelectionState(
        selectedRole: UserRole.driver,
      );

      final newState = initialState.copyWith(
        clearSelectedRole: true,
      );

      expect(newState.selectedRole, isNull);
    });

    test('hasSelectedRole getter works correctly', () {
      const stateWithRole = RoleSelectionState(selectedRole: UserRole.passenger);
      const stateWithoutRole = RoleSelectionState();

      expect(stateWithRole.hasSelectedRole, true);
      expect(stateWithoutRole.hasSelectedRole, false);
    });

    test('isSuccess getter works correctly', () {
      final successState = RoleSelectionState.success(UserRole.passenger);
      const loadingState = RoleSelectionState(isLoading: true);
      const errorState = RoleSelectionState(error: 'Error');
      const unconfirmedState = RoleSelectionState(selectedRole: UserRole.passenger);

      expect(successState.isSuccess, true);
      expect(loadingState.isSuccess, false);
      expect(errorState.isSuccess, false);
      expect(unconfirmedState.isSuccess, false);
    });

    test('hasError getter works correctly', () {
      const stateWithError = RoleSelectionState(error: 'Test error');
      const stateWithoutError = RoleSelectionState();

      expect(stateWithError.hasError, true);
      expect(stateWithoutError.hasError, false);
    });

    test('canProceed getter works correctly', () {
      const canProceedState = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
      );
      const loadingState = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: true,
      );
      const noRoleState = RoleSelectionState(isLoading: false);

      expect(canProceedState.canProceed, true);
      expect(loadingState.canProceed, false);
      expect(noRoleState.canProceed, false);
    });

    test('equality works correctly', () {
      const state1 = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
        error: null,
      );
      const state2 = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
        error: null,
      );
      const state3 = RoleSelectionState(
        selectedRole: UserRole.driver,
        isLoading: false,
        error: null,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('hashCode works correctly', () {
      const state1 = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
      );
      const state2 = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: false,
      );

      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('toString works correctly', () {
      const state = RoleSelectionState(
        selectedRole: UserRole.passenger,
        isLoading: true,
        error: 'Test error',
      );

      final stringRepresentation = state.toString();
      
      expect(stringRepresentation, contains('RoleSelectionState'));
      expect(stringRepresentation, contains('UserRole.passenger'));
      expect(stringRepresentation, contains('true'));
      expect(stringRepresentation, contains('Test error'));
    });
  });
}