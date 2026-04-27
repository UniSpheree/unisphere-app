import 'dart:async';

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
}

class MockBackend {
  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;

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
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _users
        .where((u) => u.email == email && u.password == password)
        .toList();
    if (user.isNotEmpty) {
      _currentUser = user.first;
      return true;
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.any((u) => u.email == email);
  }

  // For testing/demo
  void clear() => _users.clear();
  void logout() {
    _currentUser = null;
  }

  List<MockUser> get users => List.unmodifiable(_users);
}
