import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/database_models.dart';
import 'database_service.dart';

/// SQLite-backed backend - mirrors MockBackend interface
/// Uses DatabaseService for all persistence
class SqliteBackend extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  DbUser? _currentUser;
  final List<DbPurchasedTicket> _purchasedTickets = [];
  final List<Map<String, dynamic>> _cachedEvents = [];
  DbPurchasedTicket? _pendingPurchase;
  Map<String, dynamic>? _pendingEvent;

  // Web fallback flag and in-memory stores
  final bool _isWeb = kIsWeb;
  final List<DbUser> _memUsers = [];
  final List<DbEvent> _memEvents = [];
  final List<DbPurchasedTicket> _memTickets = [];

  static const _prefsUsersKey = 'unisphere_users_v1';
  static const _prefsEventsKey = 'unisphere_events_v1';
  static const _prefsTicketsKey = 'unisphere_tickets_v1';
  // Hive box names
  static const _hiveUsersBox = 'unisphere_users';
  static const _hiveEventsBox = 'unisphere_events';
  static const _hiveTicketsBox = 'unisphere_tickets';

  factory SqliteBackend() => _instance;

  // ─────────────────────────────────────────────────────
  // INITIALIZATION & STATE MANAGEMENT
  // ─────────────────────────────────────────────────────

  /// Initialize the database on app startup
  Future<void> initializeDatabase() async {
    try {
      if (_isWeb) {
        // On web we can't use sqflite/path_provider. Use in-memory fallback.
        print(
          '⚠ Running in web mode: using in-memory fallback (no persistent DB)',
        );
        // Load persisted web state (if any) and populate cache from in-memory events
        await _loadWebState();
        _cachedEvents.clear();
        for (final ev in _memEvents) {
          final map = ev.toMap();
          map['id'] =
              map['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString();
          _cachedEvents.add(map);
        }
        notifyListeners();
      } else {
        // Ensure database is initialized
        await _db.database;
        // Load events from database
        await _loadEventsFromDatabase();
        print('✓ Database initialized successfully');
      }
    } catch (e) {
      print('✗ Error initializing database: $e');
    }
  }

  /// Initialize current user from database if available
  Future<void> _initializeCurrentUser() async {
    // This could be extended to load from preferences if needed
    // For now, user is loaded on login
  }

  /// Load events from database into cache
  Future<void> _loadEventsFromDatabase() async {
    try {
      if (_isWeb) {
        // ensure latest web state is loaded
        await _loadWebState();
        _cachedEvents.clear();
        for (final ev in _memEvents) {
          final map = ev.toMap();
          map['id'] =
              map['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString();
          _cachedEvents.add(map);
        }
        notifyListeners();
        return;
      }

      final events = await _db.getAllEvents();
      _cachedEvents.clear();
      for (final event in events) {
        final map = event.toMap();
        map['id'] =
            map['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        _cachedEvents.add(map);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────

  DbUser? get currentUser => _currentUser;

  List<DbPurchasedTicket> get purchasedTickets =>
      List.unmodifiable(_purchasedTickets);

  /// Synchronous getter for cached events (for UI rendering)
  List<Map<String, dynamic>> get events => List.unmodifiable(_cachedEvents);

  /// Get all events as Maps (async version for updates)
  Future<List<Map<String, dynamic>>> getEvents() async {
    await _loadEventsFromDatabase();
    return events;
  }

  /// Get event by ID (for compatibility with UI)
  Future<Map<String, dynamic>?> getEventById(String id) async {
    try {
      // Try to parse id as int first
      final intId = int.tryParse(id);
      if (intId != null) {
        final event = await _db.getEventById(intId);
        if (event != null) {
          return event.toMap();
        }
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // TICKET OPERATIONS
  // ─────────────────────────────────────────────────────

  void purchaseTicket(DbPurchasedTicket ticket) {
    _purchasedTickets.add(ticket);
    notifyListeners();
  }

  void setPendingPurchase(DbPurchasedTicket ticket) {
    _pendingPurchase = ticket;
  }

  Future<void> _completePendingPurchaseInternal() async {
    if (_currentUser != null && _pendingPurchase != null) {
      if (_isWeb) {
        // store in-memory on web
        _memTickets.add(_pendingPurchase!);
        await _saveWebState();
      } else {
        await _db.addPurchasedTicket(_pendingPurchase!);
      }
      _purchasedTickets.add(_pendingPurchase!);
      _pendingPurchase = null;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────
  // EVENT OPERATIONS
  // ─────────────────────────────────────────────────────

  void setPendingEvent(Map<String, dynamic> eventData) {
    _pendingEvent = Map<String, dynamic>.from(eventData);
  }

  Future<String> _createEventInternal(Map<String, dynamic> eventData) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      final event = DbEvent(
        title: eventData['title']?.toString() ?? '',
        date: eventData['date']?.toString() ?? '',
        endDate: eventData['endDate']?.toString(),
        location: eventData['location']?.toString() ?? '',
        category: eventData['category']?.toString() ?? '',
        description: eventData['description']?.toString() ?? '',
        organizerEmail: _currentUser!.email,
        bannerImageData: eventData['bannerImageData'] != null
            ? Uint8List.fromList(eventData['bannerImageData'] as List<int>)
            : null,
        createdAt: DateTime.now(),
      );

      if (_isWeb) {
        final newId = DateTime.now().millisecondsSinceEpoch;
        final evWithId = event.copyWith(id: newId);
        _memEvents.add(evWithId);
        await _saveWebState();
        return newId.toString();
      }

      final id = await _db.createEvent(event);
      return id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> _completePendingEventInternal() async {
    if (_currentUser != null && _pendingEvent != null) {
      final payload = Map<String, dynamic>.from(_pendingEvent!);
      payload['organizerEmail'] = _currentUser!.email;
      await _createEventInternal(payload);
      _pendingEvent = null;
    }
  }

  /// Public method to create an event
  Future<String> createEvent(Map<String, dynamic> eventData) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = await _createEventInternal(eventData);
    // Reload events to update cache
    await _loadEventsFromDatabase();
    return id;
  }

  /// Update an event
  Future<bool> updateEvent(String id, Map<String, dynamic> updated) async {
    await Future.delayed(const Duration(milliseconds: 180));
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;

      if (_isWeb) {
        final idx = _memEvents.indexWhere((e) => (e.id ?? 0) == intId);
        if (idx == -1) return false;
        final mergedMap = _memEvents[idx].toMap()..addAll(updated);
        _memEvents[idx] = DbEvent.fromMap(
          mergedMap,
        ).copyWith(updatedAt: DateTime.now());
        await _saveWebState();
        await _loadEventsFromDatabase();
        return true;
      }

      final existing = await _db.getEventById(intId);
      if (existing == null) return false;

      final merged = existing.toMap()..addAll(updated);
      final updatedEvent = DbEvent.fromMap(
        merged,
      ).copyWith(updatedAt: DateTime.now());

      final result = await _db.updateEvent(updatedEvent);
      if (result) {
        await _loadEventsFromDatabase();
      }
      return result;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 160));
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;
      if (_isWeb) {
        final before = _memEvents.length;
        _memEvents.removeWhere((e) => (e.id ?? 0) == intId);
        final removed = _memEvents.length < before;
        if (removed) await _loadEventsFromDatabase();
        if (removed) await _saveWebState();
        return removed;
      }

      final result = await _db.deleteEvent(intId);
      if (result) {
        await _loadEventsFromDatabase();
      }
      return result;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────
  // USER PROFILE OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Update user profile (name and description)
  Future<DbUser?> updateCurrentUserProfile({
    required String name,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final current = _currentUser;
    if (current == null) return null;

    try {
      final trimmedName = name.trim();
      final nameParts = trimmedName
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      final firstName = nameParts.isNotEmpty
          ? nameParts.first
          : current.firstName;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : current.lastName;

      if (_isWeb) {
        final idx = _memUsers.indexWhere((u) => u.email == current.email);
        if (idx == -1) return null;

        final updated = _memUsers[idx].copyWith(
          firstName: firstName,
          lastName: lastName,
          description: description.trim(),
        );
        _memUsers[idx] = updated;
        _currentUser = updated;
        await _saveWebState();
        notifyListeners();
        return updated;
      }

      final updated = await _db.updateUserProfile(
        current.email,
        firstName,
        lastName,
        description.trim(),
      );

      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
      }

      return updated;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  /// Update user role
  Future<DbUser?> updateCurrentUserRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final current = _currentUser;
    if (current == null) return null;

    try {
      final normalizedRole = role.trim().isEmpty ? current.role : role.trim();
      if (_isWeb) {
        final idx = _memUsers.indexWhere((u) => u.email == current.email);
        if (idx == -1) return null;
        final updated = _memUsers[idx].copyWith(role: normalizedRole);
        _memUsers[idx] = updated;
        _currentUser = updated;
        await _saveWebState();
        notifyListeners();
        return updated;
      }

      final updated = await _db.updateUserRole(current.email, normalizedRole);

      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
      }

      return updated;
    } catch (e) {
      print('Error updating role: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // AUTHENTICATION OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Register a new user
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

    try {
      final trimmedEmail = email.trim().toLowerCase();

      // Check if email already exists
      if (_isWeb) {
        final exists = _memUsers.any((u) => u.email == trimmedEmail);
        if (exists) {
          print(
            '❌ Registration failed: Email "$trimmedEmail" already exists (web)',
          );
          return false;
        }
        final user = DbUser(
          email: trimmedEmail,
          password: password,
          firstName: firstName,
          lastName: lastName,
          role: role,
          university: university,
          description: '',
          isApproved: isApproved,
          createdAt: DateTime.now(),
        );
        _memUsers.add(user);
        await _saveWebState();
        _currentUser = user;
        await _loadEventsFromDatabase();
        await _completePendingPurchaseInternal();
        await _completePendingEventInternal();
        notifyListeners();
        print('✓ Registration successful for email: $trimmedEmail (web)');
        return true;
      }

      final exists = await _db.emailExists(trimmedEmail);
      if (exists) {
        print('❌ Registration failed: Email "$trimmedEmail" already exists');
        return false;
      }

      final user = DbUser(
        email: trimmedEmail,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        university: university,
        description: '',
        isApproved: isApproved,
        createdAt: DateTime.now(),
      );

      final success = await _db.registerUser(user);
      if (success) {
        _currentUser = user;
        await _loadEventsFromDatabase();
        await _completePendingPurchaseInternal();
        await _completePendingEventInternal();
        notifyListeners();
        print('✓ Registration successful for email: $trimmedEmail');
      } else {
        print('❌ Registration failed: Database error');
      }

      return success;
    } catch (e) {
      print('❌ Error registering: $e');
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final trimmedEmail = email.trim().toLowerCase();
      print('Attempting login with email: $trimmedEmail');

      if (_isWeb) {
        final user = _memUsers.firstWhere(
          (u) => u.email == trimmedEmail && u.password == password,
          orElse: () => DbUser(
            email: '',
            password: '',
            firstName: '',
            lastName: '',
            role: '',
            university: '',
            description: '',
            isApproved: false,
            createdAt: DateTime.now(),
          ),
        );
        if (user.email.isNotEmpty) {
          _currentUser = user;
          _purchasedTickets.clear();
          final tickets = _memTickets
              .where((t) => t.userEmail == trimmedEmail)
              .toList();
          _purchasedTickets.addAll(tickets);

          await _loadEventsFromDatabase();
          await _completePendingPurchaseInternal();
          await _completePendingEventInternal();
          notifyListeners();
          print('✓ Login successful for: $trimmedEmail (web)');
          return true;
        } else {
          print(
            '❌ Login failed: Email or password incorrect for $trimmedEmail (web)',
          );
          final emailExists = _memUsers.any((u) => u.email == trimmedEmail);
          if (emailExists) {
            print('ℹ Email exists in memory, but password doesn\'t match');
          } else {
            print('ℹ Email not found in memory');
          }
          return false;
        }
      }

      final user = await _db.getUserByEmailAndPassword(trimmedEmail, password);
      if (user != null) {
        _currentUser = user;

        // Load user's purchased tickets
        _purchasedTickets.clear();
        final tickets = await _db.getPurchasedTickets(trimmedEmail);
        _purchasedTickets.addAll(tickets);

        await _loadEventsFromDatabase();
        await _completePendingPurchaseInternal();
        await _completePendingEventInternal();
        notifyListeners();
        print('✓ Login successful for: $trimmedEmail');
        return true;
      } else {
        print('❌ Login failed: Email or password incorrect for $trimmedEmail');

        // Debug: check if email exists
        final emailExists = await _db.emailExists(trimmedEmail);
        if (emailExists) {
          print('ℹ Email exists in database, but password doesn\'t match');
        } else {
          print('ℹ Email not found in database');
        }
      }
      return false;
    } catch (e) {
      print('❌ Error logging in: $e');
      return false;
    }
  }

  /// Check if email exists for password reset
  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      if (_isWeb) {
        return _memUsers.any((u) => u.email == email.trim().toLowerCase());
      }
      return await _db.emailExists(email);
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      if (_isWeb) {
        final normalized = email.trim().toLowerCase();
        final idx = _memUsers.indexWhere((u) => u.email == normalized);
        if (idx == -1) return false;
        _memUsers[idx] = _memUsers[idx].copyWith(password: newPassword);
        if (_currentUser?.email == normalized) {
          _currentUser = _memUsers[idx];
        }
        await _saveWebState();
        notifyListeners();
        return true;
      }
      return await _db.resetPassword(email, newPassword);
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _purchasedTickets.clear();
    _pendingPurchase = null;
    _pendingEvent = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────
  // UTILITY OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Load persisted state into memory (web only)
  Future<void> _loadWebState() async {
    if (!_isWeb) return;
    try {
      final usersBox = Hive.box(_hiveUsersBox);
      _memUsers.clear();
      for (final val in usersBox.values) {
        final map = Map<String, dynamic>.from(val as Map);
        if (map['isApproved'] is bool) {
          map['isApproved'] = (map['isApproved'] as bool) ? 1 : 0;
        }
        map['createdAt'] =
            map['createdAt']?.toString() ?? DateTime.now().toIso8601String();
        map.putIfAbsent('university', () => '');
        map.putIfAbsent('description', () => '');
        _memUsers.add(DbUser.fromMap(map));
      }

      final eventsBox = Hive.box(_hiveEventsBox);
      _memEvents.clear();
      for (final val in eventsBox.values) {
        final map = Map<String, dynamic>.from(val as Map);
        if (map['bannerImageData'] is String &&
            (map['bannerImageData'] as String).isNotEmpty) {
          try {
            map['bannerImageData'] = base64Decode(
              map['bannerImageData'] as String,
            );
          } catch (_) {
            map['bannerImageData'] = null;
          }
        }
        map['createdAt'] =
            map['createdAt']?.toString() ?? DateTime.now().toIso8601String();
        if (map['updatedAt'] != null)
          map['updatedAt'] = map['updatedAt']?.toString();
        _memEvents.add(DbEvent.fromMap(map));
      }

      final ticketsBox = Hive.box(_hiveTicketsBox);
      _memTickets.clear();
      for (final val in ticketsBox.values) {
        final map = Map<String, dynamic>.from(val as Map);
        map['purchasedAt'] =
            map['purchasedAt']?.toString() ?? DateTime.now().toIso8601String();
        _memTickets.add(DbPurchasedTicket.fromMap(map));
      }
    } catch (e) {
      print('Error loading web state: $e');
    }
  }

  /// Save in-memory web state to SharedPreferences
  Future<void> _saveWebState() async {
    if (!_isWeb) return;
    try {
      final usersBox = Hive.box(_hiveUsersBox);
      await usersBox.clear();
      for (final u in _memUsers) {
        await usersBox.put(u.email, u.toMap());
      }

      final eventsBox = Hive.box(_hiveEventsBox);
      await eventsBox.clear();
      for (final e in _memEvents) {
        final m = e.toMap();
        final b = m['bannerImageData'];
        if (b != null && b is Uint8List) {
          m['bannerImageData'] = base64Encode(b);
        } else {
          m['bannerImageData'] = null;
        }
        final key = (e.id ?? DateTime.now().millisecondsSinceEpoch).toString();
        await eventsBox.put(key, m);
      }

      final ticketsBox = Hive.box(_hiveTicketsBox);
      await ticketsBox.clear();
      for (final t in _memTickets) {
        final key = (t.id ?? DateTime.now().millisecondsSinceEpoch).toString();
        await ticketsBox.put(key, t.toMap());
      }
    } catch (e) {
      print('Error saving web state: $e');
    }
  }

  /// Clear all data (for testing/reset) - DEVELOPMENT USE ONLY
  Future<void> clear() async {
    try {
      if (_isWeb) {
        final usersBox = Hive.box(_hiveUsersBox);
        final eventsBox = Hive.box(_hiveEventsBox);
        final ticketsBox = Hive.box(_hiveTicketsBox);
        await usersBox.clear();
        await eventsBox.clear();
        await ticketsBox.clear();
        _memUsers.clear();
        _memEvents.clear();
        _memTickets.clear();
      } else {
        await _db.clearAllData();
      }

      _currentUser = null;
      _purchasedTickets.clear();
      _cachedEvents.clear();
      _pendingPurchase = null;
      _pendingEvent = null;
      notifyListeners();
      print('✓ Database cleared - all data deleted');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  /// Get database diagnostics for debugging
  Future<String> getDiagnostics() async {
    try {
      final allUsers = await _db.database.then((db) async {
        final results = await db.query('users');
        return results;
      });

      final allEvents = await _db.database.then((db) async {
        final results = await db.query('events');
        return results;
      });

      final diagnostics =
          '''
═══════════════════════════════════════
DATABASE DIAGNOSTICS
═══════════════════════════════════════
Users (${allUsers.length}):
${allUsers.map((u) => '  • ${u['email']} | Role: ${u['role']}').join('\n')}

Events (${allEvents.length}):
${allEvents.map((e) => '  • ${e['title']} | Organizer: ${e['organizerEmail']}').join('\n')}

Current User: ${_currentUser?.email ?? 'None'}
═══════════════════════════════════════
      ''';

      return diagnostics;
    } catch (e) {
      return 'Error getting diagnostics: $e';
    }
  }

  /// Singleton pattern (optional, for now we create instances as needed)
  static final SqliteBackend _instance = SqliteBackend._internal();
  factory SqliteBackend.getInstance() => _instance;
  SqliteBackend._internal();
}
