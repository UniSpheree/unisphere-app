import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/screens/discover_event_screen.dart';
import 'package:unisphere_app/screens/event_details_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}

void main() {
  late MockSqliteBackend mockBackend;

  setUp(() {
    mockBackend = MockSqliteBackend();
    SqliteBackend.instance = mockBackend;

    when(() => mockBackend.events).thenReturn([
      {
        'id': '1',
        'title': 'Tech Conference',
        'date': '2026-05-10',
        'location': 'London',
        'category': 'Technology',
        'visibility': 'Public',
      },
    ]);
    
    when(() => mockBackend.addListener(any())).thenReturn(null);
    when(() => mockBackend.removeListener(any())).thenReturn(null);
    when(() => mockBackend.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest({String? initialSearchQuery}) {
    return MaterialApp(
      routes: {
        '/about': (context) => const Scaffold(body: Text('About Page')),
        '/login': (context) => const Scaffold(body: Text('Login Page')),
        '/create-event': (context) => const Scaffold(body: Text('Create Page')),
        '/my-tickets': (context) => const Scaffold(body: Text('Tickets Page')),
        '/discover': (context) => const DiscoverEventScreen(),
        '/register': (context) => const Scaffold(body: Text('Register Page')),
      },
      home: DiscoverEventScreen(initialSearchQuery: initialSearchQuery),
    );
  }

  testWidgets('achieve 100% coverage for DiscoverEventScreen', (tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 1. Initial State
    expect(find.text('Tech Conference'), findsWidgets);
    
    // 2. Category Chips
    await tester.tap(find.text('Technology').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();

    // 3. Filters Dropdown
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('today'));
    await tester.tap(find.text('free'));
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // 4. Search
    await tester.enterText(find.byType(TextField), 'Tech');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining("results for"), findsOneWidget);
    
    // Clear search
    await tester.enterText(find.byType(TextField), '');
    // Wait for the suffix icon to disappear if it was there
    await tester.pump();
    
    // 5. Navigation to Details
    final detailsBtn = find.text('Details').first;
    await tester.ensureVisible(detailsBtn);
    await tester.tap(detailsBtn);
    await tester.pumpAndSettle();
    expect(find.byType(EventDetailsScreen), findsOneWidget);
    
    // Back using breadcrumb icon
    final backBtn = find.byIcon(Icons.arrow_back).first;
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // 6. Backend Sync
    VoidCallback? listener;
    // Capture the listener from the latest interaction
    final captured = verify(() => mockBackend.addListener(captureAny())).captured;
    listener = captured.last as VoidCallback;
    
    when(() => mockBackend.events).thenReturn([]);
    listener.call();
    await tester.pump();
    await tester.pumpAndSettle();
    
    expect(find.text('Tech Conference'), findsNothing);

    // 7. Initial search query
    await tester.pumpWidget(createWidgetUnderTest(initialSearchQuery: 'Music'));
    await tester.pumpAndSettle();
    expect(find.textContaining("results for"), findsOneWidget);
  });
}
