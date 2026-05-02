import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/models/database_models.dart';

void main() {
  group('DbUser Tests', () {
    final now = DateTime.now();
    final user = DbUser(
      id: 1,
      email: 'test@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      role: 'student',
      university: 'Oxford',
      description: 'A student',
      isApproved: true,
      createdAt: now,
    );

    test('toMap() converts object to map correctly', () {
      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['email'], 'test@example.com');
      expect(map['isApproved'], 1);
      expect(map['createdAt'], now.toIso8601String());
    });

    test('fromMap() creates object from map correctly', () {
      final map = {
        'id': 2,
        'email': 'jane@example.com',
        'password': 'password456',
        'firstName': 'Jane',
        'lastName': 'Smith',
        'role': 'organiser',
        'university': 'Cambridge',
        'description': 'An organiser',
        'isApproved': 0,
        'createdAt': now.toIso8601String(),
      };
      final newUser = DbUser.fromMap(map);
      expect(newUser.id, 2);
      expect(newUser.email, 'jane@example.com');
      expect(newUser.isApproved, false);
      expect(newUser.isOrganiser, true);
    });

    test('copyWith() updates fields correctly', () {
      final updatedUser = user.copyWith(firstName: 'Johnny', isApproved: false);
      expect(updatedUser.firstName, 'Johnny');
      expect(updatedUser.lastName, 'Doe');
      expect(updatedUser.isApproved, false);
      expect(updatedUser.id, 1);
    });

    test('fullName returns correct string', () {
      expect(user.fullName, 'John Doe');
    });

    test('isOrganiser returns correct boolean', () {
      final student = user;
      final organiser = user.copyWith(role: 'organiser');
      expect(student.isOrganiser, false);
      expect(organiser.isOrganiser, true);
    });
  });

  group('DbEvent Tests', () {
    final now = DateTime.now();
    final event = DbEvent(
      id: 1,
      title: 'Tech Talk',
      date: '2023-12-01',
      location: 'Room 101',
      category: 'Workshop',
      description: 'Learning Flutter',
      organizerEmail: 'org@example.com',
      createdAt: now,
    );

    test('toMap() and fromMap() are symmetrical', () {
      final map = event.toMap();
      final fromMapEvent = DbEvent.fromMap(map);
      
      expect(fromMapEvent.id, event.id);
      expect(fromMapEvent.title, event.title);
      expect(fromMapEvent.organizerEmail, event.organizerEmail);
      expect(fromMapEvent.createdAt.toIso8601String(), event.createdAt.toIso8601String());
    });

    test('bannerImageData is handled correctly', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final eventWithImage = event.copyWith(bannerImageData: data);
      final map = eventWithImage.toMap();
      final fromMapEvent = DbEvent.fromMap(map);
      
      expect(fromMapEvent.bannerImageData, data);
    });
  });

  group('DbPurchasedTicket Tests', () {
    final now = DateTime.now();
    final ticket = DbPurchasedTicket(
      id: 1,
      userEmail: 'user@example.com',
      title: 'Concert',
      date: '2023-12-05',
      location: 'Arena',
      category: 'Music',
      price: '\$50',
      purchasedAt: now,
    );

    test('toMap() and fromMap() are symmetrical', () {
      final map = ticket.toMap();
      final fromMapTicket = DbPurchasedTicket.fromMap(map);
      
      expect(fromMapTicket.id, ticket.id);
      expect(fromMapTicket.userEmail, ticket.userEmail);
      expect(fromMapTicket.purchasedAt.toIso8601String(), ticket.purchasedAt.toIso8601String());
    });
  });
}
