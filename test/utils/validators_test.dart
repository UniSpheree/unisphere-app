import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/validators.dart';

void main() {
  group('validateUniversityEmail', () {
    test('rejects null or empty', () {
      expect(validateUniversityEmail(null), 'Email is required');
      expect(validateUniversityEmail('   '), 'Email is required');
    });

    test('rejects malformed emails', () {
      expect(validateUniversityEmail('no-at-symbol'), 'Enter a valid email address');
      expect(validateUniversityEmail('@domain.com'), 'Enter a valid email address');
      expect(validateUniversityEmail('local@invalid'), 'Enter a valid email address');
    });

    test('rejects blocked consumer domains', () {
      expect(validateUniversityEmail('user@gmail.com'), 'Please use your university email address');
    });

    test('accepts valid UK university emails', () {
      expect(validateUniversityEmail('student@oxford.ac.uk'), isNull);
      expect(validateUniversityEmail(' STUDENT@CAMBRIDGE.AC.UK '), isNull);
    });

    test('rejects non-UK institutional domains', () {
      expect(validateUniversityEmail('user@university.edu'), 'Enter a valid UK university email');
    });
  });

  group('validatePassword', () {
    test('rejects empty and short values', () {
      expect(validatePassword(null), 'Password is required');
      expect(validatePassword(''), 'Password is required');
      expect(validatePassword('Ab1!'), 'Password must be at least 8 characters');
    });

    test('requires a digit and special char', () {
      expect(validatePassword('Password!'), 'Password must contain at least one number');
      expect(validatePassword('Password1'), 'Password must contain at least one special character (!@#\$%^&*?_~-)');
    });

    test('accepts a valid password', () {
      expect(validatePassword('Abcdef1!'), isNull);
      expect(validatePassword('Complex_pwd-9'), isNull);
    });
  });
}
