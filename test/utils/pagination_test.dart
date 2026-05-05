import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/pagination.dart';

void main() {
  test('eventsPerPageForWidth chooses 4 for narrow widths', () {
    expect(eventsPerPageForWidth(200), 4);
    expect(eventsPerPageForWidth(799.9), 4);
  });

  test('eventsPerPageForWidth chooses 6 for wide widths', () {
    expect(eventsPerPageForWidth(800), 6);
    expect(eventsPerPageForWidth(1200), 6);
  });

  test('totalPagesForLength handles edge cases', () {
    expect(totalPagesForLength(0, 5), 0);
    expect(totalPagesForLength(10, 0), 0);
    expect(totalPagesForLength(10, 3), 4);
  });

  test('clampPageIndex bounds page index', () {
    expect(clampPageIndex(-1, 5), 0);
    expect(clampPageIndex(10, 5), 4);
    expect(clampPageIndex(2, 5), 2);
  });

  test('paginateItems returns correct slices', () {
    final items = List.generate(10, (i) => i + 1);
    expect(paginateItems(items, 0, 3), [1, 2, 3]);
    expect(paginateItems(items, 1, 3), [4, 5, 6]);
    expect(paginateItems(items, 3, 3), [10]);
    expect(paginateItems(items, 99, 3), [10]);
    expect(paginateItems<int>([], 0, 3), <int>[]);
  });
}
