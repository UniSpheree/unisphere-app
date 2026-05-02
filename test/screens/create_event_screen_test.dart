import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class MockSqliteBackend extends Mock implements SqliteBackend {}
class MockDbUser extends Mock implements DbUser {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockXFile extends Mock implements XFile {}

void main() {
  late MockSqliteBackend mockBackend;
  late MockDbUser mockUser;
  late MockImagePicker mockImagePicker;

  setUpAll(() {
    registerFallbackValue(const Duration(milliseconds: 600));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockBackend = MockSqliteBackend();
    mockUser = MockDbUser();
    mockImagePicker = MockImagePicker();
    SqliteBackend.instance = mockBackend;

    when(() => mockBackend.currentUser).thenReturn(mockUser);
    when(() => mockUser.isOrganiser).thenReturn(true);
    when(() => mockUser.isApproved).thenReturn(true);
    when(() => mockUser.role).thenReturn('Organiser');
    when(() => mockUser.email).thenReturn('test@example.com');
    
    when(() => mockBackend.createEvent(any())).thenAnswer((_) async => 'new_id');
    when(() => mockBackend.updateEvent(any(), any())).thenAnswer((_) async => true);
    when(() => mockBackend.setPendingEvent(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest({Map<String, dynamic>? existingEvent}) {
    return MaterialApp(
      routes: {
        '/register': (context) => const Scaffold(body: Text('Register Page')),
        '/profile': (context) => const Scaffold(body: Text('Profile Page')),
        '/logged-in': (context) => const Scaffold(body: Text('Dashboard Page')),
      },
      home: CreateEventScreen(existingEvent: existingEvent),
    );
  }

  Future<void> _pumpApp(WidgetTester tester, {Map<String, dynamic>? existingEvent}) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(createWidgetUnderTest(existingEvent: existingEvent));
    await tester.pumpAndSettle();
  }

  group('CreateEventScreen Coverage Suite', () {
    testWidgets('renders creation view correctly', (tester) async {
      await _pumpApp(tester);
      expect(find.text('Create New Event'), findsWidgets);
    });

    testWidgets('renders locked page for attendees', (tester) async {
      when(() => mockUser.isOrganiser).thenReturn(false);
      await _pumpApp(tester);
      expect(find.textContaining('locked'), findsOneWidget);
    });

    testWidgets('shows validation errors', (tester) async {
      await _pumpApp(tester);
      final submitBtn = find.byKey(const Key('submit_event_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(find.text('Event Name is required'), findsOneWidget);
    });

    testWidgets('handles update event success', (tester) async {
      final existing = {
        'id': '123',
        'title': 'Valid Event Title',
        'description': 'Valid description with alphanumeric 123',
        'location': 'Loc',
        'category': 'Academic',
        'date': '2026-10-10T10:00:00',
        'endDate': '2026-10-10T12:00:00',
        'maxAttendees': 100,
      };
      await _pumpApp(tester, existingEvent: existing);
      
      final updateBtn = find.byKey(const Key('submit_event_button'));
      await tester.ensureVisible(updateBtn);
      await tester.tap(updateBtn);
      await tester.pump();
      
      expect(find.textContaining('Updating'), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(); // Render SnackBar before potential pop
      
      expect(find.textContaining('successfully'), findsWidgets);
      verify(() => mockBackend.updateEvent(any(), any())).called(1);
    });

    testWidgets('saves pending event when not logged in', (tester) async {
      when(() => mockBackend.currentUser).thenReturn(null);
      final existing = {
        'id': '1',
        'title': 'Pending Event Title',
        'description': 'Valid description text for draft 123',
        'location': 'Draft Location',
        'category': 'Social',
        'date': '2026-10-10T10:00:00',
        'endDate': '2026-10-10T12:00:00',
        'maxAttendees': 100,
      };
      await _pumpApp(tester, existingEvent: existing);

      final submitBtn = find.byKey(const Key('submit_event_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      
      await tester.pump();
      expect(find.textContaining('draft was saved'), findsWidgets);
      
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Register Page'), findsOneWidget);
      verify(() => mockBackend.setPendingEvent(any())).called(1);
    });

    testWidgets('shows date validation error when end is before start', (tester) async {
      await _pumpApp(tester);
      
      final state = tester.state<CreateEventScreenState>(find.byType(CreateEventScreen));
      state.setState(() {
        state.startDate = DateTime(2026, 10, 10, 12);
        state.endDate = DateTime(2026, 10, 10, 10);
      });
      await tester.pump();
      
      final submitBtn = find.byKey(const Key('submit_event_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      
      expect(find.textContaining('must be after'), findsOneWidget);
    });

    testWidgets('handles image selection and removal', (tester) async {
      await _pumpApp(tester);
      
      final mockFile = MockXFile();
      when(() => mockFile.path).thenReturn('test_path');
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));

      final state = tester.state<CreateEventScreenState>(find.byType(CreateEventScreen));
      state.bannerImage = mockFile;
      await tester.pump();
      
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      expect(find.text('Upload Event Banner'), findsOneWidget);
    });

    testWidgets('banner hover interaction', (tester) async {
      await _pumpApp(tester);
      final bannerArea = find.text('Upload Event Banner');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(bannerArea));
      await tester.pump();
      await gesture.removePointer();
    });
  });
}
