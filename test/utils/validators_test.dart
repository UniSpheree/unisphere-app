import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/validators.dart';

void main() {
  group('validateUniversityEmail', () {
    test('rejects null or empty', () {
      expect(validateUniversityEmail(null), 'Email is required');
      expect(validateUniversityEmail('   '), 'Email is required');
      expect(validateUniversityEmail(''), 'Email is required');
    });

    test('rejects malformed emails', () {
      expect(validateUniversityEmail('no-at-symbol'), 'Enter a valid email address');
      expect(validateUniversityEmail('@domain.com'), 'Enter a valid email address');
      expect(validateUniversityEmail('local@invalid'), 'Enter a valid email address');
      expect(validateUniversityEmail('local@'), 'Enter a valid email address');
      expect(validateUniversityEmail('@'), 'Enter a valid email address');
    });

    test('rejects blocked consumer domains', () {
      expect(validateUniversityEmail('user@gmail.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@googlemail.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@yahoo.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@outlook.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@hotmail.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@icloud.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@aol.com'), 'Please use your university email address');
      expect(validateUniversityEmail('user@protonmail.com'), 'Please use your university email address');
    });

    test('accepts valid UK university emails', () {
      expect(validateUniversityEmail('student@oxford.ac.uk'), isNull);
      expect(validateUniversityEmail(' STUDENT@CAMBRIDGE.AC.UK '), isNull);
      expect(validateUniversityEmail('user@imperial.ac.uk'), isNull);
      expect(validateUniversityEmail('alice@lse.ac.uk'), isNull);
      expect(validateUniversityEmail('john.doe@manchester.ac.uk'), isNull);
    });

    test('rejects non-UK institutional domains', () {
      expect(validateUniversityEmail('user@university.edu'), 'Enter a valid UK university email');
      expect(validateUniversityEmail('user@university.com'), 'Enter a valid UK university email');
      expect(validateUniversityEmail('user@university.org'), 'Enter a valid UK university email');
    });

    test('handles multiple @ symbols', () {
      expect(validateUniversityEmail('user@@example.ac.uk'), 'Enter a valid email address');
      expect(validateUniversityEmail('user@middle@example.ac.uk'), 'Enter a valid email address');
    });

    test('case insensitivity for domain', () {
      expect(validateUniversityEmail('student@OXFORD.AC.UK'), isNull);
      expect(validateUniversityEmail('student@Oxford.Ac.Uk'), isNull);
    });

    test('rejects domains without dots', () {
      expect(validateUniversityEmail('user@localhost'), 'Enter a valid email address');
    });

    test('accepts emails with special characters in local part', () {
      expect(validateUniversityEmail('john.doe@oxford.ac.uk'), isNull);
      expect(validateUniversityEmail('alice-smith@cambridge.ac.uk'), isNull);
    });

    test('rejects blocked domains with country codes', () {
      expect(validateUniversityEmail('user@yahoo.co.uk'), 'Please use your university email address');
      expect(validateUniversityEmail('user@hotmail.co.uk'), 'Please use your university email address');
    });
  });

  group('validatePassword', () {
    test('rejects empty and short values', () {
      expect(validatePassword(null), 'Password is required');
      expect(validatePassword(''), 'Password is required');
      expect(validatePassword('Ab1!'), 'Password must be at least 8 characters');
      expect(validatePassword('A1!'), 'Password must be at least 8 characters');
    });

    test('requires at least one digit', () {
      expect(validatePassword('Password!'), 'Password must contain at least one number');
      expect(validatePassword('Abcdefgh!'), 'Password must contain at least one number');
      expect(validatePassword('ABCDEFGH!'), 'Password must contain at least one number');
    });

    test('requires at least one special character', () {
      expect(validatePassword('Password1'), 'Password must contain at least one special character (!@#\$%^&*?_~-)');
      expect(validatePassword('Password12'), 'Password must contain at least one special character (!@#\$%^&*?_~-)');
    });

    test('accepts valid passwords with various special chars', () {
      expect(validatePassword('Abcdef1!'), isNull);
      expect(validatePassword('Complex_pwd-9'), isNull);
      expect(validatePassword('Test@Pass1'), isNull);
      expect(validatePassword('Secure#Pwd2'), isNull);
      expect(validatePassword('ValidPass\$5'), isNull);
      expect(validatePassword('StrongPass%8'), isNull);
      expect(validatePassword('MyPass^90'), isNull);
      expect(validatePassword('Another&Pass1'), isNull);
      expect(validatePassword('SomethingPass*2'), isNull);
      expect(validatePassword('Question?Pass3'), isNull);
      expect(validatePassword('Underscore_Pass4'), isNull);
      expect(validatePassword('Tilde~Pass5'), isNull);
      expect(validatePassword('Dash-Pass6'), isNull);
    });

    test('accepts passwords with minimum length of 8', () {
      expect(validatePassword('Pwd12345!'), isNull);
      expect(validatePassword('Min1@Pass'), isNull);
    });

    test('accepts long passwords', () {
      expect(validatePassword('VeryLongPasswordWith123AndSpecial!'), isNull);
    });

    test('case sensitivity is not enforced', () {
      expect(validatePassword('password123!'), isNull);
      expect(validatePassword('PASSWORD123!'), isNull);
      expect(validatePassword('PaSSwoRd123!'), isNull);
    });

    test('rejects passwords missing digit even with special chars', () {
      expect(validatePassword('Abcdefgh!@#'), 'Password must contain at least one number');
    });

    test('rejects passwords with only special chars and letters', () {
      expect(validatePassword('Abcdefgh!'), 'Password must contain at least one number');
    });

    test('whitespace does not count as satisfying requirements', () {
      expect(validatePassword('Password !'), 'Password must contain at least one number');
    });
  });
}
