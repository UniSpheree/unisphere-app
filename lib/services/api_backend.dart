import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/database_models.dart';

class SqliteBackend extends ChangeNotifier {
  SqliteBackend._internal();

  static final SqliteBackend _instance = SqliteBackend._internal();
  factory SqliteBackend() => _instance;
  factory SqliteBackend.getInstance() => _instance;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  final http.Client _client = http.Client();

  DbUser? _currentUser;
  final List<DbPurchasedTicket> _purchasedTickets = [];
  final List<Map<String, dynamic>> _cachedEvents = [];
  DbPurchasedTicket? _pendingPurchase;
  Map<String, dynamic>? _pendingEvent;

  String _baseUrl = _defaultBaseUrl;

  static const String _kCurrentUserKey = 'current_user';

  DbUser? get currentUser => _currentUser;
  List<DbPurchasedTicket> get purchasedTickets =>
      List.unmodifiable(_purchasedTickets);
  List<Map<String, dynamic>> get events => List.unmodifiable(_cachedEvents);

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<http.Response> _get(String path) => _client.get(_uri(path));
  Future<http.Response> _delete(String path) => _client.delete(_uri(path));
  Future<http.Response> _post(String path, Map<String, dynamic> body) =>
      _client.post(
        _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
  Future<http.Response> _put(String path, Map<String, dynamic> body) =>
      _client.put(
        _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

  Future<void> _saveCurrentUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser == null) {
        await prefs.remove(_kCurrentUserKey);
        return;
      }
      await prefs.setString(
        _kCurrentUserKey,
        jsonEncode(_currentUser!.toMap()),
      );
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCurrentUserKey);
      if (raw == null || raw.isEmpty) return;
      _currentUser = DbUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      print('Error loading saved user: $e');
    }
  }

  Future<void> _clearSavedUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCurrentUserKey);
    } catch (e) {
      print('Error clearing saved user: $e');
    }
  }

  Future<void> initializeDatabase() async {
    try {
      await _loadSavedUser();
      final response = await _get('/health');
      if (response.statusCode != 200) {
        throw Exception('Backend not available');
      }
      await _loadEventsFromApi();
      print('✓ API backend initialized successfully');
    } catch (e) {
      print('✗ Error initializing API backend: $e');
    }
  }

  Future<void> _loadEventsFromApi() async {
    try {
      final response = await _get('/events');
      if (response.statusCode != 200) {
        throw Exception('Failed to load events');
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      final loaded = <Map<String, dynamic>>[];

      for (final item in list) {
        final raw = Map<String, dynamic>.from(item as Map);
        final eventMap = await _mapEventFromApi(raw);
        loaded.add(eventMap);
      }

      _cachedEvents
        ..clear()
        ..addAll(loaded);

      _pruneStalePurchasedTickets();
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void _pruneStalePurchasedTickets() {
    if (_purchasedTickets.isEmpty) return;

    bool eventExistsForTicket(DbPurchasedTicket ticket) {
      for (final event in _cachedEvents) {
        final eventId = int.tryParse(event['id']?.toString() ?? '');
        if (ticket.eventId != null && eventId == ticket.eventId) {
          return true;
        }
      }

      for (final event in _cachedEvents) {
        final sameTitle = event['title']?.toString() == ticket.title;
        final sameDate = event['date']?.toString() == ticket.date;
        final sameLocation = event['location']?.toString() == ticket.location;
        if (sameTitle && sameDate && sameLocation) {
          return true;
        }
      }

      return false;
    }

    _purchasedTickets.removeWhere((ticket) => !eventExistsForTicket(ticket));
  }

  Future<Map<String, dynamic>> _mapEventFromApi(
    Map<String, dynamic> raw,
  ) async {
    final organizerEmail = raw['organizerEmail']?.toString() ?? '';
    final map = <String, dynamic>{
      'id': raw['id'],
      'title': raw['title']?.toString() ?? '',
      'date': raw['date']?.toString() ?? '',
      'endDate': raw['endDate']?.toString(),
      'location': raw['location']?.toString() ?? '',
      'category': raw['category']?.toString() ?? '',
      'description': raw['description']?.toString() ?? '',
      'organizerEmail': organizerEmail,
      'maxAttendees': raw['maxAttendees'] ?? raw['capacity'],
      'capacity': raw['capacity'] ?? raw['maxAttendees'],
      'ticketsSold': raw['ticketsSold'] ?? 0,
      'visibility': raw['visibility']?.toString() ?? 'Public',
      'createdAt':
          raw['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      'updatedAt': raw['updatedAt']?.toString(),
      'bannerImageUrl': raw['bannerImageUrl']?.toString(),
    };

    // Fetch organizer name
    if (organizerEmail.isNotEmpty) {
      try {
        final response = await _get('/profiles/$organizerEmail');
        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body) as Map<String, dynamic>;
          final firstName = userData['firstName']?.toString() ?? '';
          final lastName = userData['lastName']?.toString() ?? '';
          map['organizer'] = '$firstName $lastName'.trim();
        } else {
          map['organizer'] = 'UniSphere';
        }
      } catch (e) {
        print('Error fetching organizer: $e');
        map['organizer'] = 'UniSphere';
      }
    } else {
      map['organizer'] = 'UniSphere';
    }

    final bannerUrl = map['bannerImageUrl'] as String?;
    if (bannerUrl != null && bannerUrl.isNotEmpty) {
      try {
        final bytes = await _client.get(Uri.parse(bannerUrl));
        if (bytes.statusCode == 200) {
          map['bannerImageData'] = bytes.bodyBytes;
        }
      } catch (e) {
        print('Error loading banner image: $e');
      }
    }

    return map;
  }

  DbUser _userFromApi(Map<String, dynamic> json) {
    return DbUser(
      id: json['id'] as int?,
      email: json['email']?.toString() ?? '',
      password: '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Attendee',
      university: json['university']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isApproved: json['isApproved'] == true,
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  DbPurchasedTicket _ticketFromApi(Map<String, dynamic> json) {
    return DbPurchasedTicket(
      id: json['id'] as int?,
      userEmail: json['userEmail']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      purchasedAt: DateTime.parse(
        json['purchasedAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      eventId: json['eventId'] as int?,
    );
  }

  void setPendingPurchase(DbPurchasedTicket ticket) {
    _pendingPurchase = ticket;
  }

  void setPendingEvent(Map<String, dynamic> eventData) {
    _pendingEvent = Map<String, dynamic>.from(eventData);
  }

  Future<void> _completePendingPurchaseInternal() async {
    if (_currentUser == null || _pendingPurchase == null) return;

    final ticket = _pendingPurchase!;
    final payload = {
      'userEmail': _currentUser!.email,
      'title': ticket.title,
      'date': ticket.date,
      'location': ticket.location,
      'category': ticket.category,
      'price': ticket.price,
      'eventId': ticket.eventId,
    };

    final response = await _post('/tickets', payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final created = _ticketFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      _purchasedTickets.add(created);
      _pendingPurchase = null;
      notifyListeners();
    } else {
      throw Exception('Failed to create ticket');
    }
  }

  Future<String> _createEventInternal(Map<String, dynamic> eventData) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    final payload = {
      'title': eventData['title']?.toString() ?? '',
      'date': eventData['date']?.toString() ?? '',
      'endDate': eventData['endDate']?.toString(),
      'location': eventData['location']?.toString() ?? '',
      'category': eventData['category']?.toString() ?? '',
      'description': eventData['description']?.toString() ?? '',
      'maxAttendees': eventData['maxAttendees'],
      'visibility': eventData['visibility']?.toString() ?? 'Public',
      'organizerEmail': _currentUser!.email,
      'bannerImageBase64': eventData['bannerImageData'] is Uint8List
          ? base64Encode(eventData['bannerImageData'] as Uint8List)
          : null,
    };

    final response = await _post('/events', payload);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Failed to create event',
      );
    }

    final event = jsonDecode(response.body) as Map<String, dynamic>;
    // Reload events to ensure organizer name is fetched
    await _loadEventsFromApi();
    notifyListeners();
    return event['id'].toString();
  }

  Future<void> _completePendingEventInternal() async {
    if (_currentUser == null || _pendingEvent == null) return;
    final payload = Map<String, dynamic>.from(_pendingEvent!);
    payload['organizerEmail'] = _currentUser!.email;
    await _createEventInternal(payload);
    _pendingEvent = null;
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    await _loadEventsFromApi();
    return events;
  }

  Future<Map<String, dynamic>?> getEventById(String id) async {
    try {
      final response = await _get('/events/$id');
      if (response.statusCode != 200) return null;
      return await _mapEventFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String university,
    required bool isApproved,
  }) async {
    try {
      final response = await _post('/auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'university': university,
        'description': '',
        'isApproved': isApproved,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Registration failed: ${response.body}');
        return false;
      }

      _currentUser = _userFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveCurrentUserToPrefs();
      await _loadEventsFromApi();
      await _completePendingPurchaseInternal();
      await _completePendingEventInternal();
      notifyListeners();
      print('✓ Registration successful for email: ${_currentUser!.email}');
      return true;
    } catch (e) {
      print('❌ Error registering: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode != 200) {
        print('❌ Login failed: ${response.body}');
        return false;
      }

      _currentUser = _userFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveCurrentUserToPrefs();
      // Load events first so we can validate purchased tickets against them
      await _loadEventsFromApi();
      final ticketsResponse = await _get(
        '/tickets/${Uri.encodeComponent(_currentUser!.email)}',
      );
      _purchasedTickets
        ..clear()
        ..addAll(
          (jsonDecode(ticketsResponse.body) as List<dynamic>).map(
            (item) => _ticketFromApi(Map<String, dynamic>.from(item as Map)),
          ),
        );
      // Prune any tickets that do not match loaded events
      _pruneStalePurchasedTickets();
      await _completePendingPurchaseInternal();
      await _completePendingEventInternal();
      notifyListeners();
      print('✓ Login successful for: ${_currentUser!.email}');
      return true;
    } catch (e) {
      print('❌ Error logging in: $e');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _post('/auth/forgot-password', {'email': email});
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['exists'] == true;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _post('/auth/reset-password', {
        'email': email,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  Future<DbUser?> updateCurrentUserProfile({
    required String name,
    required String description,
  }) async {
    final current = _currentUser;
    if (current == null) return null;

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final firstName = parts.isNotEmpty ? parts.first : current.firstName;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : current.lastName;

    try {
      final response =
          await _put('/profiles/${Uri.encodeComponent(current.email)}', {
            'firstName': firstName,
            'lastName': lastName,
            'description': description.trim(),
          });
      if (response.statusCode != 200) return null;
      _currentUser = _userFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveCurrentUserToPrefs();
      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  Future<DbUser?> updateCurrentUserRole(String role) async {
    final current = _currentUser;
    if (current == null) return null;

    try {
      final response = await _put(
        '/profiles/${Uri.encodeComponent(current.email)}/role',
        {'role': role},
      );
      if (response.statusCode != 200) return null;
      _currentUser = _userFromApi(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _saveCurrentUserToPrefs();
      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error updating role: $e');
      return null;
    }
  }

  Future<String> createEvent(Map<String, dynamic> eventData) async {
    final id = await _createEventInternal(eventData);
    await _loadEventsFromApi();
    return id;
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> updated) async {
    try {
      final payload = Map<String, dynamic>.from(updated);
      if (payload['removeBannerImage'] == true) {
        payload['bannerImageBase64'] = null;
      }
      if (payload['bannerImageData'] is Uint8List) {
        payload['bannerImageBase64'] = base64Encode(
          payload['bannerImageData'] as Uint8List,
        );
      }
      payload.remove('bannerImageData');
      payload.remove('removeBannerImage');
      final response = await _put('/events/$id', payload);
      if (response.statusCode != 200) return false;
      await _loadEventsFromApi();
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      final response = await _delete('/events/$id');
      if (response.statusCode != 200) return false;
      await _loadEventsFromApi();
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    final current = _currentUser;
    if (current == null) return false;

    try {
      final response = await _delete(
        '/tickets/${Uri.encodeComponent(current.email)}/$ticketId',
      );
      if (response.statusCode != 200) {
        print('Delete ticket failed: ${response.statusCode} ${response.body}');
        return false;
      }

      _purchasedTickets.removeWhere(
        (ticket) => ticket.id?.toString() == ticketId,
      );
      _pruneStalePurchasedTickets();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  Future<bool> purchaseTicket(DbPurchasedTicket ticket) async {
    if (_currentUser == null) {
      _pendingPurchase = ticket;
      notifyListeners();
      return true;
    }

    final effective = DbPurchasedTicket(
      userEmail: _currentUser!.email,
      title: ticket.title,
      date: ticket.date,
      location: ticket.location,
      category: ticket.category,
      price: ticket.price,
      purchasedAt: ticket.purchasedAt,
      eventId: ticket.eventId,
    );

    try {
      _pendingPurchase = effective;
      await _completePendingPurchaseInternal();
      await _loadEventsFromApi();
      return true;
    } catch (e) {
      print('Error purchasing ticket: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _purchasedTickets.clear();
    _pendingPurchase = null;
    _pendingEvent = null;
    _clearSavedUserFromPrefs();
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    final current = _currentUser;
    if (current == null) return false;
    try {
      final response = await _delete(
        '/auth/users/${Uri.encodeComponent(current.email)}',
      );
      if (response.statusCode == 200) {
        _currentUser = null;
        _purchasedTickets.clear();
        _cachedEvents.clear();
        await _clearSavedUserFromPrefs();
        notifyListeners();
        return true;
      }
      print('Delete account failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}
