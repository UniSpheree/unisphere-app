import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/screens/login_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}

void main() {
  late MockSqliteBackend mockBackend;

  setUp(() {
    mockBackend = MockSqliteBackend();
    SqliteBackend.instance = mockBackend;
    registerFallbackValue('');
  });

  Widget buildApp() {
    return MaterialApp(
      routes: {
        '/logged-in': (_) => const Scaffold(body: Text('Dashboard')),
        '/forgot-password': (_) => const Scaffold(body: Text('ForgotPassword')),
        '/register': (_) => const Scaffold(body: Text('Register')),
      },
      home: const LoginScreen(),
    );
  }

  // ── Rendering ─────────────────────────────────────────────────────────────
  group('Rendering', () {
    testWidgets('shows title, email, password fields and login button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to UniSphere'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login to Dashboard'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Keep me logged in'), findsOneWidget);
      expect(find.text("Don't have an account yet? "), findsOneWidget);
      expect(find.text('Register here'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });

  // ── Validation ────────────────────────────────────────────────────────────
  group('Validation', () {
    testWidgets('shows error on empty email submit', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error on blocked domain (gmail)', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'test@gmail.com');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Please use your university email address'), findsOneWidget);
    });

    testWidgets('shows error on non-UK email', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'test@mit.edu');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid UK university email'), findsOneWidget);
    });

    testWidgets('shows password error when email valid but password empty', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'alex@ox.ac.uk');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows password too short error', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'alex@ox.ac.uk');
      await tester.enterText(fields.at(1), 'ab1!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.textContaining('8 characters'), findsOneWidget);
    });
  });

  // ── Password visibility toggle ────────────────────────────────────────────
  group('Password toggle', () {
    testWidgets('tapping eye icon toggles visibility', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  // ── Checkbox ──────────────────────────────────────────────────────────────
  group('Keep me logged in', () {
    testWidgets('checkbox toggles state', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      await tester.tap(checkbox);
      await tester.pump();
      expect(tester.widget<Checkbox>(checkbox).value, true);

      await tester.tap(checkbox);
      await tester.pump();
      expect(tester.widget<Checkbox>(checkbox).value, false);
    });
  });

  // ── Backend interactions ──────────────────────────────────────────────────
  group('Backend', () {
    testWidgets('successful login navigates to dashboard', (tester) async {
      when(() => mockBackend.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'alex@ox.ac.uk');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // SnackBar appears in overlay before navigation completes
      expect(
        find.text('Welcome back! Login successful.', skipOffstage: false),
        findsOneWidget,
      );

      // Navigate to dashboard
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('failed login shows error snackbar', (tester) async {
      when(() => mockBackend.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'alex@ox.ac.uk');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Invalid email or password.', skipOffstage: false), findsOneWidget);
    });

    testWidgets('loading indicator shows while logging in', (tester) async {
      when(() => mockBackend.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return false;
      });

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'alex@ox.ac.uk');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Login to Dashboard'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  // ── Navigation links ──────────────────────────────────────────────────────
  group('Navigation', () {
    testWidgets('Forgot Password? navigates to /forgot-password', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('ForgotPassword'), findsOneWidget);
    });

    testWidgets('Register here navigates to /register', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap the GestureDetector wrapping the 'Register here' text
      await tester.tap(find.text('Register here'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('logo tap calls maybePop', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Logo tap calls maybePop which is a no-op at root
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
