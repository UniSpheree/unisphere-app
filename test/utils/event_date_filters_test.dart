import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/event_date_filters.dart';

void main() {
  group('tryParseEventDate', () {
    test('parses valid ISO date strings', () {
      final result = tryParseEventDate('2024-01-15');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('parses valid ISO datetime strings', () {
      final result = tryParseEventDate('2024-01-15T10:30:00');
      expect(result, isNotNull);
      expect(result!.hour, 10);
      expect(result.minute, 30);
    });

    test('returns null for null input', () {
      expect(tryParseEventDate(null), isNull);
    });

    test('returns null for empty string', () {
      expect(tryParseEventDate(''), isNull);
      expect(tryParseEventDate('   '), isNull);
    });

    test('returns null for invalid date strings', () {
      expect(tryParseEventDate('not-a-date'), isNull);
      expect(tryParseEventDate('2024-13-45'), isNull);
      expect(tryParseEventDate('abc123'), isNull);
    });

    test('handles whitespace around input', () {
      final result = tryParseEventDate('  2024-01-15  ');
      expect(result, isNotNull);
      expect(result!.year, 2024);
    });

    test('accepts various date formats that DateTime.parse handles', () {
      final result = tryParseEventDate('2024-01-15 10:30:00');
      expect(result, isNotNull);
    });
  });

  group('hasActiveDateFilters', () {
    test('returns true when at least one filter is active', () {
      final filters = {'today': true, 'tomorrow': false};
      expect(hasActiveDateFilters(filters), isTrue);
    });

    test('returns false when all filters are false', () {
      final filters = {'today': false, 'tomorrow': false, 'this week': false};
      expect(hasActiveDateFilters(filters), isFalse);
    });

    test('returns false for empty filter map', () {
      final filters = <String, bool>{};
      expect(hasActiveDateFilters(filters), isFalse);
    });

    test('returns true when multiple filters are active', () {
      final filters = {'today': true, 'tomorrow': true, 'this week': false};
      expect(hasActiveDateFilters(filters), isTrue);
    });
  });

  group('matchesDateFilters', () {
    final reference = DateTime(2024, 1, 15, 12, 0); // Monday, Jan 15, 2024

    test('returns true when no filters are active (all false)', () {
      final filters = {
        'today': false,
        'tomorrow': false,
        'this week': false,
        'next week': false,
        'this month': false,
        'next month': false,
      };
      expect(
        matchesDateFilters('2024-02-20', filters, reference: reference),
        isTrue,
      );
    });

    test('matches "today" filter correctly', () {
      final filters = {'today': true, 'tomorrow': false};
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-16', filters, reference: reference),
        isFalse,
      );
    });

    test('matches "tomorrow" filter correctly', () {
      final filters = {'today': false, 'tomorrow': true};
      expect(
        matchesDateFilters('2024-01-16', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isFalse,
      );
    });

    test('matches "this week" filter correctly', () {
      final filters = {'this week': true};
      // Jan 15 is Monday, week should be Jan 15 - Jan 21
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-18', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-22', filters, reference: reference),
        isFalse,
      );
    });

    test('matches "next week" filter correctly', () {
      final filters = {'next week': true};
      // Next week after Jan 15 is Jan 22 - Jan 28
      expect(
        matchesDateFilters('2024-01-22', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-28', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isFalse,
      );
    });

    test('matches "this month" filter correctly', () {
      final filters = {'this month': true};
      expect(
        matchesDateFilters('2024-01-01', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-31', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-02-01', filters, reference: reference),
        isFalse,
      );
    });

    test('matches "next month" filter correctly', () {
      final filters = {'next month': true};
      expect(
        matchesDateFilters('2024-02-01', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-02-29', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-03-01', filters, reference: reference),
        isFalse,
      );
      expect(
        matchesDateFilters('2024-01-31', filters, reference: reference),
        isFalse,
      );
    });

    test('returns false when dateValue cannot be parsed', () {
      final filters = {'today': true};
      expect(
        matchesDateFilters('invalid-date', filters, reference: reference),
        isFalse,
      );
      expect(
        matchesDateFilters(null, filters, reference: reference),
        isFalse,
      );
    });

    test('handles multiple active filters (OR logic)', () {
      final filters = {
        'today': true,
        'tomorrow': true,
        'this week': false,
      };
      // Should match if it matches "today" or "tomorrow"
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-16', filters, reference: reference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-01-17', filters, reference: reference),
        isFalse,
      );
    });

    test('is case-insensitive for filter keys', () {
      final filters = {'TODAY': true};
      expect(
        matchesDateFilters('2024-01-15', filters, reference: reference),
        isTrue,
      );
    });

    test('uses current date when reference is not provided', () {
      final filters = {'today': true};
      // This test verifies that the function uses DateTime.now() as default
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      expect(
        matchesDateFilters(todayStr, filters),
        isTrue,
      );
    });

    test('handles month boundaries correctly', () {
      final novReference = DateTime(2024, 11, 30); // Saturday, end of Nov
      final filters = {'next month': true};
      expect(
        matchesDateFilters('2024-12-01', filters, reference: novReference),
        isTrue,
      );
      expect(
        matchesDateFilters('2024-12-31', filters, reference: novReference),
        isTrue,
      );
    });

    test('handles year boundaries correctly for next month', () {
      final decReference = DateTime(2024, 12, 31);
      final filters = {'next month': true};
      expect(
        matchesDateFilters('2025-01-15', filters, reference: decReference),
        isTrue,
      );
    });
  });

  group('kEventDateFilters constant', () {
    test('contains expected filter options', () {
      expect(kEventDateFilters, contains('today'));
      expect(kEventDateFilters, contains('tomorrow'));
      expect(kEventDateFilters, contains('this week'));
      expect(kEventDateFilters, contains('next week'));
      expect(kEventDateFilters, contains('this month'));
      expect(kEventDateFilters, contains('next month'));
    });

    test('has exactly 6 filter options', () {
      expect(kEventDateFilters.length, 6);
    });
  });

  group('edge cases and integration', () {
    test('parses and filters datetime with time component', () {
      final reference = DateTime(2024, 1, 15, 12, 0);
      final filters = {'today': true};
      expect(
        matchesDateFilters('2024-01-15T14:30:00', filters, reference: reference),
        isTrue,
      );
    });

    test('handles leap year dates', () {
      final reference = DateTime(2024, 2, 29); // Leap year
      final filters = {'today': true};
      expect(
        matchesDateFilters('2024-02-29', filters, reference: reference),
        isTrue,
      );
    });

    test('handles dates with leading/trailing spaces in parse', () {
      final reference = DateTime(2024, 1, 15);
      final filters = {'today': true};
      expect(
        matchesDateFilters('  2024-01-15  ', filters, reference: reference),
        isTrue,
      );
    });

    test('multiple filters with complex scenarios', () {
      final reference = DateTime(2024, 1, 15, 12, 0); // Monday, Jan 15
      final filters = {
        'today': false,
        'tomorrow': true,
        'this week': true,
        'next week': false,
        'this month': false,
        'next month': false,
      };
      // Tomorrow (Jan 16) matches "tomorrow" and "this week"
      expect(
        matchesDateFilters('2024-01-16', filters, reference: reference),
        isTrue,
      );
    });
  });
}
