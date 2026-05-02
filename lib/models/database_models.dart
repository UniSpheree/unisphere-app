import 'dart:typed_data';

/// Database models for SQLite persistence
/// These are separate from UI models - focused on data storage

class DbUser {
  final int? id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String university;
  final String description;
  final bool isApproved;
  final DateTime createdAt;

  DbUser({
    this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.university,
    required this.description,
    required this.isApproved,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isOrganiser => role.toLowerCase() == 'organiser';

  /// Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'university': university,
      'description': description,
      'isApproved': isApproved ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from database Map
  factory DbUser.fromMap(Map<String, dynamic> map) {
    return DbUser(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      role: map['role'] as String,
      university: map['university'] as String,
      description: map['description'] as String? ?? '',
      isApproved: (map['isApproved'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy with some fields updated
  DbUser copyWith({
    int? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? role,
    String? university,
    String? description,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return DbUser(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      university: university ?? this.university,
      description: description ?? this.description,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DbEvent {
  final int? id;
  final String title;
  final String date;
  final String? endDate;
  final String location;
  final String category;
  final String description;
  final String organizerEmail;
  final Uint8List? bannerImageData; // Store image as binary
  final DateTime createdAt;
  final DateTime? updatedAt;

  DbEvent({
    this.id,
    required this.title,
    required this.date,
    this.endDate,
    required this.location,
    required this.category,
    required this.description,
    required this.organizerEmail,
    this.bannerImageData,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'endDate': endDate,
      'location': location,
      'category': category,
      'description': description,
      'organizerEmail': organizerEmail,
      'bannerImageData': bannerImageData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DbEvent.fromMap(Map<String, dynamic> map) {
    return DbEvent(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      endDate: map['endDate'] as String?,
      location: map['location'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      organizerEmail: map['organizerEmail'] as String,
      bannerImageData: map['bannerImageData'] as Uint8List?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  DbEvent copyWith({
    int? id,
    String? title,
    String? date,
    String? endDate,
    String? location,
    String? category,
    String? description,
    String? organizerEmail,
    Uint8List? bannerImageData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DbEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      category: category ?? this.category,
      description: description ?? this.description,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      bannerImageData: bannerImageData ?? this.bannerImageData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DbPurchasedTicket {
  final int? id;
  final String userEmail;
  final String title;
  final String date;
  final String location;
  final String category;
  final String price;
  final DateTime purchasedAt;

  DbPurchasedTicket({
    this.id,
    required this.userEmail,
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.price,
    required this.purchasedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'title': title,
      'date': date,
      'location': location,
      'category': category,
      'price': price,
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }

  factory DbPurchasedTicket.fromMap(Map<String, dynamic> map) {
    return DbPurchasedTicket(
      id: map['id'] as int?,
      userEmail: map['userEmail'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      location: map['location'] as String,
      category: map['category'] as String,
      price: map['price'] as String,
      purchasedAt: DateTime.parse(map['purchasedAt'] as String),
    );
  }
}
