import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/features/auth/domain/conductor_auth_data.dart';

void main() {
  group('ConductorAuthData', () {
    test('creates login instance correctly', () {
      const authData = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      expect(authData.employeeId, 'EMP123');
      expect(authData.password, 'password123');
      expect(authData.isLogin, true);
      expect(authData.fullName, isNull);
      expect(authData.phoneNumber, isNull);
    });

    test('creates signup instance correctly', () {
      const authData = ConductorAuthData(
        fullName: 'John Doe',
        employeeId: 'EMP123',
        phoneNumber: '+1234567890',
        password: 'password123',
        isLogin: false,
      );

      expect(authData.fullName, 'John Doe');
      expect(authData.employeeId, 'EMP123');
      expect(authData.phoneNumber, '+1234567890');
      expect(authData.password, 'password123');
      expect(authData.isLogin, false);
    });

    test('creates login instance using factory', () {
      final authData = ConductorAuthData.forLogin();

      expect(authData.employeeId, '');
      expect(authData.password, '');
      expect(authData.isLogin, true);
      expect(authData.fullName, isNull);
      expect(authData.phoneNumber, isNull);
    });

    test('creates signup instance using factory', () {
      final authData = ConductorAuthData.forSignup();

      expect(authData.fullName, '');
      expect(authData.employeeId, '');
      expect(authData.phoneNumber, '');
      expect(authData.password, '');
      expect(authData.isLogin, false);
    });

    test('copyWith works correctly', () {
      const original = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      final updated = original.copyWith(
        fullName: 'John Doe',
        phoneNumber: '+1234567890',
        isLogin: false,
      );

      expect(updated.fullName, 'John Doe');
      expect(updated.employeeId, 'EMP123');
      expect(updated.phoneNumber, '+1234567890');
      expect(updated.password, 'password123');
      expect(updated.isLogin, false);
    });

    test('copyWith clears fields when requested', () {
      const original = ConductorAuthData(
        fullName: 'John Doe',
        employeeId: 'EMP123',
        phoneNumber: '+1234567890',
        password: 'password123',
        isLogin: false,
      );

      final updated = original.copyWith(
        clearFullName: true,
        clearPhoneNumber: true,
      );

      expect(updated.fullName, isNull);
      expect(updated.phoneNumber, isNull);
      expect(updated.employeeId, 'EMP123');
      expect(updated.password, 'password123');
    });

    group('validation', () {
      test('validates login data correctly', () {
        const validLogin = ConductorAuthData(
          employeeId: 'EMP123',
          password: 'password123',
          isLogin: true,
        );

        final errors = validLogin.validate();
        expect(errors, isEmpty);
        expect(validLogin.isValid, true);
      });

      test('validates signup data correctly', () {
        const validSignup = ConductorAuthData(
          fullName: 'John Doe',
          employeeId: 'EMP123',
          phoneNumber: '+1234567890',
          password: 'password123',
          isLogin: false,
        );

        final errors = validSignup.validate();
        expect(errors, isEmpty);
        expect(validSignup.isValid, true);
      });

      test('detects empty employee ID', () {
        const invalidData = ConductorAuthData(
          employeeId: '',
          password: 'password123',
          isLogin: true,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Employee ID is required'));
        expect(invalidData.isValid, false);
      });

      test('detects short employee ID', () {
        const invalidData = ConductorAuthData(
          employeeId: 'AB',
          password: 'password123',
          isLogin: true,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Employee ID must be at least 3 characters'));
      });

      test('detects empty password', () {
        const invalidData = ConductorAuthData(
          employeeId: 'EMP123',
          password: '',
          isLogin: true,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Password is required'));
      });

      test('detects short password', () {
        const invalidData = ConductorAuthData(
          employeeId: 'EMP123',
          password: '123',
          isLogin: true,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Password must be at least 6 characters'));
      });

      test('detects weak password', () {
        const invalidData = ConductorAuthData(
          employeeId: 'EMP123',
          password: 'password',
          isLogin: true,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Password must contain at least one letter and one number'));
      });

      test('validates signup-specific fields', () {
        const invalidSignup = ConductorAuthData(
          fullName: '',
          employeeId: 'EMP123',
          phoneNumber: '',
          password: 'password123',
          isLogin: false,
        );

        final errors = invalidSignup.validate();
        expect(errors, contains('Full name is required for signup'));
        expect(errors, contains('Phone number is required for signup'));
      });

      test('detects invalid phone number', () {
        const invalidData = ConductorAuthData(
          fullName: 'John Doe',
          employeeId: 'EMP123',
          phoneNumber: '123',
          password: 'password123',
          isLogin: false,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Please enter a valid phone number'));
      });

      test('detects invalid name characters', () {
        const invalidData = ConductorAuthData(
          fullName: 'John123',
          employeeId: 'EMP123',
          phoneNumber: '+1234567890',
          password: 'password123',
          isLogin: false,
        );

        final errors = invalidData.validate();
        expect(errors, contains('Full name contains invalid characters'));
      });
    });

    test('isComplete works correctly for login', () {
      const completeLogin = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      const incompleteLogin = ConductorAuthData(
        employeeId: '',
        password: 'password123',
        isLogin: true,
      );

      expect(completeLogin.isComplete, true);
      expect(incompleteLogin.isComplete, false);
    });

    test('isComplete works correctly for signup', () {
      const completeSignup = ConductorAuthData(
        fullName: 'John Doe',
        employeeId: 'EMP123',
        phoneNumber: '+1234567890',
        password: 'password123',
        isLogin: false,
      );

      const incompleteSignup = ConductorAuthData(
        fullName: '',
        employeeId: 'EMP123',
        phoneNumber: '+1234567890',
        password: 'password123',
        isLogin: false,
      );

      expect(completeSignup.isComplete, true);
      expect(incompleteSignup.isComplete, false);
    });

    test('toMap works correctly for login', () {
      const loginData = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      final map = loginData.toMap();

      expect(map['employeeId'], 'EMP123');
      expect(map['password'], 'password123');
      expect(map['isLogin'], true);
      expect(map.containsKey('fullName'), false);
      expect(map.containsKey('phoneNumber'), false);
    });

    test('toMap works correctly for signup', () {
      const signupData = ConductorAuthData(
        fullName: 'John Doe',
        employeeId: 'EMP123',
        phoneNumber: '+1234567890',
        password: 'password123',
        isLogin: false,
      );

      final map = signupData.toMap();

      expect(map['fullName'], 'John Doe');
      expect(map['employeeId'], 'EMP123');
      expect(map['phoneNumber'], '+1234567890');
      expect(map['password'], 'password123');
      expect(map['isLogin'], false);
    });

    test('fromMap works correctly', () {
      final map = {
        'fullName': 'John Doe',
        'employeeId': 'EMP123',
        'phoneNumber': '+1234567890',
        'password': 'password123',
        'isLogin': false,
      };

      final authData = ConductorAuthData.fromMap(map);

      expect(authData.fullName, 'John Doe');
      expect(authData.employeeId, 'EMP123');
      expect(authData.phoneNumber, '+1234567890');
      expect(authData.password, 'password123');
      expect(authData.isLogin, false);
    });

    test('getFieldError works correctly', () {
      const invalidData = ConductorAuthData(
        employeeId: '',
        password: '123',
        isLogin: true,
      );

      expect(invalidData.getFieldError('employeeId'), contains('Employee ID is required'));
      expect(invalidData.getFieldError('password'), contains('Password must be at least 6 characters'));
      expect(invalidData.getFieldError('fullName'), isNull);
    });

    test('equality works correctly', () {
      const data1 = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      const data2 = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      const data3 = ConductorAuthData(
        employeeId: 'EMP456',
        password: 'password123',
        isLogin: true,
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });

    test('toString hides password', () {
      const authData = ConductorAuthData(
        employeeId: 'EMP123',
        password: 'password123',
        isLogin: true,
      );

      final stringRepresentation = authData.toString();

      expect(stringRepresentation, contains('EMP123'));
      expect(stringRepresentation, contains('[HIDDEN]'));
      expect(stringRepresentation, isNot(contains('password123')));
    });
  });
}