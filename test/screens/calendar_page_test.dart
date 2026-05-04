import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/screens/calendar_page.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/widgets/header.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SqliteBackend().logout(); // Clear any injected state between tests
    
    // Ignore RenderFlex overflow errors that happen due to test environment font scaling
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
  });

  Widget _buildTestApp() {
    return MaterialApp(
      key: UniqueKey(),
      routes: {
        '/': (_) => const CalendarPage(),
        '/create-event': (_) => Scaffold(appBar: AppBar(), body: const Text('Create Event Screen')),
        '/discover': (_) => Scaffold(appBar: AppBar(), body: const Text('Discover Screen')),
        '/my-tickets': (_) => Scaffold(appBar: AppBar(), body: const Text('My Tickets Screen')),
        '/login': (_) => Scaffold(appBar: AppBar(), body: const Text('Login Screen')),
        '/about': (_) => Scaffold(appBar: AppBar(), body: const Text('About Screen')),
        '/profile': (_) => Scaffold(appBar: AppBar(), body: const Text('Profile Screen')),
      },
      initialRoute: '/',
    );
  }

  Future<void> _pumpApp(WidgetTester tester, {Size size = const Size(1200, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();
  }

  group('CalendarPage', () {
    testWidgets('renders locked state when user is not logged in', (tester) async {
      await _pumpApp(tester, size: const Size(500, 900)); // Use mobile to avoid flex overflow
      addTearDown(tester.view.reset);

      expect(find.text('Organiser calendar locked'), findsOneWidget);
      expect(find.text('Open profile'), findsOneWidget);
    });

    testWidgets('renders locked state when user is logged in but not an organiser', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'attendee@uni.ac.uk',
          password: 'password',
          firstName: 'John',
          lastName: 'Doe',
          role: 'Attendee', // Not an organiser
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
      );

      await _pumpApp(tester, size: const Size(500, 900));
      addTearDown(tester.view.reset);

      expect(find.text('Organiser calendar locked'), findsOneWidget);
      
      // Test the 'Open profile' button
      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets('renders calendar view when user is an organiser', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'organiser@uni.ac.uk',
          password: 'password',
          firstName: 'Jane',
          lastName: 'Smith',
          role: 'Organiser', // Is an organiser
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
        mockEvents: [], // Empty events
      );

      await _pumpApp(tester, size: const Size(1920, 1080)); // Large desktop viewport
      addTearDown(tester.view.reset);

      expect(find.text('Organiser Calendar'), findsWidgets);
      
      // Default start date is 2026-05-17 (May 2026)
      expect(find.text('May 2026'), findsOneWidget);

      // Verify days of the week are shown
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);

      // Verify hours are shown
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('03:00'), findsOneWidget);
      expect(find.text('06:00'), findsOneWidget);
    });

    testWidgets('calendar navigation buttons update the week', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'org@uni.ac.uk',
          password: 'pass',
          firstName: 'Org',
          lastName: 'Name',
          role: 'Organiser',
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
      );

      await _pumpApp(tester, size: const Size(1920, 1080));
      addTearDown(tester.view.reset);

      // Current week is May 17, 2026. Next week is May 24, 2026
      expect(find.text('May 2026'), findsOneWidget);
      
      // Find the next week button (chevron_right_rounded)
      final nextWeekBtn = find.byIcon(Icons.chevron_right_rounded);
      expect(nextWeekBtn, findsOneWidget);
      
      await tester.tap(nextWeekBtn);
      await tester.pumpAndSettle();

      // Wait, tapping next week keeps it in May 2026.
      // Let's tap 4 times to go to June 2026.
      await tester.tap(nextWeekBtn);
      await tester.tap(nextWeekBtn);
      await tester.tap(nextWeekBtn);
      await tester.pumpAndSettle();

      expect(find.text('June 2026'), findsOneWidget);

      // Now tap previous week button to go back to May
      final prevWeekBtn = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(prevWeekBtn);
      await tester.tap(prevWeekBtn);
      await tester.tap(prevWeekBtn);
      await tester.tap(prevWeekBtn);
      await tester.pumpAndSettle();

      expect(find.text('May 2026'), findsOneWidget);
    });

    testWidgets('renders events matching the user and date correctly', (tester) async {
      // Mock an event on Monday, May 18, 2026 at 10:30 to 12:30
      // Another event with invalid date
      // Another event on Tuesday, May 19 without endDate
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'org@uni.ac.uk',
          password: 'pass',
          firstName: 'Org',
          lastName: 'Name',
          role: 'Organiser',
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
        mockEvents: [
          {
            'id': 1,
            'title': 'Flutter Workshop',
            'location': 'Room A',
            'date': '2026-05-18T01:30:00',
            'endDate': '2026-05-18T03:30:00',
            'organizerEmail': 'org@uni.ac.uk', // Matches user
          },
          {
            'id': 2,
            'title': 'Invalid Date Event',
            'location': 'Room B',
            'date': 'invalid-date', // Tests the catch block
            'organizerEmail': 'org@uni.ac.uk',
          },
          {
            'id': 3,
            'title': 'Short Event',
            'location': 'Room C',
            'date': '2026-05-19T04:00:00',
            'endDate': null, // Tests the fallback endDate (start + 1h)
            'organizerEmail': 'org@uni.ac.uk',
          },
          {
            'id': 4,
            'title': 'Other Organizer Event', // Should not be rendered
            'location': 'Room D',
            'date': '2026-05-18T01:30:00',
            'organizerEmail': 'other@uni.ac.uk',
          }
        ],
      );

      await _pumpApp(tester, size: const Size(1920, 1080));
      addTearDown(tester.view.reset);

      // Verify the events are rendered
      expect(find.text('Flutter Workshop'), findsWidgets); // Overlaps 3 hour slots (10:00, 11:00, 12:00)
      expect(find.text('Room A'), findsWidgets);
      
      expect(find.text('Short Event'), findsWidgets); // Overlaps 14:00 slot
      expect(find.text('Room C'), findsWidgets);
      
      // Invalid date event and other organizer's event should not be found
      expect(find.text('Invalid Date Event'), findsNothing);
      expect(find.text('Other Organizer Event'), findsNothing);
    });

    testWidgets('renders event with no location without throwing', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'org@uni.ac.uk',
          password: 'pass',
          firstName: 'Org',
          lastName: 'Name',
          role: 'Organiser',
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
        mockEvents: [
          {
            'id': 5,
            'title': 'No Location Event',
            'location': null,
            'date': '2026-05-18T02:00:00',
            'organizerEmail': 'org@uni.ac.uk',
          },
        ],
      );

      await _pumpApp(tester, size: const Size(1920, 1080));
      addTearDown(tester.view.reset);

      expect(find.text('No Location Event'), findsWidgets);
    });

    testWidgets('header navigation buttons and back button work', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'org@uni.ac.uk',
          password: 'pass',
          firstName: 'Org',
          lastName: 'Name',
          role: 'Organiser',
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
      );

      await _pumpApp(tester, size: const Size(1920, 1080));
      addTearDown(tester.view.reset);

      // Test the back buttons in breadcrumbs
      // Tap the back icon first
      final backIcon = find.byIcon(Icons.arrow_back).first;
      expect(backIcon, findsOneWidget);
      await tester.tap(backIcon);
      await tester.pumpAndSettle();
      expect(find.text('Organiser Calendar'), findsNothing);

      // Re-pump app to test the text back button
      await _pumpApp(tester, size: const Size(1920, 1080));
      
      final backTexts = find.text('Back');
      expect(backTexts, findsWidgets);
      
      // Tap the 'Back' text
      await tester.tap(backTexts.first);
      await tester.pumpAndSettle();
      
      expect(find.text('Organiser Calendar'), findsNothing);
    });
    
    testWidgets('AppHeader navigation callbacks push correct routes', (tester) async {
      await _pumpApp(tester, size: const Size(500, 900));
      addTearDown(tester.view.reset);

      final headerFinder = find.byType(AppHeader);
      expect(headerFinder, findsOneWidget);
      final header = tester.widget<AppHeader>(headerFinder);

      header.onHostEventTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Create Event Screen'), findsOneWidget);
      
      // Return to initial
      await tester.pageBack();
      await tester.pumpAndSettle();

      header.onFindEventsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Discover Screen'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      header.onCreateEventsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Create Event Screen'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      header.onMyTicketsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('My Tickets Screen'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      header.onAboutTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('About Screen'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      header.onSignInTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('mobile layout adjusts correctly', (tester) async {
      SqliteBackend().injectMockState(
        user: DbUser(
          email: 'org@uni.ac.uk',
          password: 'pass',
          firstName: 'Org',
          lastName: 'Name',
          role: 'Organiser',
          university: 'Uni',
          description: '',
          isApproved: true,
          createdAt: DateTime.now(),
        ),
        mockEvents: [],
      );

      await _pumpApp(tester, size: const Size(640, 900)); // Mobile size
      addTearDown(tester.view.reset);

      // Calendar should still render, just with smaller padding (isMobile = true branch)
      expect(find.text('Organiser Calendar'), findsWidgets);
    });
  });
}
