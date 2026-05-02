import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/screens/landing_page_logged_in.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/models/database_models.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}

// ── Helpers ──────────────────────────────────────────────────────────────────

DbUser makeUser({bool isOrg = false}) => DbUser(
      email: isOrg ? 'org@uni.ac.uk' : 'alex@uni.ac.uk',
      password: 'password',
      firstName: isOrg ? 'Org' : 'Alex',
      lastName: 'Smith',
      role: isOrg ? 'Organiser' : 'Attendee',
      university: 'Oxford',
      description: '',
      isApproved: true,
      createdAt: DateTime(2024),
    );

DbPurchasedTicket makeTicket(int id) => DbPurchasedTicket(
      id: id,
      userEmail: 'alex@uni.ac.uk',
      title: 'Event $id',
      date: 'Oct $id',
      location: 'Room $id',
      category: 'Social',
      price: '0',
      purchasedAt: DateTime(2024),
    );

// ── Test setup ───────────────────────────────────────────────────────────────

void main() {
  late MockSqliteBackend mockBackend;

  setUp(() {
    mockBackend = MockSqliteBackend();
    SqliteBackend.instance = mockBackend;
    when(() => mockBackend.events).thenReturn([]);
    when(() => mockBackend.purchasedTickets).thenReturn([]);
    when(() => mockBackend.currentUser).thenReturn(null);
    when(() => mockBackend.addListener(any())).thenReturn(null);
    when(() => mockBackend.removeListener(any())).thenReturn(null);
  });

  // Large viewport so entire page (including Dashboard panel) renders
  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildApp({String userName = 'Alex', String role = 'Attendee'}) {
    return MaterialApp(
      routes: {
        '/login': (_) => const Scaffold(body: Text('Login')),
        '/discover': (_) => const Scaffold(body: Text('Discover')),
        '/my-tickets': (_) => const Scaffold(body: Text('MyTickets')),
        '/about': (_) => const Scaffold(body: Text('About')),
        '/profile': (_) => const Scaffold(body: Text('Profile')),
        '/register': (_) => const Scaffold(body: Text('Register')),
        '/create-event': (_) => const Scaffold(body: Text('CreateEvent')),
      },
      home: PersonalizedLandingPage(userName: userName, role: role),
    );
  }

  // ── Rendering ─────────────────────────────────────────────────────────────
  group('Rendering', () {
    testWidgets('desktop: welcome text and discover section visible', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Alex'), findsOneWidget);
      expect(find.text('Discover newest events'), findsOneWidget);
      expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    });

    testWidgets('mobile: narrow viewport still renders correctly', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Alex'), findsOneWidget);
    });
  });

  // ── Role UI ───────────────────────────────────────────────────────────────
  group('Role UI', () {
    testWidgets('attendee sees Events Joined and My Tickets labels', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Attendee account'), findsOneWidget);
      expect(find.text('Events Joined'), findsOneWidget);
      expect(find.text('Your activity and upcoming plans in one place.'), findsOneWidget);
    });

    testWidgets('attendee sees My Tickets in both metric card and action button', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('My Tickets'), findsNWidgets(2));
    });

    testWidgets('organiser sees Live Events, Total Views and create subtitle', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser(isOrg: true));
      await tester.pumpWidget(buildApp(userName: 'Org', role: 'Organiser'));
      await tester.pumpAndSettle();

      expect(find.text('Organiser account'), findsOneWidget);
      expect(find.text('Live Events'), findsOneWidget);
      expect(find.text('Total Views'), findsOneWidget);
      expect(find.text('Your event activity at a glance.'), findsOneWidget);
      expect(find.text('Manage events, review performance, and keep your listings active.'), findsOneWidget);
    });

    testWidgets('attendee sees attendee discovery subtitle', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Jump back into discovery and see what\u2019s happening next.'), findsOneWidget);
    });
  });

  // ── Category Filtering ────────────────────────────────────────────────────
  group('Category Filtering', () {
    final twoEvents = [
      {'id': 1, 'title': 'Tech Talk', 'category': 'Technology'},
      {'id': 2, 'title': 'Music Fest', 'category': 'Music'},
    ];

    testWidgets('shows all events with All chip selected', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.events).thenReturn(twoEvents);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Music Fest'), findsOneWidget);
    });

    testWidgets('Technology chip filters to only tech events', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.events).thenReturn(twoEvents);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Technology'));
      await tester.pumpAndSettle();

      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Music Fest'), findsNothing);
    });

    testWidgets('Music chip filters to only music events', (tester) async {
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      when(() => mockBackend.events).thenReturn(twoEvents);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();

      expect(find.text('Music Fest'), findsOneWidget);
      expect(find.text('Tech Talk'), findsNothing);
    });

    testWidgets('all other chips render (Entertainment, Career, Sports, Workshops)', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Career'), findsOneWidget);
      expect(find.text('Sports'), findsOneWidget);
      expect(find.text('Workshops'), findsOneWidget);
    });
  });

  // ── Search ────────────────────────────────────────────────────────────────
  group('Search', () {
    testWidgets('title search filters correctly', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Blockchain Workshop', 'category': 'Technology'},
        {'id': 2, 'title': 'Pizza Social', 'category': 'Social'},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pumpAndSettle();

      expect(find.text('Pizza Social'), findsOneWidget);
      expect(find.text('Blockchain Workshop'), findsNothing);
    });

    testWidgets('category search filters correctly', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Blockchain Workshop', 'category': 'Technology'},
        {'id': 2, 'title': 'Pizza Social', 'category': 'Social'},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'social');
      await tester.pumpAndSettle();

      expect(find.text('Pizza Social'), findsOneWidget);
      expect(find.text('Blockchain Workshop'), findsNothing);
    });
  });

  // ── Date Filter Dropdown ──────────────────────────────────────────────────
  group('Date Filter Dropdown', () {
    testWidgets('tune icon toggles date filter panel', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('today'), findsNothing);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text('today'), findsOneWidget);

      // Select a date filter
      await tester.tap(find.text('today'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Close
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text('today'), findsNothing);
    });

    testWidgets('all date filter options render', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      for (final label in ['today', 'tomorrow', 'this week', 'next week', 'this month', 'next month']) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });

  // ── Navigation ────────────────────────────────────────────────────────────
  group('Navigation', () {
    testWidgets('settings icon goes to /profile when logged in', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('settings icon goes to /register when not logged in', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(null);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('View details navigates away from landing page', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Sci Expo', 'category': 'Technology'},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View details'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalizedLandingPage), findsNothing);
    });

    testWidgets('Create Events (welcome strip) pushes CreateEventScreen', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // 'Create Events' exists in both AppHeader and welcome strip — tap first occurrence
      await tester.tap(find.text('Create Events').first);
      await tester.pumpAndSettle();
      expect(find.byType(PersonalizedLandingPage), findsNothing);
    });

    testWidgets('My Tickets action button (attendee) pushes MyTicketsScreen', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // The action button uses ElevatedButton.icon labeled 'My Tickets'
      // Find all ElevatedButtons and tap the last one (dashboard action button)
      final allButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      final myTicketsButton = find.byWidget(
        allButtons.lastWhere((b) {
          final child = b.child;
          // ElevatedButton.icon wraps in _ElevatedButtonWithIconChild which has text
          return child?.toString().contains('My Tickets') == true;
        }, orElse: () => allButtons.last),
      );
      await tester.tap(myTicketsButton);
      await tester.pumpAndSettle();
      expect(find.byType(PersonalizedLandingPage), findsNothing);
    });

    testWidgets('Create action button (organiser) pushes CreateEventScreen', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser(isOrg: true));
      await tester.pumpWidget(buildApp(role: 'Organiser'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create').last);
      await tester.pumpAndSettle();
      expect(find.byType(PersonalizedLandingPage), findsNothing);
    });

    testWidgets('Live Events metric taps to MyEventsPage for organiser', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser(isOrg: true));
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'E1', 'organizerEmail': 'org@uni.ac.uk'},
      ]);
      await tester.pumpWidget(buildApp(role: 'Organiser'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Live Events'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalizedLandingPage), findsNothing);
    });
  });

  // ── Dashboard Metrics ─────────────────────────────────────────────────────
  group('Dashboard Metrics', () {
    testWidgets('ticket count shows for attendee', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      when(() => mockBackend.purchasedTickets).thenReturn([makeTicket(1), makeTicket(2)]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('shows empty upcoming events message', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('No upcoming events in the next 30 days.'), findsOneWidget);
    });

    testWidgets('organiser views formatted as 2K for 2 events', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser(isOrg: true));
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'E1', 'organizerEmail': 'org@uni.ac.uk'},
        {'id': 2, 'title': 'E2', 'organizerEmail': 'org@uni.ac.uk'},
      ]);
      await tester.pumpWidget(buildApp(role: 'Organiser'));
      await tester.pumpAndSettle();

      expect(find.text('2K'), findsOneWidget);
    });

    testWidgets('attendee upcoming events from purchased tickets', (tester) async {
      setLargeViewport(tester);
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      when(() => mockBackend.purchasedTickets).thenReturn([makeTicket(1)]);
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Event 1', 'category': 'Social'},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Event 1'), findsAtLeastNWidgets(1));
    });
  });

  // ── Banner / Media ────────────────────────────────────────────────────────
  group('Banner media', () {
    testWidgets('event card renders with MemoryImage when bannerBytes provided', (tester) async {
      setLargeViewport(tester);
      final bytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Image Event', 'category': 'Tech', 'bannerImageData': bytes},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final memImages = find.byWidgetPredicate((w) => w is Image && w.image is MemoryImage);
      expect(memImages, findsAtLeastNWidgets(1));
    });

    testWidgets('upcoming event card shows banner if available', (tester) async {
      setLargeViewport(tester);
      final bytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
      when(() => mockBackend.currentUser).thenReturn(makeUser());
      when(() => mockBackend.purchasedTickets).thenReturn([makeTicket(1)]);
      when(() => mockBackend.events).thenReturn([
        {'id': 1, 'title': 'Event 1', 'category': 'Social', 'bannerImageData': bytes},
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('NEXT EVENT'), findsOneWidget);
    });
  });
}
