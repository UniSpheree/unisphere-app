import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/screens/login_screen.dart';
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
        '/logged-in': (_) => const Scaffold(body: Text('Logged In Page')),
        '/forgot-password': (_) => const Scaffold(body: Text('Forgot Password Page')),
        '/register': (_) => const Scaffold(body: Text('Register Page')),
      },
      home: child,
    );
  }

  Future<void> _setLargeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('LoginScreen Tests', () {
    testWidgets('Initial renders correctly', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      expect(find.text('Welcome to UniSphere'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Validation errors', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      
      // Empty
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Invalid format
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);

      // Non-university
      await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Please use your university email address'), findsOneWidget);

      // Non-UK
      await tester.enterText(find.byType(TextFormField).at(0), 'test@stanford.edu');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid UK university email'), findsOneWidget);
    });

    testWidgets('Password validation', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      final pw = find.byType(TextFormField).at(1);
      final btn = find.text('Login to Dashboard');

      await tester.enterText(pw, 'short');
      await tester.tap(btn);
      await tester.pumpAndSettle();
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);

      await tester.enterText(pw, 'NoNumber!');
      await tester.tap(btn);
      await tester.pumpAndSettle();
      expect(find.text('Password must contain at least one number'), findsOneWidget);

      await tester.enterText(pw, 'NoSpecial123');
      await tester.tap(btn);
      await tester.pumpAndSettle();
      expect(find.textContaining('special character'), findsOneWidget);
    });

    testWidgets('Successful login', (tester) async {
      await _setLargeView(tester);
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return http.Response(jsonEncode({'id': 1, 'email': 'test@oxford.ac.uk'}), 200);
        }
        return http.Response(jsonEncode([]), 200);
      });

      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@oxford.ac.uk');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      
      expect(find.text('Welcome back! Login successful.'), findsOneWidget);
      expect(find.text('Logged In Page'), findsOneWidget);
    });

    testWidgets('Failed login', (tester) async {
      await _setLargeView(tester);
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return http.Response('Unauthorized', 401);
        }
        return http.Response(jsonEncode([]), 200);
      });

      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@oxford.ac.uk');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      
      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('UI Toggles', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      
      // Visibility
      final pwField = find.descendant(of: find.byType(TextFormField).at(1), matching: find.byType(TextField));
      expect(tester.widget<TextField>(pwField).obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(pwField).obscureText, isFalse);
      
      // Checkbox
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('Navigation: Forgot Password', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('Forgot Password Page'), findsOneWidget);
    });

    testWidgets('Navigation: Register', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.tap(find.text('Register here'));
      await tester.pumpAndSettle();
      expect(find.text('Register Page'), findsOneWidget);
    });

    testWidgets('Navigation: Logo Pop', (tester) async {
      await _setLargeView(tester);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Go'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Loading state', (tester) async {
      await _setLargeView(tester);
      final completer = Completer<http.Response>();
      SqliteBackend().client = MockClient((request) async => completer.future);

      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@oxford.ac.uk');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pump(const Duration(milliseconds: 50));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(http.Response(jsonEncode({'id': 1}), 200));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Dispose check', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpWidget(_buildTestApp(const Scaffold()));
      // No crash means dispose worked
    });
  });
}

class ResponseCompleter {
  final _completer = Completer<http.Response>();
  Future<http.Response> get future => _completer.future;
  void complete(http.Response response) => _completer.complete(response);
}
