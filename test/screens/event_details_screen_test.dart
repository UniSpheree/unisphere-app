import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/event_details_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}

void main() {
  late MockSqliteBackend mockBackend;

  setUpAll(() {
    registerFallbackValue(DbPurchasedTicket(
      userEmail: '',
      title: '',
      date: '',
      location: '',
      category: '',
      price: '',
      purchasedAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockBackend = MockSqliteBackend();
    
    when(() => mockBackend.currentUser).thenReturn(null);
    when(() => mockBackend.setPendingPurchase(any())).thenReturn(null);
    when(() => mockBackend.purchaseTicket(any())).thenAnswer((_) async => true);
    when(() => mockBackend.events).thenReturn([]);
    
    SqliteBackend.instance = mockBackend;
  });

  Widget createWidgetUnderTest(Map<String, dynamic> event, {bool allowPurchase = true}) {
    return MaterialApp(
      routes: {
        '/register': (context) => const Scaffold(body: Text('Register Screen')),
        '/my-tickets': (context) => const Scaffold(body: Text('My Tickets Screen')),
      },
      home: EventDetailsScreen(event: event, allowPurchase: allowPurchase),
    );
  }

  final baseEvent = {
    'id': '1',
    'title': 'Test Event',
    'date': '2026-05-10',
    'location': 'London, UK',
    'category': 'Technology',
    'description': 'A test event description.',
    'organizer': 'Test Organizer',
    'organizerEmail': 'organizer@test.com',
    'capacity': 100,
    'price': '£10',
    'tags': ['Tech', 'Flutter'],
  };

  testWidgets('renders all basic event details', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    expect(find.text('Test Event'), findsWidgets);
    expect(find.text('2026-05-10'), findsOneWidget);
    expect(find.text('London, UK'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('A test event description.'), findsOneWidget);
    expect(find.text('Test Organizer'), findsOneWidget);
    expect(find.text('Capacity: 100'), findsOneWidget);
    expect(find.text('£10'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('renders default values when non-essential fields are missing', (tester) async {
    final minimalEvent = {
      'title': 'Minimal Event',
      'date': 'TBA',
      'location': 'TBA',
      'category': 'Other',
    };

    await tester.pumpWidget(createWidgetUnderTest(minimalEvent));
    await tester.pumpAndSettle();

    expect(find.text('No extra description provided for this event.'), findsOneWidget);
    expect(find.text('Organizer not specified'), findsOneWidget);
  });

  testWidgets('renders banner image when provided', (tester) async {
    final eventWithImage = Map<String, dynamic>.from(baseEvent);
    eventWithImage['bannerImageData'] = Uint8List.fromList([0, 1, 2, 3]);

    await tester.pumpWidget(createWidgetUnderTest(eventWithImage));
    await tester.pumpAndSettle();

    // Find the one that uses MemoryImage
    expect(find.byWidgetPredicate((w) => w is Image && w.image is MemoryImage), findsOneWidget);
  });

  testWidgets('renders broken image icon on error', (tester) async {
    final eventWithImage = Map<String, dynamic>.from(baseEvent);
    eventWithImage['bannerImageData'] = Uint8List.fromList([0]); // Invalid image

    await tester.pumpWidget(createWidgetUnderTest(eventWithImage));
    await tester.pump(); // Start loading
    
    final imageFinder = find.byWidgetPredicate((w) => w is Image && w.image is MemoryImage);
    final imageWidget = tester.widget<Image>(imageFinder);
    
    // Manual trigger of error builder
    final BuildContext context = tester.element(imageFinder);
    final errorWidget = imageWidget.errorBuilder!(context, 'error', null);
    
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });

  testWidgets('navigation breadcrumbs work', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
  });

  testWidgets('back icon breadcrumb works', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  });

  testWidgets('shows organizer management message for organizer', (tester) async {
    when(() => mockBackend.currentUser).thenReturn(DbUser(
      email: 'organizer@test.com',
      password: '',
      firstName: 'Test',
      lastName: 'Organizer',
      role: 'organiser',
      university: '',
      description: '',
      isApproved: true,
      createdAt: DateTime.now(),
    ));

    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    expect(find.textContaining('This is your event. You can manage it'), findsOneWidget);
    expect(find.text('Buy ticket now'), findsNothing);
  });

  testWidgets('shows already have ticket message when allowPurchase is false', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(baseEvent, allowPurchase: false));
    await tester.pumpAndSettle();

    expect(find.text('You already have a ticket for this event.'), findsOneWidget);
    expect(find.text('Buy ticket now'), findsNothing);
  });

  testWidgets('guest user buying ticket redirects to register', (tester) async {
    when(() => mockBackend.currentUser).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy ticket now'));
    await tester.pumpAndSettle();

    verify(() => mockBackend.setPendingPurchase(any())).called(1);
    expect(find.text('Please register or sign in to complete your purchase.'), findsOneWidget);
    expect(find.text('Register Screen'), findsOneWidget);
  });

  testWidgets('logged in user buying ticket succeeds', (tester) async {
    when(() => mockBackend.currentUser).thenReturn(DbUser(
      email: 'buyer@test.com',
      password: '',
      firstName: 'Buyer',
      lastName: '',
      role: 'user',
      university: '',
      description: '',
      isApproved: true,
      createdAt: DateTime.now(),
    ));

    await tester.pumpWidget(createWidgetUnderTest(baseEvent));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy ticket now'));
    await tester.pumpAndSettle();

    verify(() => mockBackend.purchaseTicket(any())).called(1);
    expect(find.textContaining('Ticket purchased for Test Event'), findsOneWidget);
    expect(find.text('My Tickets Screen'), findsOneWidget);
  });
}
