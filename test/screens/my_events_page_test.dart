import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';
import 'package:unisphere_app/screens/my_events_page.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

Future<void> pumpMyEventsPage(
  WidgetTester tester, {
  DbUser? user,
  List<Map<String, dynamic>> events = const [],
}) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final backend = SqliteBackend();
  backend.client = MockClient((request) async {
    if (request.url.path == '/events') {
      return http.Response(jsonEncode(events), 200);
    }
    if (request.url.path.startsWith('/events/')) {
      return http.Response(jsonEncode(events.isNotEmpty ? events.first : {}), 200);
    }
    if (request.url.path.startsWith('/profiles/')) {
      return http.Response(jsonEncode({'firstName': 'Org', 'lastName': 'User'}), 200);
    }
    if (request.url.path.startsWith('/auth/')) {
      return http.Response('OK', 200);
    }
    return http.Response('OK', 200);
  });
  backend.injectMockState(user: user, mockEvents: events);

  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/profile': (_) => const Scaffold(body: Text('Profile Screen')),
        '/create-event': (_) => const Scaffold(body: CreateEventScreen()),
      },
      home: const MyEventsPage(),
    ),
  );
  await tester.pumpAndSettle();
}

DbUser organiserUser() {
  return DbUser(
    id: 1,
    email: 'organiser@oxford.ac.uk',
    password: 'pw',
    firstName: 'Org',
    lastName: 'User',
    role: 'Organiser',
    university: 'Oxford',
    description: '',
    isApproved: true,
    createdAt: DateTime(2024),
  );
}

void main() {
  testWidgets('shows locked state for non-organisers and opens profile', (
    tester,
  ) async {
    await pumpMyEventsPage(tester, user: null, events: const []);

    expect(find.text('Organiser only access'), findsOneWidget);
    expect(find.text('Open profile'), findsOneWidget);

    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Screen'), findsOneWidget);
  });

  testWidgets('shows empty organiser state when there are no events', (
    tester,
  ) async {
    await pumpMyEventsPage(tester, user: organiserUser(), events: const []);

    expect(find.text('My Events'), findsNWidgets(2));
    expect(find.text('No events created yet'), findsOneWidget);
    expect(find.text('Create your first event'), findsOneWidget);
  });

  testWidgets('renders organiser event cards and opens delete dialog', (
    tester,
  ) async {
    final events = [
      {
        'id': 10,
        'title': 'Tech Night',
        'date': '2026-06-01T18:00:00.000',
        'endDate': '2026-06-01T20:00:00.000',
        'location': 'Main Hall',
        'category': 'Technology',
        'description': 'A tech event',
        'organizerEmail': 'organiser@oxford.ac.uk',
        'bannerImageData': null,
      },
    ];

    await pumpMyEventsPage(tester, user: organiserUser(), events: events);

    expect(find.text('Tech Night'), findsOneWidget);
    expect(find.textContaining('1 Jun, 2026'), findsOneWidget);
    expect(find.byTooltip('Edit Event'), findsOneWidget);
    expect(find.byTooltip('Delete Event'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Event'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Event'), findsOneWidget);
    expect(find.textContaining('Tech Night'), findsNWidgets(2));
  });
}
