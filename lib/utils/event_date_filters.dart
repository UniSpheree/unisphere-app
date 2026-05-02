const List<String> kEventDateFilters = [
  'today',
  'tomorrow',
  'this week',
  'next week',
  'this month',
  'next month',
];

DateTime? tryParseEventDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  try {
    return DateTime.parse(raw);
  } catch (_) {
    return null;
  }
}

bool hasActiveDateFilters(Map<String, bool> filters) {
  return filters.values.any((value) => value);
}

bool matchesDateFilters(
  dynamic dateValue,
  Map<String, bool> filters, {
  DateTime? reference,
}) {
  if (!hasActiveDateFilters(filters)) return true;

  final date = tryParseEventDate(dateValue);
  if (date == null) return false;

  final now = reference ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  final nextWeekStart = endOfWeek;
  final nextWeekEnd = nextWeekStart.add(const Duration(days: 7));

  final thisMonthStart = DateTime(now.year, now.month);
  final nextMonthStart = DateTime(now.year, now.month + 1);
  final monthAfterNext = DateTime(now.year, now.month + 2);

  final selected = filters.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key.toLowerCase())
      .toList();

  bool inRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  for (final filter in selected) {
    switch (filter) {
      case 'today':
        if (date.year == today.year &&
            date.month == today.month &&
            date.day == today.day) {
          return true;
        }
        break;
      case 'tomorrow':
        if (date.year == tomorrow.year &&
            date.month == tomorrow.month &&
            date.day == tomorrow.day) {
          return true;
        }
        break;
      case 'this week':
        if (inRange(date, startOfWeek, endOfWeek)) return true;
        break;
      case 'next week':
        if (inRange(date, nextWeekStart, nextWeekEnd)) return true;
        break;
      case 'this month':
        if (date.year == thisMonthStart.year &&
            date.month == thisMonthStart.month) {
          return true;
        }
        break;
      case 'next month':
        if (date.year == nextMonthStart.year &&
            date.month == nextMonthStart.month &&
            !date.isBefore(nextMonthStart) &&
            date.isBefore(monthAfterNext)) {
          return true;
        }
        break;
    }
  }

  return false;
}
