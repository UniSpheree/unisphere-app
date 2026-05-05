import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/my_tickets_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

Future<void> pumpMyTicketsScreen(
  WidgetTester tester, {
  DbUser? user,
  List<Map<String, dynamic>> events = const [],
  List<DbPurchasedTicket> tickets = const [],
}) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final backend = SqliteBackend();
  backend.logout();
  backend.client = MockClient((request) async {
    if (request.url.path == '/auth/login') {
      return http.Response(
        jsonEncode({
          'id': user?.id ?? 1,
          'email': user?.email ?? 'student@oxford.ac.uk',
          'firstName': user?.firstName ?? 'Stu',
          'lastName': user?.lastName ?? 'Dent',
          'role': user?.role ?? 'Attendee',
          'university': user?.university ?? 'Oxford',
          'description': user?.description ?? '',
          'isApproved': user?.isApproved ?? true,
          'createdAt': (user?.createdAt ?? DateTime(2024)).toIso8601String(),
        }),
        200,
      );
    }
    if (request.url.path == '/auth/logout') {
      return http.Response('OK', 200);
    }
    if (request.url.path == '/events') {
      return http.Response(jsonEncode(events), 200);
    }
    if (request.url.path.startsWith('/tickets/')) {
      return http.Response(jsonEncode(tickets.map((t) => t.toMap()).toList()), 200);
    }
    if (request.url.path.startsWith('/events/')) {
      return http.Response(jsonEncode(events.isNotEmpty ? events.first : {}), 200);
    }
    return http.Response('OK', 200);
  });
  if (user != null) {
    await backend.login(email: user.email, password: user.password);
  } else {
    backend.injectMockState(user: null, mockEvents: events);
  }
  await tester.pumpWidget(
    const MaterialApp(home: MyTicketsScreen()),
  );
  await tester.pumpAndSettle();
}

DbUser attendeeUser() {
  return DbUser(
    id: 1,
    email: 'student@oxford.ac.uk',
    password: 'pw',
    firstName: 'Stu',
    lastName: 'Dent',
    role: 'Attendee',
    university: 'Oxford',
    description: '',
    isApproved: true,
    createdAt: DateTime(2024),
  );
}

void main() {
  testWidgets('shows empty state when no tickets are saved', (tester) async {
    await pumpMyTicketsScreen(tester, user: null, events: const [], tickets: const []);

    expect(find.text('No tickets saved yet'), findsOneWidget);
    expect(find.text('Go back and browse events to buy one.'), findsOneWidget);
  });

  testWidgets('shows matching tickets and filters by search query', (tester) async {
    final events = [
      {
        'id': 1,
        'title': 'Tech Night',
        'date': '2026-06-01T18:00:00.000',
        'location': 'Main Hall',
        'category': 'Technology',
        'organizer': 'Org User',
        'organizerEmail': 'organiser@oxford.ac.uk',
        'bannerImageData': null,
      },
    ];
    final tickets = [
      DbPurchasedTicket(
        id: 22,
        userEmail: 'student@oxford.ac.uk',
        title: 'Tech Night',
        date: '2026-06-01T18:00:00.000',
        location: 'Main Hall',
        category: 'Technology',
        price: '£10',
        purchasedAt: DateTime(2026, 5, 1),
        eventId: 1,
      ),
    ];

    await pumpMyTicketsScreen(tester, user: attendeeUser(), events: events, tickets: tickets);

    expect(find.text('Tech Night'), findsOneWidget);
    expect(find.textContaining('1 ticket available'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'hall');
    await tester.pumpAndSettle();

    expect(find.textContaining('1 match found'), findsOneWidget);
    expect(find.text('Tech Night'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'music');
    await tester.pumpAndSettle();

    expect(find.text('No matching tickets'), findsOneWidget);
  });

  testWidgets('opens delete confirmation for a saved ticket', (tester) async {
    final events = [
      {
        'id': 7,
        'title': 'Design Summit',
        'date': '2026-06-10T09:00:00.000',
        'location': 'Lecture Theatre',
        'category': 'Workshops',
        'organizer': 'Org User',
        'organizerEmail': 'organiser@oxford.ac.uk',
        'bannerImageData': null,
      },
    ];
    final tickets = [
      DbPurchasedTicket(
        id: 99,
        userEmail: 'student@oxford.ac.uk',
        title: 'Design Summit',
        date: '2026-06-10T09:00:00.000',
        location: 'Lecture Theatre',
        category: 'Workshops',
        price: '£5',
        purchasedAt: DateTime(2026, 5, 1),
        eventId: 7,
      ),
    ];

    await pumpMyTicketsScreen(tester, user: attendeeUser(), events: events, tickets: tickets);

    await tester.tap(find.byTooltip('Remove ticket'));
    await tester.pumpAndSettle();

    expect(find.text('Delete ticket'), findsOneWidget);
    expect(find.textContaining('Design Summit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
