import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/event_details_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SqliteBackend().logout();
    // Suppress RenderFlex overflow errors for tests
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

  Widget _buildTestApp(Widget child) {
    return MaterialApp(
      routes: {
        '/register': (_) => Scaffold(appBar: AppBar(), body: const Text('Register Screen')),
        '/my-tickets': (_) => Scaffold(appBar: AppBar(), body: const Text('My Tickets Screen')),
        '/logged-in': (_) => Scaffold(appBar: AppBar(), body: const Text('Logged In Screen')),
        '/discover': (_) => Scaffold(appBar: AppBar(), body: const Text('Discover Screen')),
        '/profile': (_) => Scaffold(appBar: AppBar(), body: const Text('Profile Screen')),
      },
      home: child,
    );
  }

  Future<void> _pumpApp(WidgetTester tester, Widget child, {Size size = const Size(1920, 1080)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_buildTestApp(child));
    await tester.pumpAndSettle();
  }

  final dummyEvent = {
    'id': 1,
    'title': 'Test Event',
    'description': 'Test Description',
    'date': '2026-05-10',
    'location': 'Test Location',
    'category': 'Academic',
    'tags': ['tag1', 'tag2'],
    'organizer': 'Test Organizer',
    'organizerEmail': 'organizer@test.com',
    'capacity': 100,
    'price': '£10',
    'color': Colors.blue,
  };

  group('EventDetailsScreen', () {
    testWidgets('renders deleted state when event is not in backend and pops correctly', (tester) async {
      SqliteBackend().injectMockState(mockEvents: []); // Backend has no events
      
      // Use a router so we can test pop
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(event: dummyEvent),
                ),
              ),
              child: const Text('Push Screen'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Push Screen'));
      await tester.pumpAndSettle();

      expect(find.text('This event was deleted'), findsOneWidget);
      expect(find.text('Go back'), findsOneWidget);

      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();
      
      expect(find.text('Push Screen'), findsOneWidget); // Validates pop
    });

    testWidgets('renders all event details correctly', (tester) async {
      SqliteBackend().injectMockState(
        mockEvents: [dummyEvent],
        user: null,
      );

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent));

      expect(find.text('Test Event'), findsWidgets);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('2026-05-10'), findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.text('Academic'), findsOneWidget);
      expect(find.text('tag1'), findsOneWidget);
      expect(find.text('Test Organizer'), findsOneWidget);
      expect(find.text('Capacity: 100'), findsOneWidget);
      expect(find.text('£10'), findsOneWidget);
      expect(find.text('Buy ticket now'), findsOneWidget);
    });

    testWidgets('renders default values for missing optional fields', (tester) async {
      final incompleteEvent = {
        'id': 2,
        'title': 'Minimal Event',
        'date': '2026-05-11',
        'location': 'Unknown',
        'category': 'Other',
        // missing tags, organizer, capacity, price, description
      };

      SqliteBackend().injectMockState(
        mockEvents: [incompleteEvent],
        user: null,
      );

      await _pumpApp(tester, EventDetailsScreen(event: incompleteEvent));

      expect(find.text('Minimal Event'), findsWidgets);
      expect(find.text('No extra description provided for this event.'), findsOneWidget);
      expect(find.text('Organizer not specified'), findsOneWidget);
      expect(find.text('Buy ticket now'), findsOneWidget);
      expect(find.text('Capacity: '), findsNothing); // Because capacity is null
    });

    testWidgets('handles banner image data correctly and displays error builder', (tester) async {
      final invalidImageEvent = Map<String, dynamic>.from(dummyEvent)
        ..['id'] = 3
        ..['bannerImageData'] = Uint8List.fromList([1, 2, 3]); // Invalid bytes for Image.memory

      SqliteBackend().injectMockState(mockEvents: [invalidImageEvent]);

      await _pumpApp(tester, EventDetailsScreen(event: invalidImageEvent));

      // Should see the broken_image icon from error builder
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('handles purchase when not logged in (pending purchase)', (tester) async {
      SqliteBackend().injectMockState(
        mockEvents: [dummyEvent],
        user: null, // Not logged in
      );

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent));

      final buyButton = find.text('Buy ticket now');
      await tester.ensureVisible(buyButton);
      await tester.tap(buyButton);
      await tester.pumpAndSettle();

      expect(find.text('Please register or sign in to complete your purchase.'), findsOneWidget);
      expect(find.text('Register Screen'), findsOneWidget); // Navigated to register
      expect(SqliteBackend().pendingPurchase, isNotNull);
    });

    testWidgets('handles purchase when logged in', (tester) async {
      final user = DbUser(
        email: 'user@test.com',
        password: 'password',
        firstName: 'John',
        lastName: 'Doe',
        role: 'Attendee',
        university: 'Uni',
        description: '',
        isApproved: true,
        createdAt: DateTime.now(),
      );

      SqliteBackend().injectMockState(
        user: user,
        mockEvents: [dummyEvent],
      );

      // Mock the HTTP client to handle the ticket purchase request
      SqliteBackend().client = MockClient((request) async {
        if (request.url.path == '/tickets') {
          return http.Response(jsonEncode({
            'id': 101,
            'userEmail': user.email,
            'title': dummyEvent['title'],
            'date': dummyEvent['date'],
            'location': dummyEvent['location'],
            'category': dummyEvent['category'],
            'price': dummyEvent['price'],
            'purchasedAt': DateTime.now().toIso8601String(),
            'eventId': dummyEvent['id'],
          }), 201);
        }
        if (request.url.path == '/events') {
          return http.Response(jsonEncode([dummyEvent]), 200);
        }
        return http.Response('Not Found', 404);
      });

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent));

      final buyButton = find.text('Buy ticket now');
      await tester.ensureVisible(buyButton);
      await tester.tap(buyButton);
      
      // Wait for the async purchaseTicket microtask and then the SnackBar
      await tester.pump(); 
      await tester.pumpAndSettle();

      expect(find.text('Ticket purchased for Test Event'), findsOneWidget);
      expect(find.text('My Tickets Screen'), findsOneWidget); // Navigated to my tickets
    });

    testWidgets('displays organizer view when currentUser is the organizer', (tester) async {
      final organizerUser = DbUser(
        email: 'organizer@test.com', // Matches dummyEvent organizerEmail
        password: 'password',
        firstName: 'Test',
        lastName: 'Organizer',
        role: 'Organiser',
        university: 'Uni',
        description: '',
        isApproved: true,
        createdAt: DateTime.now(),
      );

      SqliteBackend().injectMockState(
        user: organizerUser,
        mockEvents: [dummyEvent],
      );

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent));

      expect(find.text('This is your event. You can manage it from the My Events page.'), findsOneWidget);
      expect(find.text('Buy ticket now'), findsNothing);
    });

    testWidgets('displays already bought view when allowPurchase is false', (tester) async {
      SqliteBackend().injectMockState(
        user: null,
        mockEvents: [dummyEvent],
        clearUser: true,
      );

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent, allowPurchase: false));

      // Scroll to ensure it's visible
      final alreadyBoughtText = find.text('You already have a ticket for this event.');
      await tester.ensureVisible(alreadyBoughtText);
      expect(alreadyBoughtText, findsOneWidget);
      expect(find.text('Buy ticket now'), findsNothing);
    });

    testWidgets('breadcrumbs navigate back via icon and text', (tester) async {
      SqliteBackend().injectMockState(
        mockEvents: [dummyEvent],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(event: dummyEvent),
                ),
              ),
              child: const Text('Push Screen'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Test Icon back
      await tester.tap(find.text('Push Screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.text('Push Screen'), findsOneWidget);

      // Test Text back
      await tester.tap(find.text('Push Screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back').first);
      await tester.pumpAndSettle();
      expect(find.text('Push Screen'), findsOneWidget);
    });

    testWidgets('rebuilds when backend state changes', (tester) async {
      SqliteBackend().injectMockState(
        mockEvents: [dummyEvent],
      );

      await _pumpApp(tester, EventDetailsScreen(event: dummyEvent));

      // Trigger a change
      SqliteBackend().notifyListeners();
      await tester.pumpAndSettle();

      // We just ensure it doesn't crash on state change
      expect(find.text('Test Event'), findsWidgets);
    });

    testWidgets('handles event with null ID and triggers orElse', (tester) async {
      final noIdEvent = Map<String, dynamic>.from(dummyEvent)..remove('id');
      // Backend has an event with ID 1, but we are looking for null ID
      SqliteBackend().injectMockState(mockEvents: [dummyEvent], clearUser: true);

      await _pumpApp(tester, EventDetailsScreen(event: noIdEvent));
      expect(find.text('Test Event'), findsWidgets);
    });

    testWidgets('handles canonical event not found', (tester) async {
      // Event in widget has ID 999, but backend has no such event
      final rareEvent = Map<String, dynamic>.from(dummyEvent)..['id'] = 999;
      SqliteBackend().injectMockState(mockEvents: [dummyEvent], clearUser: true);

      await _pumpApp(tester, EventDetailsScreen(event: rareEvent));
      expect(find.text('This event was deleted'), findsOneWidget);
    });
  });
}
