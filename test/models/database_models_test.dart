import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/models/database_models.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // DbUser
  // ─────────────────────────────────────────────────────────────────────────
  group('DbUser', () {
    final createdAt = DateTime(2024, 1, 15, 10, 30);

    DbUser _makeUser({
      int? id = 1,
      String email = 'alice@uni.ac.uk',
      String password = 'secret',
      String firstName = 'Alice',
      String lastName = 'Smith',
      String role = 'Attendee',
      String university = 'UniSphere University',
      String description = 'A test user',
      bool isApproved = true,
      DateTime? createdAt,
    }) {
      return DbUser(
        id: id,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        university: university,
        description: description,
        isApproved: isApproved,
        createdAt: createdAt ?? DateTime(2024, 1, 15, 10, 30),
      );
    }

    // ── Constructor & getters ──────────────────────────────────────────────

    test('stores all fields correctly', () {
      final user = _makeUser();

      expect(user.id, 1);
      expect(user.email, 'alice@uni.ac.uk');
      expect(user.password, 'secret');
      expect(user.firstName, 'Alice');
      expect(user.lastName, 'Smith');
      expect(user.role, 'Attendee');
      expect(user.university, 'UniSphere University');
      expect(user.description, 'A test user');
      expect(user.isApproved, isTrue);
      expect(user.createdAt, DateTime(2024, 1, 15, 10, 30));
    });

    test('id is nullable – can be null when not yet persisted', () {
      final user = _makeUser(id: null);
      expect(user.id, isNull);
    });

    // ── fullName getter ────────────────────────────────────────────────────

    test('fullName returns "firstName lastName"', () {
      final user = _makeUser(firstName: 'Alice', lastName: 'Smith');
      expect(user.fullName, 'Alice Smith');
    });

    test('fullName trims leading/trailing whitespace', () {
      // trim() removes nothing when both parts are present, but guard the edge
      final user = _makeUser(firstName: 'Alice', lastName: '');
      expect(user.fullName, 'Alice');
    });

    // ── isOrganiser getter ─────────────────────────────────────────────────

    test('isOrganiser returns true when role is "organiser" (lowercase)', () {
      final user = _makeUser(role: 'organiser');
      expect(user.isOrganiser, isTrue);
    });

    test('isOrganiser returns true when role is "Organiser" (mixed case)', () {
      final user = _makeUser(role: 'Organiser');
      expect(user.isOrganiser, isTrue);
    });

    test('isOrganiser returns true when role is "ORGANISER" (uppercase)', () {
      final user = _makeUser(role: 'ORGANISER');
      expect(user.isOrganiser, isTrue);
    });

    test('isOrganiser returns false for non-organiser roles', () {
      final user = _makeUser(role: 'Attendee');
      expect(user.isOrganiser, isFalse);
    });

    // ── toMap ──────────────────────────────────────────────────────────────

    test('toMap serialises all fields correctly when isApproved is true', () {
      final user = _makeUser(isApproved: true);
      final map = user.toMap();

      expect(map['id'], 1);
      expect(map['email'], 'alice@uni.ac.uk');
      expect(map['password'], 'secret');
      expect(map['firstName'], 'Alice');
      expect(map['lastName'], 'Smith');
      expect(map['role'], 'Attendee');
      expect(map['university'], 'UniSphere University');
      expect(map['description'], 'A test user');
      expect(map['isApproved'], 1);
      expect(map['createdAt'], DateTime(2024, 1, 15, 10, 30).toIso8601String());
    });

    test('toMap serialises isApproved=false as 0', () {
      final user = _makeUser(isApproved: false);
      expect(user.toMap()['isApproved'], 0);
    });

    test('toMap includes null id when not set', () {
      final user = _makeUser(id: null);
      expect(user.toMap()['id'], isNull);
    });

    // ── fromMap ────────────────────────────────────────────────────────────

    test('fromMap round-trips toMap correctly', () {
      final original = _makeUser();
      final restored = DbUser.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.email, original.email);
      expect(restored.password, original.password);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.role, original.role);
      expect(restored.university, original.university);
      expect(restored.description, original.description);
      expect(restored.isApproved, original.isApproved);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromMap deserialises isApproved=1 as true', () {
      final map = _makeUser(isApproved: true).toMap();
      final user = DbUser.fromMap(map);
      expect(user.isApproved, isTrue);
    });

    test('fromMap deserialises isApproved=0 as false', () {
      final map = _makeUser(isApproved: false).toMap();
      final user = DbUser.fromMap(map);
      expect(user.isApproved, isFalse);
    });

    test('fromMap uses empty string when description is null in map', () {
      final map = _makeUser().toMap()..['description'] = null;
      final user = DbUser.fromMap(map);
      expect(user.description, '');
    });

    test('fromMap accepts null id', () {
      final map = _makeUser(id: null).toMap();
      final user = DbUser.fromMap(map);
      expect(user.id, isNull);
    });

    // ── copyWith ───────────────────────────────────────────────────────────

    test('copyWith with no arguments returns equivalent object', () {
      final user = _makeUser();
      final copy = user.copyWith();

      expect(copy.id, user.id);
      expect(copy.email, user.email);
      expect(copy.password, user.password);
      expect(copy.firstName, user.firstName);
      expect(copy.lastName, user.lastName);
      expect(copy.role, user.role);
      expect(copy.university, user.university);
      expect(copy.description, user.description);
      expect(copy.isApproved, user.isApproved);
      expect(copy.createdAt, user.createdAt);
    });

    test('copyWith overrides individual fields', () {
      final user = _makeUser();
      final newDate = DateTime(2025, 6, 1);

      final copy = user.copyWith(
        id: 99,
        email: 'bob@uni.ac.uk',
        password: 'newpassword',
        firstName: 'Bob',
        lastName: 'Jones',
        role: 'Organiser',
        university: 'Other U',
        description: 'Updated',
        isApproved: false,
        createdAt: newDate,
      );

      expect(copy.id, 99);
      expect(copy.email, 'bob@uni.ac.uk');
      expect(copy.password, 'newpassword');
      expect(copy.firstName, 'Bob');
      expect(copy.lastName, 'Jones');
      expect(copy.role, 'Organiser');
      expect(copy.university, 'Other U');
      expect(copy.description, 'Updated');
      expect(copy.isApproved, isFalse);
      expect(copy.createdAt, newDate);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DbEvent
  // ─────────────────────────────────────────────────────────────────────────
  group('DbEvent', () {
    final createdAt = DateTime(2024, 3, 10, 9, 0);
    final updatedAt = DateTime(2024, 3, 11, 12, 0);
    final banner = Uint8List.fromList([1, 2, 3, 4, 5]);

    DbEvent _makeEvent({
      int? id = 10,
      String title = 'Tech Symposium',
      String date = '2024-04-01T09:00:00.000',
      String? endDate = '2024-04-01T17:00:00.000',
      String location = 'Room 101',
      String category = 'Academic',
      String description = 'A great event',
      String organizerEmail = 'organiser@uni.ac.uk',
      Uint8List? bannerImageData,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return DbEvent(
        id: id,
        title: title,
        date: date,
        endDate: endDate,
        location: location,
        category: category,
        description: description,
        organizerEmail: organizerEmail,
        bannerImageData: bannerImageData,
        createdAt: createdAt ?? DateTime(2024, 3, 10, 9, 0),
        updatedAt: updatedAt,
      );
    }

    // ── Constructor ────────────────────────────────────────────────────────

    test('stores all fields correctly', () {
      final event = _makeEvent(bannerImageData: banner, updatedAt: updatedAt);

      expect(event.id, 10);
      expect(event.title, 'Tech Symposium');
      expect(event.date, '2024-04-01T09:00:00.000');
      expect(event.endDate, '2024-04-01T17:00:00.000');
      expect(event.location, 'Room 101');
      expect(event.category, 'Academic');
      expect(event.description, 'A great event');
      expect(event.organizerEmail, 'organiser@uni.ac.uk');
      expect(event.bannerImageData, banner);
      expect(event.createdAt, DateTime(2024, 3, 10, 9, 0));
      expect(event.updatedAt, updatedAt);
    });

    test('optional fields default to null', () {
      final event = _makeEvent(id: null, endDate: null, updatedAt: null);

      expect(event.id, isNull);
      expect(event.endDate, isNull);
      expect(event.bannerImageData, isNull);
      expect(event.updatedAt, isNull);
    });

    // ── toMap ──────────────────────────────────────────────────────────────

    test('toMap serialises all fields including optionals', () {
      final event = _makeEvent(bannerImageData: banner, updatedAt: updatedAt);
      final map = event.toMap();

      expect(map['id'], 10);
      expect(map['title'], 'Tech Symposium');
      expect(map['date'], '2024-04-01T09:00:00.000');
      expect(map['endDate'], '2024-04-01T17:00:00.000');
      expect(map['location'], 'Room 101');
      expect(map['category'], 'Academic');
      expect(map['description'], 'A great event');
      expect(map['organizerEmail'], 'organiser@uni.ac.uk');
      expect(map['bannerImageData'], banner);
      expect(map['createdAt'], DateTime(2024, 3, 10, 9, 0).toIso8601String());
      expect(map['updatedAt'], updatedAt.toIso8601String());
    });

    test('toMap serialises null optional fields as null', () {
      final event = _makeEvent(endDate: null, updatedAt: null);
      final map = event.toMap();

      expect(map['endDate'], isNull);
      expect(map['bannerImageData'], isNull);
      expect(map['updatedAt'], isNull);
    });

    // ── fromMap ────────────────────────────────────────────────────────────

    test('fromMap round-trips toMap correctly (with all optionals)', () {
      final original = _makeEvent(bannerImageData: banner, updatedAt: updatedAt);
      final map = original.toMap();
      final restored = DbEvent.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.date, original.date);
      expect(restored.endDate, original.endDate);
      expect(restored.location, original.location);
      expect(restored.category, original.category);
      expect(restored.description, original.description);
      expect(restored.organizerEmail, original.organizerEmail);
      expect(restored.bannerImageData, banner);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('fromMap handles null updatedAt', () {
      final map = _makeEvent(updatedAt: null).toMap();
      final event = DbEvent.fromMap(map);
      expect(event.updatedAt, isNull);
    });

    test('fromMap handles null endDate', () {
      final map = _makeEvent(endDate: null).toMap();
      final event = DbEvent.fromMap(map);
      expect(event.endDate, isNull);
    });

    test('fromMap handles null bannerImageData', () {
      final map = _makeEvent().toMap();
      final event = DbEvent.fromMap(map);
      expect(event.bannerImageData, isNull);
    });

    test('fromMap accepts null id', () {
      final map = _makeEvent(id: null).toMap();
      final event = DbEvent.fromMap(map);
      expect(event.id, isNull);
    });

    // ── copyWith ───────────────────────────────────────────────────────────

    test('copyWith with no arguments returns equivalent object', () {
      final event = _makeEvent(bannerImageData: banner, updatedAt: updatedAt);
      final copy = event.copyWith();

      expect(copy.id, event.id);
      expect(copy.title, event.title);
      expect(copy.date, event.date);
      expect(copy.endDate, event.endDate);
      expect(copy.location, event.location);
      expect(copy.category, event.category);
      expect(copy.description, event.description);
      expect(copy.organizerEmail, event.organizerEmail);
      expect(copy.bannerImageData, event.bannerImageData);
      expect(copy.createdAt, event.createdAt);
      expect(copy.updatedAt, event.updatedAt);
    });

    test('copyWith overrides individual fields', () {
      final event = _makeEvent();
      final newCreatedAt = DateTime(2025, 1, 1);
      final newUpdatedAt = DateTime(2025, 1, 2);
      final newBanner = Uint8List.fromList([9, 8, 7]);

      final copy = event.copyWith(
        id: 99,
        title: 'New Title',
        date: '2025-05-01',
        endDate: '2025-05-02',
        location: 'Online',
        category: 'Social',
        description: 'Updated description',
        organizerEmail: 'new@org.com',
        bannerImageData: newBanner,
        createdAt: newCreatedAt,
        updatedAt: newUpdatedAt,
      );

      expect(copy.id, 99);
      expect(copy.title, 'New Title');
      expect(copy.date, '2025-05-01');
      expect(copy.endDate, '2025-05-02');
      expect(copy.location, 'Online');
      expect(copy.category, 'Social');
      expect(copy.description, 'Updated description');
      expect(copy.organizerEmail, 'new@org.com');
      expect(copy.bannerImageData, newBanner);
      expect(copy.createdAt, newCreatedAt);
      expect(copy.updatedAt, newUpdatedAt);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DbPurchasedTicket
  // ─────────────────────────────────────────────────────────────────────────
  group('DbPurchasedTicket', () {
    final purchasedAt = DateTime(2024, 4, 1, 14, 0);

    DbPurchasedTicket _makeTicket({
      int? id = 5,
      String userEmail = 'alice@uni.ac.uk',
      String title = 'Tech Symposium',
      String date = '2024-04-10',
      String location = 'Room 101',
      String category = 'Academic',
      String price = 'Free',
      DateTime? purchasedAt,
      int? eventId = 10,
    }) {
      return DbPurchasedTicket(
        id: id,
        userEmail: userEmail,
        title: title,
        date: date,
        location: location,
        category: category,
        price: price,
        purchasedAt: purchasedAt ?? DateTime(2024, 4, 1, 14, 0),
        eventId: eventId,
      );
    }

    // ── Constructor ────────────────────────────────────────────────────────

    test('stores all fields correctly', () {
      final ticket = _makeTicket(purchasedAt: purchasedAt);

      expect(ticket.id, 5);
      expect(ticket.userEmail, 'alice@uni.ac.uk');
      expect(ticket.title, 'Tech Symposium');
      expect(ticket.date, '2024-04-10');
      expect(ticket.location, 'Room 101');
      expect(ticket.category, 'Academic');
      expect(ticket.price, 'Free');
      expect(ticket.purchasedAt, purchasedAt);
      expect(ticket.eventId, 10);
    });

    test('optional fields default to null', () {
      final ticket = _makeTicket(id: null, eventId: null);

      expect(ticket.id, isNull);
      expect(ticket.eventId, isNull);
    });

    // ── toMap ──────────────────────────────────────────────────────────────

    test('toMap serialises all fields correctly', () {
      final ticket = _makeTicket(purchasedAt: purchasedAt);
      final map = ticket.toMap();

      expect(map['id'], 5);
      expect(map['userEmail'], 'alice@uni.ac.uk');
      expect(map['title'], 'Tech Symposium');
      expect(map['date'], '2024-04-10');
      expect(map['location'], 'Room 101');
      expect(map['category'], 'Academic');
      expect(map['price'], 'Free');
      expect(map['purchasedAt'], purchasedAt.toIso8601String());
      expect(map['eventId'], 10);
    });

    test('toMap includes null id and eventId when not set', () {
      final ticket = _makeTicket(id: null, eventId: null);
      final map = ticket.toMap();

      expect(map['id'], isNull);
      expect(map['eventId'], isNull);
    });

    // ── fromMap ────────────────────────────────────────────────────────────

    test('fromMap round-trips toMap correctly', () {
      final original = _makeTicket(purchasedAt: purchasedAt);
      final restored = DbPurchasedTicket.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.userEmail, original.userEmail);
      expect(restored.title, original.title);
      expect(restored.date, original.date);
      expect(restored.location, original.location);
      expect(restored.category, original.category);
      expect(restored.price, original.price);
      expect(restored.purchasedAt, original.purchasedAt);
      expect(restored.eventId, original.eventId);
    });

    test('fromMap handles null id', () {
      final map = _makeTicket(id: null).toMap();
      final ticket = DbPurchasedTicket.fromMap(map);
      expect(ticket.id, isNull);
    });

    test('fromMap handles null eventId', () {
      final map = _makeTicket(eventId: null).toMap();
      final ticket = DbPurchasedTicket.fromMap(map);
      expect(ticket.eventId, isNull);
    });
  });
}
