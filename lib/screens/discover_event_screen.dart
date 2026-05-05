import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/sqlite_backend.dart';
import '../utils/event_categories.dart';
import '../utils/event_date_filters.dart';
import '../utils/pagination.dart';
import '../widgets/app_footer.dart';
import '../widgets/header.dart';
import '../widgets/pagination_controls.dart';
import 'event_details_screen.dart';

class DiscoverEventScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const DiscoverEventScreen({super.key, this.initialSearchQuery});

  @override
  State<DiscoverEventScreen> createState() => _DiscoverEventScreenState();
}

class _DiscoverEventScreenState extends State<DiscoverEventScreen> {
  bool _showFiltersDropdown = false;
  String _selectedFilter = 'All';
  late final TextEditingController _searchController;
  String _submittedSearchQuery = '';
  late Map<String, bool> _dateFilters;

  static const List<String> _filterChips = kEventFilterCategories;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _dateFilters = {for (final item in kEventDateFilters) item: false};
    SqliteBackend().addListener(_onBackendChanged);

    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _submittedSearchQuery = widget.initialSearchQuery!;
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  void _onBackendChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    SqliteBackend().removeListener(_onBackendChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _setDateFilter(String filter, bool value) {
    setState(() {
      _dateFilters[filter] = value;
    });
  }

  List<Map<String, dynamic>> get _discoverEvents {
    return SqliteBackend().events
        .where(
          (e) =>
              e['title']?.toString().toLowerCase() != 'demo event' &&
              e['visibility']?.toString() != 'Private',
        )
        .map((event) {
          return {
            'id': event['id'],
            'title': event['title']?.toString() ?? 'Untitled Event',
            'date': event['date']?.toString() ?? '',
            'location': event['location']?.toString() ?? 'TBA',
            'category': event['category']?.toString() ?? 'Other',
            'description': event['description']?.toString() ?? '',
            'bannerImageData': event['bannerImageData'],
            'organizer': event['organizer']?.toString() ?? 'UniSphere',
            'organizerEmail': event['organizerEmail']?.toString(),
            'imageColor': const Color(0xFFE0E7FF),
            'icon': Icons.event_rounded,
          };
        })
        .toList();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final baseEvents = _selectedFilter == 'All'
        ? _discoverEvents
        : _discoverEvents
              .where((event) => event['category'] == _selectedFilter)
              .toList();

    final dateFiltered = baseEvents
        .where((event) => matchesDateFilters(event['date'], _dateFilters))
        .toList();

    if (_submittedSearchQuery.isEmpty) {
      return dateFiltered;
    }

    final query = _submittedSearchQuery.toLowerCase();
    return dateFiltered.where((event) {
      final title = (event['title'] as String).toLowerCase();
      final category = (event['category'] as String).toLowerCase();
      final location = (event['location'] as String).toLowerCase();
      return title.contains(query) ||
          category.contains(query) ||
          location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      AppHeader(
                        onHostEventTap: () =>
                            Navigator.pushNamed(context, '/create-event'),
                        onRegisterTap: () =>
                            Navigator.pushNamed(context, '/register'),
                        onFindEventsTap: () {},
                        onCreateEventsTap: () =>
                            Navigator.pushNamed(context, '/create-event'),
                        onMyTicketsTap: () =>
                            Navigator.pushNamed(context, '/my-tickets'),
                        onAboutTap: () =>
                            Navigator.pushNamed(context, '/about'),
                        onSignInTap: () =>
                            Navigator.pushNamed(context, '/login'),
                        showProfile: true,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 900;
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 32,
                                vertical: 28,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1100,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: const Text(
                                            'Landing Page',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '  /  ',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Flexible(
                                          child: Text(
                                            'Discover Events',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(0xFF4F46E5),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Discover Events',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1F36),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: _searchController,
                                              onChanged: (value) {
                                                setState(() {
                                                  _submittedSearchQuery = value;
                                                });
                                              },
                                              onSubmitted: (value) {
                                                setState(() {
                                                  _submittedSearchQuery = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Search events...',
                                                hintStyle: const TextStyle(
                                                  color: Color(0xFF9CA3AF),
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: const Icon(
                                                  Icons.search_rounded,
                                                  color: Color(0xFF9CA3AF),
                                                  size: 20,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Color(0xFF4F46E5),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _submittedSearchQuery =
                                                          _searchController
                                                              .text;
                                                    });
                                                  },
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF1A1F36),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          height: 54,
                                          width: 54,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _showFiltersDropdown =
                                                    !_showFiltersDropdown;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.tune_rounded,
                                              color: Color(0xFF4F46E5),
                                              size: 20,
                                            ),
                                            tooltip: 'Filter events',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_showFiltersDropdown) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Date',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1A1F36),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 10,
                                              children: kEventDateFilters.map((
                                                filter,
                                              ) {
                                                final isSelected =
                                                    _dateFilters[filter] ??
                                                    false;
                                                return GestureDetector(
                                                  onTap: () => _setDateFilter(
                                                    filter,
                                                    !isSelected,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF4F46E5,
                                                            ).withOpacity(0.10)
                                                          : const Color(
                                                              0xFFF8FAFC,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF4F46E5,
                                                              )
                                                            : const Color(
                                                                0xFFE5E7EB,
                                                              ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 18,
                                                          height: 18,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? const Color(
                                                                      0xFF4F46E5,
                                                                    )
                                                                  : const Color(
                                                                      0xFFD1D5DB,
                                                                    ),
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF4F46E5,
                                                                  )
                                                                : Colors.white,
                                                          ),
                                                          child: isSelected
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  size: 12,
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : null,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          filter,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF4F46E5,
                                                                  )
                                                                : const Color(
                                                                    0xFF1A1F36,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (_submittedSearchQuery.isEmpty) ...[
                                      const SizedBox(height: 20),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: _filterChips.map((chip) {
                                          final isSelected =
                                              chip == _selectedFilter;
                                          return GestureDetector(
                                            onTap: () => _setFilter(chip),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF4F46E5)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF4F46E5)
                                                      : const Color(0xFFE5E7EB),
                                                ),
                                              ),
                                              child: Text(
                                                chip,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF1A1F36),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    if (_submittedSearchQuery.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          'Showing results for "$_submittedSearchQuery"',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 28),
                                    _PaginatedDiscoverGrid(
                                      events: _filteredEvents,
                                      emptyMessage: _selectedFilter == 'All'
                                          ? 'No events available right now.'
                                          : 'No ${_selectedFilter.toLowerCase()} events available right now.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaginatedDiscoverGrid extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final String emptyMessage;

  const _PaginatedDiscoverGrid({
    required this.events,
    required this.emptyMessage,
  });

  @override
  State<_PaginatedDiscoverGrid> createState() => _PaginatedDiscoverGridState();
}

class _PaginatedDiscoverGridState extends State<_PaginatedDiscoverGrid> {
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant _PaginatedDiscoverGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events.length != widget.events.length ||
        oldWidget.emptyMessage != widget.emptyMessage) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 36,
              color: const Color(0xFF4F46E5).withOpacity(0.65),
            ),
            const SizedBox(height: 10),
            Text(
              widget.emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth > 800
            ? 3
            : (availableWidth > 400 ? 2 : 1);
        final childAspectRatio = crossAxisCount == 1 ? 1.2 : 0.72;
        final itemsPerPage = eventsPerPageForWidth(availableWidth);
        final totalPages = totalPagesForLength(
          widget.events.length,
          itemsPerPage,
        );
        final pageIndex = clampPageIndex(_currentPage, totalPages);
        final pageEvents = paginateItems(
          widget.events,
          pageIndex,
          itemsPerPage,
        );

        if (totalPages > 0 && pageIndex != _currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _currentPage = pageIndex);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              itemCount: pageEvents.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) =>
                  _DiscoverEventCard(event: pageEvents[index]),
            ),
            PaginationControls(
              currentPage: pageIndex,
              totalPages: totalPages,
              onPrevious: () {
                setState(() {
                  _currentPage -= 1;
                });
              },
              onNext: () {
                setState(() {
                  _currentPage += 1;
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class _DiscoverEventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _DiscoverEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final bannerData = event['bannerImageData'];
    final Uint8List? bannerBytes = bannerData is Uint8List ? bannerData : null;
    final icon = event['icon'] as IconData? ?? Icons.event_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: event['imageColor'] as Color? ?? const Color(0xFFE0E7FF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: bannerBytes != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: Image.memory(
                        bannerBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            icon,
                            size: 42,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        icon,
                        size: 42,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']?.toString() ?? 'Untitled Event',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['date']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['location']?.toString() ?? 'TBA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${event['organizer']?.toString() ?? 'UniSphere'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event['category']?.toString() ?? 'Other',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailsScreen(event: event),
                          ),
                        );
                      },
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
