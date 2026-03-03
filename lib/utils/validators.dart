library;
import 'unis.dart';
/// Shared field validators used across the app.

/// Blocked consumer / free-mail domains that are NOT university addresses.
const _blockedDomains = {
  'gmail.com',
  'googlemail.com',
  'yahoo.com',
  'yahoo.co.uk',
  'yahoo.fr',
  'hotmail.com',
  'hotmail.co.uk',
  'hotmail.fr',
  'outlook.com',
  'outlook.co.uk',
  'live.com',
  'live.co.uk',
  'msn.com',
  'icloud.com',
  'me.com',
  'mac.com',
  'aol.com',
  'protonmail.com',
  'proton.me',
  'mail.com',
  'tutanota.com',
  'yandex.com',
  'yandex.ru',
  'gmx.com',
  'gmx.de',
  'web.de',
};

/// Validates that [value] is a university email address.
///
/// Rules:
/// 1. Not empty.
/// 2. Contains exactly one `@`.
/// 3. Domain is not a known free/consumer mail provider.
/// 4. Domain ends with `.edu`, `.ac.uk`, `.ac.<cc>`, `.edu.<cc>` OR
///    is not in the blocked list (allows any other institutional TLD).
String? validateUniversityEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }

  final email = value.trim().toLowerCase();
  final parts = email.split('@');

  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
    return 'Enter a valid email address';
  }

  final domain = parts[1];

  // Block known free-mail providers explicitly
  if (_blockedDomains.contains(domain)) {
    return 'Please use your university email address';
  }

  // Must look like a real domain (contains a dot)
  if (!domain.contains('.')) {
    return 'Enter a valid email address';
  }

  // Accept only UK university emails (any .ac.uk domain)
  final ukUniversityDomainRegex = RegExp(r'^[a-z0-9\-\.]+\.ac\.uk$');
  if (!ukUniversityDomainRegex.hasMatch(domain)) {
    return 'Enter a valid UK university email';
  }
  return null;
}

/// Validates a registration password.
///
/// Rules:
/// 1. Not empty.
/// 2. At least 8 characters.
/// 3. Contains at least one digit (0-9).
/// 4. Contains at least one special character (!@#\$%^&*?_~-).
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  if (!RegExp(r'[!@#\$%^&*?_~\-]').hasMatch(value)) {
    return 'Password must contain at least one special character (!@#\$%^&*?_~-)';
  }
  return null;
}
