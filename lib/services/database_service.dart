import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/database_models.dart';

/// Central database service for SQLite operations
/// Handles all persistence for: Users, Events, Purchased Tickets
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // ─────────────────────────────────────────────────────
  // DATABASE INITIALIZATION
  // ─────────────────────────────────────────────────────

  /// Get or create the database
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'unisphere_app.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  /// Create all database tables
  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        role TEXT NOT NULL,
        university TEXT NOT NULL,
        description TEXT DEFAULT '',
        isApproved INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        endDate TEXT,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT DEFAULT '',
        organizerEmail TEXT NOT NULL,
        bannerImageData BLOB,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Purchased tickets table
    await db.execute('''
      CREATE TABLE purchased_tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        price TEXT NOT NULL,
        purchasedAt TEXT NOT NULL
      )
    ''');
  }

  // ─────────────────────────────────────────────────────
  // USER OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Register a new user
  Future<bool> registerUser(DbUser user) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// Get user by email and password (for login)
  Future<DbUser?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (results.isEmpty) return null;
      return DbUser.fromMap(results.first);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get user by email only
  Future<DbUser?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) return null;
      return DbUser.fromMap(results.first);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return results.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// Update user profile
  Future<DbUser?> updateUserProfile(
    String email,
    String firstName,
    String lastName,
    String description,
  ) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {
          'firstName': firstName,
          'lastName': lastName,
          'description': description,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      return getUserByEmail(email);
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  /// Update user role
  Future<DbUser?> updateUserRole(String email, String role) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {'role': role},
        where: 'email = ?',
        whereArgs: [email],
      );
      return getUserByEmail(email);
    } catch (e) {
      print('Error updating role: $e');
      return null;
    }
  }

  /// Reset user password
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final db = await database;
      final updated = await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
      return updated > 0;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────
  // EVENT OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Create a new event
  Future<int?> createEvent(DbEvent event) async {
    try {
      final db = await database;
      final id = await db.insert('events', event.toMap());
      return id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  /// Get all events
  Future<List<DbEvent>> getAllEvents() async {
    try {
      final db = await database;
      final results = await db.query('events');
      return results.map((map) => DbEvent.fromMap(map)).toList();
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  /// Get event by ID
  Future<DbEvent?> getEventById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) return null;
      return DbEvent.fromMap(results.first);
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  /// Get events by organizer email
  Future<List<DbEvent>> getEventsByOrganizer(String organizerEmail) async {
    try {
      final db = await database;
      final results = await db.query(
        'events',
        where: 'organizerEmail = ?',
        whereArgs: [organizerEmail],
        orderBy: 'date DESC',
      );
      return results.map((map) => DbEvent.fromMap(map)).toList();
    } catch (e) {
      print('Error getting organizer events: $e');
      return [];
    }
  }

  /// Search events by title or category
  Future<List<DbEvent>> searchEvents(String query) async {
    try {
      final db = await database;
      final results = await db.query(
        'events',
        where: 'title LIKE ? OR category LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );
      return results.map((map) => DbEvent.fromMap(map)).toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Update event
  Future<bool> updateEvent(DbEvent event) async {
    try {
      final db = await database;
      final updated = await db.update(
        'events',
        {...event.copyWith(updatedAt: DateTime.now()).toMap()},
        where: 'id = ?',
        whereArgs: [event.id],
      );
      return updated > 0;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  /// Delete event
  Future<bool> deleteEvent(int id) async {
    try {
      final db = await database;
      final deleted = await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────
  // PURCHASED TICKET OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Add a purchased ticket
  Future<int?> addPurchasedTicket(DbPurchasedTicket ticket) async {
    try {
      final db = await database;
      final id = await db.insert('purchased_tickets', ticket.toMap());
      return id;
    } catch (e) {
      print('Error adding ticket: $e');
      return null;
    }
  }

  /// Get purchased tickets for a user
  Future<List<DbPurchasedTicket>> getPurchasedTickets(String userEmail) async {
    try {
      final db = await database;
      final results = await db.query(
        'purchased_tickets',
        where: 'userEmail = ?',
        whereArgs: [userEmail],
        orderBy: 'purchasedAt DESC',
      );
      return results.map((map) => DbPurchasedTicket.fromMap(map)).toList();
    } catch (e) {
      print('Error getting tickets: $e');
      return [];
    }
  }

  /// Delete a purchased ticket
  Future<bool> deletePurchasedTicket(int id) async {
    try {
      final db = await database;
      final deleted = await db.delete(
        'purchased_tickets',
        where: 'id = ?',
        whereArgs: [id],
      );
      return deleted > 0;
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────
  // UTILITY OPERATIONS
  // ─────────────────────────────────────────────────────

  /// Close the database (call on app shutdown)
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('purchased_tickets');
      await db.delete('events');
      await db.delete('users');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
