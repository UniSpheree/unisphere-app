import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/screens/forgot_password_screen.dart';
import 'package:unisphere_app/widgets/auth_text_field.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SqliteBackend().logout();
    
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) return;
      if (originalOnError != null) originalOnError(details);
    };
  });

  Widget _buildTestApp(Widget child) {
    return MaterialApp(
      routes: {
        '/login': (_) => Scaffold(appBar: AppBar(), body: const Text('Login Screen')),
        '/landing': (_) => Scaffold(appBar: AppBar(), body: const Text('Landing Screen')),
      },
      home: child,
    );
  }

  Future<void> _pumpApp(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_buildTestApp(child));
    await tester.pumpAndSettle();
  }

  group('ForgotPasswordScreen Isolated Tests', () {
    testWidgets('Initial Renders', (tester) async {
      await _pumpApp(tester, const ForgotPasswordScreen());
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Step 1: Validation', (tester) async {
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'bad@gmail.com');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('Please use your university email address'), findsOneWidget);
    });

    testWidgets('Step 1: Email Not Found', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': false}), 200));
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'missing@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('No account found with this email.'), findsOneWidget);
    });

    testWidgets('Step 2: Resend Code', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': true}), 200));
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'test@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Code'));
      await tester.pump();
      expect(find.textContaining('Code resent'), findsOneWidget);
    });

    testWidgets('Step 2: Invalid Code', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': true}), 200));
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'test@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '000000');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(find.text('Invalid code. Please try again.'), findsOneWidget);
    });

    testWidgets('Step 3: Password Reset Success', (tester) async {
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path == '/auth/forgot-password') return http.Response(jsonEncode({'exists': true}), 200);
        return http.Response('Success', 200);
      });
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'success@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Password reset successfully! Please log in.'), findsOneWidget);
    });

    testWidgets('Step 3: Password Reset Failure', (tester) async {
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path == '/auth/forgot-password') return http.Response(jsonEncode({'exists': true}), 200);
        return http.Response('Error', 400);
      });
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'fail@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Failed to reset password. Please try again.'), findsOneWidget);
    });

    testWidgets('Navigation: Logo and Back Buttons', (tester) async {
      await _pumpApp(tester, const ForgotPasswordScreen());
      
      // Back button
      await tester.tap(find.text('Back to Login').first);
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);

      // Logo
      await _pumpApp(tester, const ForgotPasswordScreen());
      final logo = find.byType(Image).first;
      final logoGesture = tester.widget<GestureDetector>(find.ancestor(of: logo, matching: find.byType(GestureDetector)).first);
      logoGesture.onTap!();
      await tester.pumpAndSettle();
      expect(find.text('Landing Screen'), findsOneWidget);
    });

    testWidgets('Misc: Toggles and Mismatch', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': true}), 200));
      await _pumpApp(tester, const ForgotPasswordScreen());
      await tester.enterText(find.byType(TextFormField), 'test@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      final visibilityIcons = find.byIcon(Icons.visibility_outlined);
      if (visibilityIcons.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcons.at(0));
        await tester.pump();
      }

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Mismatch123!');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
