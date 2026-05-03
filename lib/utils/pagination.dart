int eventsPerPageForWidth(double width) {
  return width < 800 ? 4 : 6;
}

int totalPagesForLength(int length, int itemsPerPage) {
  if (length <= 0 || itemsPerPage <= 0) return 0;
  return ((length + itemsPerPage - 1) ~/ itemsPerPage);
}

int clampPageIndex(int pageIndex, int totalPages) {
  if (totalPages <= 0) return 0;
  if (pageIndex < 0) return 0;
  if (pageIndex >= totalPages) return totalPages - 1;
  return pageIndex;
}

List<T> paginateItems<T>(List<T> items, int pageIndex, int itemsPerPage) {
  if (items.isEmpty || itemsPerPage <= 0) return <T>[];
  final totalPages = totalPagesForLength(items.length, itemsPerPage);
  final safePage = clampPageIndex(pageIndex, totalPages);
  final start = safePage * itemsPerPage;
  final end = (start + itemsPerPage).clamp(0, items.length);
  return items.sublist(start, end);
}
