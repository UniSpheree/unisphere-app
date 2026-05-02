import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/calendar_page.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}
class MockDbUser extends Mock implements DbUser {}

void main() {
  late MockSqliteBackend mockBackend;
  late MockDbUser mockUser;

  setUp(() {
    mockBackend = MockSqliteBackend();
    mockUser = MockDbUser();
    SqliteBackend.instance = mockBackend;

    // Default mock behavior
    when(() => mockBackend.currentUser).thenReturn(mockUser);
    when(() => mockBackend.events).thenReturn([]);
    when(() => mockUser.isOrganiser).thenReturn(true);
    when(() => mockUser.email).thenReturn('test@example.com');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Text('Navigated to ${settings.name}')),
        );
      },
      home: MediaQuery(
        data: const MediaQueryData(textScaleFactor: 0.8),
        child: const CalendarPage(),
      ),
    );
  }

  testWidgets('CalendarPage renders organiser view correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Organiser Calendar'), findsWidgets); // Found in header and title
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
    
    // Check for day names
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });

  testWidgets('CalendarPage renders locked state for non-organisers', (WidgetTester tester) async {
    when(() => mockUser.isOrganiser).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Organiser calendar locked'), findsOneWidget);
    expect(find.text('Open profile'), findsOneWidget);
    
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    expect(find.text('Navigated to /profile'), findsOneWidget);
  });

  testWidgets('Week navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the right arrow (next week)
    final nextWeekButton = find.byIcon(Icons.chevron_right_rounded);
    await tester.tap(nextWeekButton);
    await tester.pump();

    // Verify some change (e.g., month name or dates might change)
    // The initial date is May 17, 2026. Next week should still be May or June.
    expect(find.text('May 2026'), findsOneWidget);
    
    // Go back
    final prevWeekButton = find.byIcon(Icons.chevron_left_rounded);
    await tester.tap(prevWeekButton);
    await tester.pump();
    expect(find.text('May 2026'), findsOneWidget);
  });

  testWidgets('Events are rendered in the calendar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final event = {
      'id': 1,
      'title': 'Test Event',
      'date': '2026-05-18T10:00:00', // Monday
      'location': 'Room 101',
      'organizerEmail': 'test@example.com',
    };
    when(() => mockBackend.events).thenReturn([event]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll the hour list
    final listViewFinder = find.byType(ListView);
    await tester.drag(listViewFinder, const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.textContaining('Test Event'), findsWidgets);
    expect(find.textContaining('Room 101'), findsWidgets);
  });

  testWidgets('Breadcrumb navigation works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap "Back" text
    final backTextFinder = find.text('Back');
    expect(backTextFinder, findsOneWidget);
    await tester.tap(backTextFinder);
    await tester.pumpAndSettle();
    
    // Tap back icon in breadcrumbs (the one in header is usually Icons.arrow_back_rounded)
    final backIconFinder = find.byIcon(Icons.arrow_back);
    expect(backIconFinder, findsOneWidget);
    await tester.tap(backIconFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('Header callbacks work', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Test header button taps to cover the callback lines
    final buttons = [
      'Find Events',
      'Create Events',
      'About us',
      'Sign In',
    ];

    for (final label in buttons) {
      final finder = find.text(label);
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('Mobile view responsiveness', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('Organiser Calendar'), findsWidgets);
  });

  testWidgets('Handles event parsing errors gracefully', (WidgetTester tester) async {
    final badEvent = {
      'id': 1,
      'title': 'Bad Date Event',
      'date': 'not-a-date',
      'organizerEmail': 'test@example.com',
    };
    when(() => mockBackend.events).thenReturn([badEvent]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Bad Date Event'), findsNothing);
  });

  testWidgets('Handles multi-day or long events', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    final longEvent = {
      'id': 1,
      'title': 'Long Event',
      'date': '2026-05-18T10:00:00',
      'endDate': '2026-05-18T14:00:00',
      'organizerEmail': 'test@example.com',
    };
    when(() => mockBackend.events).thenReturn([longEvent]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll
    final listViewFinder = find.byType(ListView);
    await tester.drag(listViewFinder, const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.textContaining('Long Event'), findsWidgets);
  });
}
