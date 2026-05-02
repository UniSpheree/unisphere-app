import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'event_details_screen.dart';

class DiscoverEventScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const DiscoverEventScreen({super.key, this.initialSearchQuery});

  @override
  State<DiscoverEventScreen> createState() => _DiscoverEventScreenState();
}

class _DiscoverEventScreenState extends State<DiscoverEventScreen> {
  bool _showFiltersDropdown = false;

  final Map<String, bool> _dateFilters = {
    'today': false,
    'tomorrow': false,
    'this week': false,
    'next week': false,
    'this month': false,
    'next month': false,
  };

  final Map<String, bool> _priceFilters = {'free': false, 'paid': false};

  void _toggleFiltersDropdown() {
    setState(() {
      _showFiltersDropdown = !_showFiltersDropdown;
    });
  }

  void _setDateFilter(String key, bool value) {
    setState(() {
      _dateFilters[key] = value;
    });
  }

  void _setPriceFilter(String key, bool value) {
    setState(() {
      _priceFilters[key] = value;
    });
  }

  String _selectedFilter = 'All';
  late TextEditingController _searchController;
  String _submittedSearchQuery = '';

  static const List<String> _filterChips = [
    'All',
    'Technology',
    'Music',
    'Entertainment',
    'Career',
    'Sports',
    'Workshops',
  ];

  List<Map<String, dynamic>> get _discoverEvents {
    return SqliteBackend().events
        .where((e) =>
            e['title']?.toString().toLowerCase() != 'demo event' &&
            e['visibility']?.toString() != 'Private')
        .map((event) {
      return {
        'id': event['id'],
        'title': event['title'] ?? 'Untitled Event',
        'date': event['date'] ?? '',
        'location': event['location'] ?? 'TBA',
        'category': event['category'] ?? 'Other',
        'description': event['description'] ?? '',
        'bannerImageData': event['bannerImageData'],
        'organizer': event['organizer'] ?? 'UniSphere',
        'imageColor': const Color(0xFFE0E7FF),
        'icon': Icons.event_rounded,
      };
    }).toList();
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> events = _selectedFilter == 'All'
        ? _discoverEvents
        : _discoverEvents
              .where((event) => event['category'] == _selectedFilter)
              .toList();

    if (_submittedSearchQuery.isEmpty) {
      return events;
    }

    final searchLower = _submittedSearchQuery.toLowerCase();

    return events.where((event) {
      final titleLower = (event['title'] as String).toLowerCase();
      final categoryLower = (event['category'] as String).toLowerCase();
      return titleLower.contains(searchLower) ||
          categoryLower.contains(searchLower);
    }).toList();
  }

  Widget _buildEventCardImage(Map<String, dynamic> event) {
    final bannerData = event['bannerImageData'];
    final Uint8List? bannerBytes = bannerData is Uint8List ? bannerData : null;

    if (bannerBytes != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Image.memory(
          bannerBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    } else {
      return Center(
        child: Icon(
          event['icon'] as IconData,
          size: 42,
          color: const Color(0xFF4F46E5),
        ),
      );
    }
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
                        onHostEventTap: () {
                          Navigator.pushNamed(context, '/create-event');
                        },
                        onRegisterTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        onFindEventsTap: () {
                          // already on this page
                        },
                        onCreateEventsTap: () {
                          Navigator.pushNamed(context, '/create-event');
                        },
                        onMyTicketsTap: () {
                          Navigator.pushNamed(context, '/my-tickets');
                        },
                        onAboutTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        onSignInTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        showProfile: true,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 32,
                                vertical: 28,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 860,
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
                                                setState(() {});
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
                                              _toggleFiltersDropdown();
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
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A1F36),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 10,
                                              children: _dateFilters.keys.map((
                                                filter,
                                              ) {
                                                final isSelected =
                                                    _dateFilters[filter]!;

                                                return GestureDetector(
                                                  onTap: () => _setDateFilter(
                                                    filter,
                                                    !isSelected,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF4F46E5,
                                                            ).withOpacity(0.12)
                                                          : Colors.white,
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
                                                                      0xFFE5E7EB,
                                                                    ),
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
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
                                                        Text(filter),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),

                                            const SizedBox(height: 28),

                                            const Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A1F36),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 10,
                                              children: _priceFilters.keys.map((
                                                filter,
                                              ) {
                                                final isSelected =
                                                    _priceFilters[filter]!;

                                                return GestureDetector(
                                                  onTap: () => _setPriceFilter(
                                                    filter,
                                                    !isSelected,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF4F46E5,
                                                            ).withOpacity(0.12)
                                                          : Colors.white,
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
                                                                      0xFFE5E7EB,
                                                                    ),
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
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
                                                        Text(filter),
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
                                    if (_submittedSearchQuery.isEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                                        ? const Color(
                                                            0xFF4F46E5,
                                                          )
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
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
                                                  child: Text(
                                                    chip,
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF1A1F36,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    if (_submittedSearchQuery.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          'Showing results for \'$_submittedSearchQuery\'',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 28),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final availableWidth =
                                            constraints.maxWidth;
                                        final crossAxisCount =
                                            availableWidth > 800
                                                ? 3
                                                : (availableWidth > 400 ? 2 : 1);

                                        return GridView.builder(
                                          itemCount: _filteredEvents.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.72,
                                          ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final event =
                                                _filteredEvents[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.04),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            event['imageColor']
                                                                as Color,
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    22,
                                                                  ),
                                                            ),
                                                      ),
                                                      child:
                                                          _buildEventCardImage(
                                                            event,
                                                          ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          18,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          event['title']
                                                              as String,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                  0xFF1A1F36,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          event['date']
                                                              as String,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          event['location']
                                                              as String,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'By ${event['organizer']?.toString() ?? 'UniSphere'}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF9CA3AF,
                                                                ),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 14,
                                                        ),
                                                        Wrap(
                                                          alignment: WrapAlignment.spaceBetween,
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 6,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                      0xFFEEF2FF,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      999,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                event['category']
                                                                    as String,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xFF4F46E5,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        EventDetailsScreen(
                                                                          event:
                                                                              event,
                                                                        ),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                'Details',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
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
