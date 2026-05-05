import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Ensure singleton is reset to clean state by injecting clear user
    SqliteBackend().injectMockState(user: null, mockEvents: []);
  });

  test('injectMockState sets user and events and logout clears them', () async {
    final backend = SqliteBackend();
    final user = DbUser(
      id: 5,
      email: 'test@uni.ac.uk',
      password: 'pw',
      firstName: 'T',
      lastName: 'User',
      role: 'Attendee',
      university: 'U',
      description: '',
      isApproved: true,
      createdAt: DateTime.now(),
    );

    final mockEvents = [
      {'id': 1, 'title': 'A'},
    ];

    backend.injectMockState(user: user, mockEvents: mockEvents);
    expect(backend.currentUser?.email, 'test@uni.ac.uk');
    expect(backend.events.length, 1);

    backend.logout();
    expect(backend.currentUser, isNull);
    expect(backend.events, isNotEmpty);
    expect(backend.pendingPurchase, isNull);
    expect(backend.pendingEvent, isNull);
  });

  test('setPendingPurchase and setPendingEvent store pending state', () async {
    final backend = SqliteBackend();
    final ticket = DbPurchasedTicket(
      id: null,
      userEmail: 'a@b.com',
      title: 'Title',
      date: '2024-01-01',
      location: 'Loc',
      category: 'Cat',
      price: '0',
      purchasedAt: DateTime.now(),
    );

    backend.setPendingPurchase(ticket);
    expect(backend.pendingPurchase, isNotNull);

    backend.setPendingEvent({'id': 2, 'title': 'Evt'});
    expect(backend.pendingEvent, isNotNull);
  });
}
