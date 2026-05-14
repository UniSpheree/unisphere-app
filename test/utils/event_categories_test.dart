import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/event_categories.dart';

void main() {
  group('kEventCategories', () {
    test('contains expected core categories', () {
      expect(kEventCategories, contains('Technology'));
      expect(kEventCategories, contains('Music'));
      expect(kEventCategories, contains('Entertainment'));
      expect(kEventCategories, contains('Career'));
      expect(kEventCategories, contains('Sports'));
      expect(kEventCategories, contains('Workshops'));
      expect(kEventCategories, contains('Academic'));
      expect(kEventCategories, contains('Social'));
      expect(kEventCategories, contains('Other'));
    });

    test('has exactly 9 categories', () {
      expect(kEventCategories.length, 9);
    });

    test('contains no empty strings', () {
      for (final category in kEventCategories) {
        expect(category, isNotEmpty);
      }
    });

    test('all categories are unique', () {
      final uniqueCount = kEventCategories.toSet().length;
      expect(uniqueCount, equals(kEventCategories.length));
    });

    test('all entries are strings', () {
      for (final category in kEventCategories) {
        expect(category, isA<String>());
      }
    });
  });

  group('kEventFilterCategories', () {
    test('starts with "All"', () {
      expect(kEventFilterCategories.first, 'All');
    });

    test('contains all base categories after "All"', () {
      for (final c in kEventCategories) {
        expect(kEventFilterCategories, contains(c));
      }
    });

    test('has one more item than kEventCategories (for "All")', () {
      expect(
        kEventFilterCategories.length,
        equals(kEventCategories.length + 1),
      );
    });

    test('contains exactly 10 items', () {
      expect(kEventFilterCategories.length, 10);
    });

    test('does not contain duplicates', () {
      final uniqueCount = kEventFilterCategories.toSet().length;
      expect(uniqueCount, equals(kEventFilterCategories.length));
    });

    test('all items are non-empty strings', () {
      for (final item in kEventFilterCategories) {
        expect(item, isNotEmpty);
        expect(item, isA<String>());
      }
    });

    test('includes Technology, Music, and Entertainment', () {
      expect(kEventFilterCategories, contains('All'));
      expect(kEventFilterCategories, contains('Technology'));
      expect(kEventFilterCategories, contains('Music'));
      expect(kEventFilterCategories, contains('Entertainment'));
    });

    test('uses spread operator correctly (derived from kEventCategories)', () {
      // Verify that items 1-9 match kEventCategories items 0-8
      for (int i = 0; i < kEventCategories.length; i++) {
        expect(kEventFilterCategories[i + 1], equals(kEventCategories[i]));
      }
    });
  });
}
