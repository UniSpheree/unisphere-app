import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unisphere_app/screens/discover_event_screen.dart';
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

  testWidgets('diagnostic: print all text with events', (tester) async {
    tester.view.physicalSize = Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(MaterialApp(home: DiscoverEventScreen()));
    await tester.pumpAndSettle();

    final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList();
    print('ALL TEXTS WITH EVENTS: $texts');
  });
}
