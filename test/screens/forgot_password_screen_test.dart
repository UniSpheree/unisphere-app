import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/screens/forgot_password_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}

// Helper: a valid UK university email the validator will accept
const _validEmail = 'alex@ox.ac.uk';

void main() {
  late MockSqliteBackend mockBackend;

  setUp(() {
    mockBackend = MockSqliteBackend();
    SqliteBackend.instance = mockBackend;
    registerFallbackValue('');
  });

  Widget app() => MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login Screen')),
        },
        home: const ForgotPasswordScreen(),
      );

  // ────────────────────────────────────────────────────────────────
  // STEP 1 — Email validation + backend
  // ────────────────────────────────────────────────────────────────
  group('Step 1 – Email entry', () {
    testWidgets('shows error on empty submit', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for blocked domain (gmail)', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@gmail.com');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('Please use your university email address'), findsOneWidget);
    });

    testWidgets('shows error for non-UK university email', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@mit.edu');
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid UK university email'), findsOneWidget);
    });

    testWidgets('shows snackbar when email not found', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBackend.forgotPassword(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), _validEmail);
      await tester.tap(find.text('Send Reset Code'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 100)); // resolve future
      await tester.pump(); // rebuild
      expect(find.text('No account found with this email.'), findsOneWidget);
    });

    testWidgets('advances to step 2 on success', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBackend.forgotPassword(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), _validEmail);
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();

      expect(find.text('Check your Email'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // STEP 2 — Code verification
  // ────────────────────────────────────────────────────────────────
  group('Step 2 – Code verification', () {
    // Helper: pump to step 2
    Future<void> pumpToStep2(WidgetTester tester) async {
      when(() => mockBackend.forgotPassword(any())).thenAnswer((_) async => true);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), _validEmail);
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows error on short code', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep2(tester);

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.text('Verify Code'));
      await tester.pumpAndSettle();
      expect(find.text('Code must be 6 digits'), findsOneWidget);
    });

    testWidgets('resend shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep2(tester);

      await tester.tap(find.text('Resend Code'));
      await tester.pump(); // kick off snackbar animation
      await tester.pump(const Duration(milliseconds: 100));
      // SnackBar is in overlay — find it even if offstage
      expect(
        find.text('Code resent! (hint: 123456)', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('wrong code shows invalid snackbar', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep2(tester);

      await tester.enterText(find.byType(TextFormField), '000000');
      await tester.tap(find.text('Verify Code'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 700)); // wait for delay
      await tester.pump(); // rebuild
      expect(
        find.text('Invalid code. Please try again.', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('correct code advances to step 3', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep2(tester);

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.text('Set New Password'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // STEP 3 — New password
  // ────────────────────────────────────────────────────────────────
  group('Step 3 – New password', () {
    // Helper: pump straight to step 3
    Future<void> pumpToStep3(WidgetTester tester) async {
      when(() => mockBackend.forgotPassword(any())).thenAnswer((_) async => true);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), _validEmail);
      await tester.tap(find.text('Send Reset Code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    }

    testWidgets('password visibility toggles work', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep3(tester);
      expect(find.text('Set New Password'), findsOneWidget);

      // Toggle new password visibility
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Toggle confirm password visibility
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets('shows mismatch error', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpToStep3(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Different999!');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows failure snackbar on backend error', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBackend.resetPassword(any(), any())).thenAnswer((_) async => false);
      await pumpToStep3(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(
        find.text('Failed to reset password. Please try again.', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('navigates to login on success', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBackend.resetPassword(any(), any())).thenAnswer((_) async => true);
      await pumpToStep3(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Navigation
  // ────────────────────────────────────────────────────────────────
  testWidgets('Back to Login navigates correctly', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
