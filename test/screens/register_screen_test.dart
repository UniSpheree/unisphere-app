import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/register_screen.dart';
import 'package:unisphere_app/widgets/auth_text_field.dart';
import 'package:unisphere_app/utils/validators.dart';

void main() {
  group('validators', () {
    test('validateUniversityEmail - empty', () {
      expect(validateUniversityEmail(''), 'Email is required');
    });

    test('validateUniversityEmail - invalid format', () {
      expect(
        validateUniversityEmail('not-an-email'),
        'Enter a valid email address',
      );
      expect(validateUniversityEmail('a@b'), 'Enter a valid email address');
    });

    test('validateUniversityEmail - blocked domain', () {
      expect(
        validateUniversityEmail('user@gmail.com'),
        'Please use your university email address',
      );
    });

    test('validateUniversityEmail - non UK domain', () {
      expect(
        validateUniversityEmail('user@uni.edu'),
        'Enter a valid UK university email',
      );
    });

    test('validateUniversityEmail - valid .ac.uk', () {
      expect(validateUniversityEmail('user@oxford.ac.uk'), isNull);
    });

    test('validatePassword rules', () {
      expect(validatePassword(''), 'Password is required');
      expect(
        validatePassword('short1!'),
        'Password must be at least 8 characters',
      );
      expect(
        validatePassword('longpassword!'),
        'Password must contain at least one number',
      );
      expect(
        validatePassword('passw0rd'),
        'Password must contain at least one special character (!@#\u0024%^&*?_~-)',
      );
      expect(validatePassword('Goodpass1!'), isNull);
    });
  });

  group('AuthTextField widget', () {
    testWidgets('renders label and TextFormField', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Email',
              hintText: 'you@uni.ac.uk',
              prefixIcon: Icons.email_outlined,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('obscureText and suffix visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              suffixWidget: Icon(Icons.visibility),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tf = find.byType(TextFormField);
      expect(tf, findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  test('RegisterScreen can be instantiated', () {
    final widget = const RegisterScreen();
    expect(widget, isNotNull);
    expect(widget, isA<RegisterScreen>());
  });
}
