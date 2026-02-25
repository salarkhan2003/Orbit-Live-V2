import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/auth/presentation/providers/role_selection_provider.dart';
import 'package:public_transport_tracker/features/auth/domain/user_role.dart';
import 'package:public_transport_tracker/features/auth/domain/role_selection_state.dart';

void main() {
  group('RoleSelectionProvider', () {
    late RoleSelectionProvider provider;

    setUp(() {
      provider = RoleSelectionProvider();
    });

    test('initializes with initial state', () {
      expect(provider.selectedRole, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.isGuestMode, false);
      expect(provider.isConfirmed, false);
      expect(provider.hasSelectedRole, false);
      expect(provider.canProceed, false);
    });

    test('selectRole updates selected role', () {
      provider.selectRole(UserRole.passenger);

      expect(provider.selectedRole, UserRole.passenger);
      expect(provider.hasSelectedRole, true);
      expect(provider.canProceed, true);
      expect(provider.error, isNull);
    });

    test('selectRole clears error', () {
      provider.setError('Test error');
      expect(provider.error, 'Test error');

      provider.selectRole(UserRole.passenger);
      expect(provider.error, isNull);
    });

    test('clearSelection removes selected role', () {
      provider.selectRole(UserRole.passenger);
      expect(provider.selectedRole, UserRole.passenger);

      provider.clearSelection();
      expect(provider.selectedRole, isNull);
      expect(provider.hasSelectedRole, false);
      expect(provider.canProceed, false);
      expect(provider.isConfirmed, false);
    });

    test('setLoading updates loading state', () {
      provider.setLoading(true);
      expect(provider.isLoading, true);
      expect(provider.canProceed, false);

      provider.setLoading(false);
      expect(provider.isLoading, false);
    });

    test('setLoading clears error when loading starts', () {
      provider.setError('Test error');
      expect(provider.error, 'Test error');

      provider.setLoading(true);
      expect(provider.error, isNull);
    });

    test('setError updates error state', () {
      const errorMessage = 'Test error';
      provider.setError(errorMessage);

      expect(provider.error, errorMessage);
      expect(provider.isLoading, false);
    });

    test('clearError removes error', () {
      provider.setError('Test error');
      expect(provider.error, 'Test error');

      provider.clearError();
      expect(provider.error, isNull);
    });

    test('confirmRole succeeds with selected role', () async {
      provider.selectRole(UserRole.passenger);

      await provider.confirmRole();

      expect(provider.isConfirmed, true);
      expect(provider.selectedRole, UserRole.passenger);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('confirmRole fails without selected role', () async {
      await provider.confirmRole();

      expect(provider.error, 'Please select a role first');
      expect(provider.isConfirmed, false);
      expect(provider.isLoading, false);
    });

    test('enableGuestMode sets guest mode', () {
      provider.enableGuestMode();

      expect(provider.isGuestMode, true);
      expect(provider.isLoading, false);
    });

    test('disableGuestMode clears guest mode', () {
      provider.enableGuestMode();
      expect(provider.isGuestMode, true);

      provider.disableGuestMode();
      expect(provider.isGuestMode, false);
    });

    test('reset returns to initial state', () {
      provider.selectRole(UserRole.passenger);
      provider.setError('Test error');
      provider.setLoading(true);

      provider.reset();

      expect(provider.selectedRole, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.isGuestMode, false);
      expect(provider.isConfirmed, false);
    });

    test('validateSelection returns null for valid selection', () {
      provider.selectRole(UserRole.passenger);

      final validation = provider.validateSelection();
      expect(validation, isNull);
    });

    test('validateSelection returns error for no selection', () {
      final validation = provider.validateSelection();
      expect(validation, 'Please select a role to continue');
    });

    test('validateSelection returns error when loading', () {
      provider.selectRole(UserRole.passenger);
      provider.setLoading(true);

      final validation = provider.validateSelection();
      expect(validation, 'Please wait while we process your selection');
    });

    test('isRoleSelected works correctly', () {
      expect(provider.isRoleSelected(UserRole.passenger), false);

      provider.selectRole(UserRole.passenger);
      expect(provider.isRoleSelected(UserRole.passenger), true);
      expect(provider.isRoleSelected(UserRole.driver), false);
    });

    test('selectedRoleDisplayName returns correct display name', () {
      expect(provider.selectedRoleDisplayName, isNull);

      provider.selectRole(UserRole.passenger);
      expect(provider.selectedRoleDisplayName, UserRole.passenger.displayName);

      provider.selectRole(UserRole.driver);
      expect(provider.selectedRoleDisplayName, UserRole.driver.displayName);
    });

    test('state getter returns current state', () {
      final initialState = provider.state;
      expect(initialState.selectedRole, isNull);
      expect(initialState.isLoading, false);

      provider.selectRole(UserRole.passenger);
      final updatedState = provider.state;
      expect(updatedState.selectedRole, UserRole.passenger);
    });

    group('state changes trigger notifications', () {
      test('selectRole triggers notification', () {
        bool notified = false;
        provider.addListener(() => notified = true);

        provider.selectRole(UserRole.passenger);
        expect(notified, true);
      });

      test('setLoading triggers notification', () {
        bool notified = false;
        provider.addListener(() => notified = true);

        provider.setLoading(true);
        expect(notified, true);
      });

      test('setError triggers notification', () {
        bool notified = false;
        provider.addListener(() => notified = true);

        provider.setError('Test error');
        expect(notified, true);
      });

      test('enableGuestMode triggers notification', () {
        bool notified = false;
        provider.addListener(() => notified = true);

        provider.enableGuestMode();
        expect(notified, true);
      });
    });

    test('does not notify when state is unchanged', () {
      provider.selectRole(UserRole.passenger);
      
      bool notified = false;
      provider.addListener(() => notified = true);

      // Setting the same role should not trigger notification
      provider.selectRole(UserRole.passenger);
      expect(notified, false);
    });
  });
}