import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/event_categories.dart';

void main() {
  test('kEventCategories contains expected entries', () {
    expect(kEventCategories, contains('Technology'));
    expect(kEventCategories, isNotEmpty);
  });

  test('kEventFilterCategories includes "All" and categories', () {
    expect(kEventFilterCategories.first, 'All');
    for (final c in kEventCategories) expect(kEventFilterCategories, contains(c));
  });
}
