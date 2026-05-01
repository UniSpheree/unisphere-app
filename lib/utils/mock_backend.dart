import 'dart:async';

import 'package:flutter/foundation.dart';

class MockUser {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String university;
  final String description;
  final bool isApproved;

  MockUser({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.university,
    this.description = '',
    required this.isApproved,
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get isOrganiser => role.toLowerCase() == 'organiser';
}

class PurchasedTicket {
  final String title;
  final String date;
  final String location;
  final String category;
  final String price;

  PurchasedTicket({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.price,
  });
}

class _Event {
  final String id;
  final String title;
  final String date;
  final String? endDate;
  final String location;
  final String category;
  final String description;
  final String? organizerEmail;

  const _Event({
    required this.id,
    required this.title,
    required this.date,
    this.endDate,
    required this.location,
    required this.category,
    required this.description,
    this.organizerEmail,
  });

  factory _Event.fromMap(Map<String, dynamic> m) {
    return _Event(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      date: m['date']?.toString() ?? '',
      endDate: m['endDate']?.toString(),
      location: m['location']?.toString() ?? '',
      category: m['category']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      organizerEmail: m['organizerEmail']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'date': date,
    'endDate': endDate,
    'location': location,
    'category': category,
    'description': description,
    'organizerEmail': organizerEmail,
  };

  bool get isEmpty => id.isEmpty;

  factory _Event.empty() => const _Event(
    id: '',
    title: '',
    date: '',
    location: '',
    category: '',
    description: '',
  );
}

class MockBackend extends ChangeNotifier {
  MockUser? _currentUser;
  final List<PurchasedTicket> _purchasedTickets = [];
  PurchasedTicket? _pendingPurchase;
  final List<_Event> _events = [
    _Event(
      id: 'e1',
      title: 'Welcome Mixer',
      date: '2024-06-20',
      location: 'Main Hall',
      category: 'Social',
      description: 'Meet and greet with new students',
      organizerEmail: 'organiser@example.com',
    ),
    _Event(
      id: 'e2',
      title: 'Tech Talk',
      date: '2024-07-05',
      location: 'Auditorium',
      category: 'Tech',
      description: 'AI and the future of computing',
      organizerEmail: 'organiser@example.com',
    ),
  ];

  MockUser? get currentUser => _currentUser;

  List<PurchasedTicket> get purchasedTickets =>
      List.unmodifiable(_purchasedTickets);

  List<Map<String, dynamic>> get events =>
      List.unmodifiable(_events.map((e) => e.toMap()).toList());

  Map<String, dynamic>? getEventById(String id) {
    final ev = _events.firstWhere(
      (e) => e.id == id,
      orElse: () => _Event.empty(),
    );
    if (ev.isEmpty) return null;
    return ev.toMap();
  }

  void purchaseTicket(PurchasedTicket ticket) {
    _purchasedTickets.add(ticket);
    notifyListeners();
  }

  void setPendingPurchase(PurchasedTicket ticket) {
    _pendingPurchase = ticket;
  }

  void _completePendingPurchaseInternal() {
    if (_currentUser != null && _pendingPurchase != null) {
      _purchasedTickets.add(_pendingPurchase!);
      _pendingPurchase = null;
      notifyListeners();
    }
  }

  Future<String> createEvent(Map<String, dynamic> eventData) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ev = _Event.fromMap({...eventData, 'id': id});
    _events.add(ev);
    notifyListeners();
    return id;
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> updated) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final idx = _events.indexWhere((e) => e.id == id);
    if (idx == -1) return false;
    final merged = _events[idx].toMap()..addAll(updated);
    _events[idx] = _Event.fromMap(merged);
    notifyListeners();
    return true;
  }

  Future<bool> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 160));
    final before = _events.length;
    _events.removeWhere((e) => e.id == id);
    final removed = _events.length < before;
    if (removed) notifyListeners();
    return removed;
  }

  Future<MockUser?> updateCurrentUserProfile({
    required String name,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final current = _currentUser;
    if (current == null) return null;

    final trimmedName = name.trim();
    final nameParts = trimmedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final updatedUser = MockUser(
      email: current.email,
      password: current.password,
      firstName: nameParts.isNotEmpty ? nameParts.first : current.firstName,
      lastName: nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : current.lastName,
      role: current.role,
      university: current.university,
      description: description.trim(),
      isApproved: current.isApproved,
    );
    _currentUser = updatedUser;
    notifyListeners();
    return updatedUser;
  }

  Future<MockUser?> updateCurrentUserRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final current = _currentUser;
    if (current == null) return null;

    final normalizedRole = role.trim().isEmpty ? current.role : role.trim();
    final updatedUser = MockUser(
      email: current.email,
      password: current.password,
      firstName: current.firstName,
      lastName: current.lastName,
      role: normalizedRole,
      university: current.university,
      description: current.description,
      isApproved: current.isApproved,
    );
    _currentUser = updatedUser;

    final index = _users.indexWhere((u) => u.email == current.email);
    if (index != -1) {
      _users[index] = updatedUser;
    }

    notifyListeners();
    return updatedUser;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final user in _users) {
      if (user.email == email) {
        _users[_users.indexOf(user)] = MockUser(
          email: user.email,
          password: newPassword,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          university: user.university,
          description: user.description,
          isApproved: user.isApproved,
        );
        if (_currentUser?.email == email) {
          _currentUser = _users.firstWhere((u) => u.email == email);
          notifyListeners();
        }
        return true;
      }
    }
    return false;
  }

  static final MockBackend _instance = MockBackend._internal();
  factory MockBackend() => _instance;
  MockBackend._internal();

  final List<MockUser> _users = [];

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String university,
    required bool isApproved,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.any((u) => u.email == email)) return false;
    final user = MockUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      university: university,
      description: '',
      isApproved: isApproved,
    );
    _users.add(user);
    _currentUser = user;
    _completePendingPurchaseInternal();
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _users
        .where((u) => u.email == email && u.password == password)
        .toList();
    if (user.isNotEmpty) {
      _currentUser = user.first;
      _completePendingPurchaseInternal();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.any((u) => u.email == email);
  }

  // For testing/demo
  void clear() {
    _users.clear();
    _purchasedTickets.clear();
    _currentUser = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  List<MockUser> get users => List.unmodifiable(_users);
}
