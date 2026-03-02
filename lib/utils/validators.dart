/// Shared field validators used across the app.
library;

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

  return null; // valid
}
