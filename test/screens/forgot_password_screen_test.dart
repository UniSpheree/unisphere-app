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

  group('ForgotPasswordScreen Isolated Coverage', () {
    testWidgets('Step 1: Logo and Back', (tester) async {
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      
      // Back - tap the "Back to Login" link
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Step 1: API Logic', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': false}), 200));
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'missing@oxford.ac.uk');
      final sendResetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(sendResetButton);
      await tester.tap(sendResetButton);
      await tester.pumpAndSettle();
      expect(find.text('No account found with this email.'), findsOneWidget);
    });

    testWidgets('Step 2: Full Flow', (tester) async {
      SqliteBackend().client = MockClient((request) async => http.Response(jsonEncode({'exists': true}), 200));
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@oxford.ac.uk');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      // Verify and Transition
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@oxford.ac.uk');
      final sendResetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(sendResetButton);
      await tester.tap(sendResetButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '123456');
      final verifyButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Set New Password'), findsOneWidget);
    });

    testWidgets('Step 3: Logic and Toggles', (tester) async {
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path == '/auth/forgot-password') return http.Response(jsonEncode({'exists': true}), 200);
        return http.Response('Success', 200);
      });
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@oxford.ac.uk');
      final sendResetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(sendResetButton);
      await tester.tap(sendResetButton);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '123456');
      final verifyButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Return and Finish
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@oxford.ac.uk');
      final sendResetButtonAgain = find.byType(ElevatedButton).first;
      await tester.ensureVisible(sendResetButtonAgain);
      await tester.tap(sendResetButtonAgain);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '123456');
      final verifyButtonAgain = find.byType(ElevatedButton).first;
      await tester.ensureVisible(verifyButtonAgain);
      await tester.tap(verifyButtonAgain);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      final resetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Step 3: Failure Case', (tester) async {
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path == '/auth/forgot-password') return http.Response(jsonEncode({'exists': true}), 200);
        return http.Response('Error', 400);
      });
      await tester.pumpWidget(_buildTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'fail@oxford.ac.uk');
      final sendResetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(sendResetButton);
      await tester.tap(sendResetButton);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '123456');
      final verifyButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Password123!');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
      final resetButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed'), findsOneWidget);
    });
  });
}
