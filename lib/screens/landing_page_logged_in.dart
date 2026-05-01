import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'event_details_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'create_event_screen.dart';
import 'my_tickets_screen.dart';
import 'my_events_page.dart';

class PersonalizedLandingPage extends StatefulWidget {
  final String userName;
  final String role;

  const PersonalizedLandingPage({
    super.key,
    this.userName = 'Alex',
    this.role = 'Attendee',
  });

  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color softBlue = Color(0xFFEEF2FF);

  @override
  State<PersonalizedLandingPage> createState() =>
      _PersonalizedLandingPageState();
}

class _PersonalizedLandingPageState extends State<PersonalizedLandingPage> {
  // State variables
  late String _selectedFilter;
  late String _searchQuery;
  late TextEditingController _searchController;
  late bool _showFiltersDropdown;
  late Map<String, bool> _dateFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'All';
    _searchQuery = '';
    _searchController = TextEditingController();
    _showFiltersDropdown = false;
    _dateFilters = {
      'today': false,
      'tomorrow': false,
      'this week': false,
      'next week': false,
      'this month': false,
      'next month': false,
    };
    SqliteBackend().addListener(_onBackendChanged);
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

  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleFiltersDropdown() {
    setState(() {
      _showFiltersDropdown = !_showFiltersDropdown;
    });
  }

  void _setDateFilter(String filter, bool value) {
    setState(() {
      _dateFilters[filter] = value;
    });
  }

  List<Map<String, dynamic>> get _organiserLiveEvents {
    final email = SqliteBackend().currentUser?.email;
    if (email == null) return [];

    return SqliteBackend().events
        .where((event) => 
            event['organizerEmail']?.toString() == email && 
            event['title']?.toString().toLowerCase() != 'demo event')
        .map(_toDashboardEvent)
        .toList();
  }

  List<Map<String, dynamic>> get _upcomingEventsWithinNextMonth {
    final isOrganiser =
        (SqliteBackend().currentUser?.isOrganiser ?? false) ||
        widget.role.toLowerCase() == 'organiser';

    if (isOrganiser) {
      return _organiserLiveEvents;
    }

    return SqliteBackend().purchasedTickets
        .where((t) => t.title.toLowerCase() != 'demo event')
        .map((ticket) {
      // Find the actual event by matching title
      final matchingEvent = SqliteBackend().events.firstWhere(
        (event) => event['title']?.toString() == ticket.title,
        orElse: () => {},
      );

      return {
        'title': ticket.title,
        'date': ticket.date,
        'eventDate': DateTime.now().add(const Duration(days: 10)),
        'location': ticket.location,
        'category': ticket.category,
        'icon': Icons.confirmation_number_outlined,
        'color': const Color(0xFF4F46E5),
        'bannerImageData': matchingEvent.isNotEmpty
            ? matchingEvent['bannerImageData']
            : null,
        'organizer': matchingEvent.isNotEmpty
            ? (matchingEvent['organizer']?.toString() ?? 'UniSphere')
            : 'UniSphere',
      };
    }).toList();
  }

  Map<String, dynamic> _toDashboardEvent(Map<String, dynamic> event) {
    final category = event['category']?.toString() ?? 'Other';
    final color = _dashboardColorForCategory(category);
    final dateText = event['date']?.toString() ?? '';

    return {
      'title': event['title']?.toString() ?? 'Untitled Event',
      'date': dateText,
      'location': event['location']?.toString() ?? 'TBA',
      'category': category,
      'color': color,
      'icon': _dashboardIconForCategory(category),
      'bannerImageData': event['bannerImageData'],
      'organizer': event['organizer']?.toString() ?? 'UniSphere',
    };
  }

  Color _dashboardColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return const Color(0xFF0F766E);
      case 'tech':
      case 'technology':
        return const Color(0xFF4F46E5);
      case 'career':
        return const Color(0xFFEA580C);
      case 'sports':
        return const Color(0xFF16A34A);
      case 'music':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  IconData _dashboardIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.groups_rounded;
      case 'tech':
      case 'technology':
        return Icons.code_rounded;
      case 'career':
        return Icons.work_outline_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final backendEvents = SqliteBackend().events
        .where((e) => e['title']?.toString().toLowerCase() != 'demo event')
        .map(
          (event) => {
            'id': event['id'],
            'title': event['title'] ?? 'Untitled Event',
            'date': event['date'] ?? '',
            'location': event['location'] ?? 'TBA',
            'category': event['category'] ?? 'Other',
            'description': event['description'] ?? '',
            'imageColor': const Color(0xFFE0E7FF),
            'icon': Icons.event_rounded,
            'bannerImageData': event['bannerImageData'],
            'organizer': event['organizer'] ?? 'UniSphere',
          },
        )
        .toList();

    final baseEvents = _selectedFilter == 'All'
        ? backendEvents
        : backendEvents
              .where((event) => event['category'] == _selectedFilter)
              .toList();

    if (_searchQuery.isEmpty) {
      return baseEvents;
    }

    final query = _searchQuery.toLowerCase();
    return baseEvents.where((event) {
      final category = (event['category'] as String).toLowerCase();
      final title = (event['title'] as String).toLowerCase();
      final titleWords = title.split(' ');

      return category.startsWith(query) ||
          titleWords.any((word) => word.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isOrganiser =
        SqliteBackend().currentUser?.isOrganiser ??
        widget.role.toLowerCase() == 'organiser';
    final upcomingEvents = _upcomingEventsWithinNextMonth;

    return Scaffold(
      backgroundColor: PersonalizedLandingPage.background,
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
                        onFindEventsTap: () {
                          Navigator.pushNamed(context, '/discover');
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
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 1100;

                          if (isMobile) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _DiscoverSection(
                                    userName: widget.userName,
                                    isOrganiser: isOrganiser,
                                    selectedFilter: _selectedFilter,
                                    filteredEvents: _filteredEvents,
                                    onFilterChanged: _setFilter,
                                    searchController: _searchController,
                                    onSearchChanged: _setSearchQuery,
                                    showFiltersDropdown: _showFiltersDropdown,
                                    dateFilters: _dateFilters,
                                    onToggleFiltersDropdown:
                                        _toggleFiltersDropdown,
                                    onDateFilterChanged: _setDateFilter,
                                  ),
                                  const SizedBox(height: 20),
                                  _DashboardPanel(
                                    userName: widget.userName,
                                    isOrganiser: isOrganiser,
                                    upcomingEvents: upcomingEvents,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1400,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          28,
                                          28,
                                          20,
                                          28,
                                        ),
                                        child: _DiscoverSection(
                                          userName: widget.userName,
                                          isOrganiser: isOrganiser,
                                          selectedFilter: _selectedFilter,
                                          filteredEvents: _filteredEvents,
                                          onFilterChanged: _setFilter,
                                          searchController: _searchController,
                                          onSearchChanged: _setSearchQuery,
                                          showFiltersDropdown:
                                              _showFiltersDropdown,
                                          dateFilters: _dateFilters,
                                          onToggleFiltersDropdown:
                                              _toggleFiltersDropdown,
                                          onDateFilterChanged: _setDateFilter,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 430,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                          left: BorderSide(
                                            color:
                                                PersonalizedLandingPage.border,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: _DashboardPanel(
                                          userName: widget.userName,
                                          isOrganiser: isOrganiser,
                                          upcomingEvents: upcomingEvents,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
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

class _DiscoverSection extends StatelessWidget {
  final String userName;
  final bool isOrganiser;
  final String selectedFilter;
  final List<Map<String, dynamic>> filteredEvents;
  final Function(String) onFilterChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool showFiltersDropdown;
  final Map<String, bool> dateFilters;
  final VoidCallback onToggleFiltersDropdown;
  final Function(String, bool) onDateFilterChanged;

  const _DiscoverSection({
    required this.userName,
    required this.isOrganiser,
    required this.selectedFilter,
    required this.filteredEvents,
    required this.onFilterChanged,
    required this.searchController,
    required this.onSearchChanged,
    required this.showFiltersDropdown,
    required this.dateFilters,
    required this.onToggleFiltersDropdown,
    required this.onDateFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopWelcomeStrip(userName: userName, isOrganiser: isOrganiser),
        const SizedBox(height: 24),
        _SearchAndFilters(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          showFiltersDropdown: showFiltersDropdown,
          dateFilters: dateFilters,
          onToggleFiltersDropdown: onToggleFiltersDropdown,
          onDateFilterChanged: onDateFilterChanged,
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Discover newest events',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: PersonalizedLandingPage.text,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore fresh picks, trending categories, and events happening around your university.',
                    style: TextStyle(
                      fontSize: 16,
                      color: PersonalizedLandingPage.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 24),
        _CategoryChips(
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 800;
            final crossAxisCount = isSmall ? 1 : 2;

            return GridView.builder(
              itemCount: filteredEvents.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: isSmall ? 1.6 : 0.85,
              ),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return _DiscoverEventCard(event: event);
              },
            );
          },
        ),
      ],
    );
  }
}

class _TopWelcomeStrip extends StatelessWidget {
  final String userName;
  final bool isOrganiser;

  const _TopWelcomeStrip({required this.userName, required this.isOrganiser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PersonalizedLandingPage.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PersonalizedLandingPage.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: PersonalizedLandingPage.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PersonalizedLandingPage.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOrganiser
                      ? 'Manage events, review performance, and keep your listings active.'
                      : 'Jump back into discovery and see what’s happening next.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: PersonalizedLandingPage.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PersonalizedLandingPage.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Create Events'),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool showFiltersDropdown;
  final Map<String, bool> dateFilters;
  final VoidCallback onToggleFiltersDropdown;
  final Function(String, bool) onDateFilterChanged;

  const _SearchAndFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.showFiltersDropdown,
    required this.dateFilters,
    required this.onToggleFiltersDropdown,
    required this.onDateFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PersonalizedLandingPage.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: PersonalizedLandingPage.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        decoration: const InputDecoration(
                          hintText:
                              'Search events, societies, categories, places...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: PersonalizedLandingPage.text,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: onToggleFiltersDropdown,
              child: Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PersonalizedLandingPage.border),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: PersonalizedLandingPage.primary,
                ),
              ),
            ),
          ],
        ),
        if (showFiltersDropdown) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PersonalizedLandingPage.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PersonalizedLandingPage.text,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 440;
                    final itemWidth =
                        (constraints.maxWidth - (isWide ? 32 : 24)) /
                        (isWide ? 3 : 2);

                    return Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children:
                          [
                            'today',
                            'tomorrow',
                            'this week',
                            'next week',
                            'this month',
                            'next month',
                          ].map((filter) {
                            return SizedBox(
                              width: itemWidth,
                              child: GestureDetector(
                                onTap: () => onDateFilterChanged(
                                  filter,
                                  !dateFilters[filter]!,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dateFilters[filter]!
                                        ? PersonalizedLandingPage.primary
                                              .withOpacity(0.12)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: dateFilters[filter]!
                                          ? PersonalizedLandingPage.primary
                                          : PersonalizedLandingPage.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: dateFilters[filter]!
                                                ? PersonalizedLandingPage
                                                      .primary
                                                : PersonalizedLandingPage
                                                      .border,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          color: dateFilters[filter]!
                                              ? PersonalizedLandingPage.primary
                                              : Colors.white,
                                        ),
                                        child: dateFilters[filter]!
                                            ? const Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          filter,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: PersonalizedLandingPage.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _CategoryChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      'All',
      'Technology',
      'Music',
      'Entertainment',
      'Career',
      'Sports',
      'Workshops',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips.map((chip) {
        final isSelected = chip == selectedFilter;
        return GestureDetector(
          onTap: () => onFilterChanged(chip),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? PersonalizedLandingPage.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? PersonalizedLandingPage.primary
                    : PersonalizedLandingPage.border,
              ),
            ),
            child: Text(
              chip,
              style: TextStyle(
                color: isSelected ? Colors.white : PersonalizedLandingPage.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DiscoverEventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _DiscoverEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event['imageColor'] as Color;
    final icon = event['icon'] as IconData;
    final bannerData = event['bannerImageData'];
    final Uint8List? bannerBytes = bannerData is Uint8List ? bannerData : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PersonalizedLandingPage.border),
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: _buildEventCardImage(bannerBytes, icon),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PersonalizedLandingPage.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['date'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: PersonalizedLandingPage.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['location'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: PersonalizedLandingPage.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'By ${event['organizer']?.toString() ?? 'UniSphere'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PersonalizedLandingPage.muted,
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
                        color: PersonalizedLandingPage.softBlue,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event['category'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PersonalizedLandingPage.primary,
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
                      child: const Text('View details'),
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

  Widget _buildEventCardImage(Uint8List? bannerBytes, IconData icon) {
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
        child: Icon(icon, size: 42, color: PersonalizedLandingPage.primary),
      );
    }
  }
}

class _DashboardPanel extends StatelessWidget {
  final String userName;
  final bool isOrganiser;
  final List<Map<String, dynamic>> upcomingEvents;

  const _DashboardPanel({
    required this.userName,
    required this.isOrganiser,
    required this.upcomingEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: PersonalizedLandingPage.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isOrganiser
              ? 'Your event activity at a glance.'
              : 'Your activity and upcoming plans in one place.',
          style: TextStyle(fontSize: 15, color: PersonalizedLandingPage.muted),
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: PersonalizedLandingPage.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: PersonalizedLandingPage.softBlue,
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: PersonalizedLandingPage.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: PersonalizedLandingPage.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOrganiser ? 'Organiser account' : 'Attendee account',
                      style: TextStyle(
                        fontSize: 13,
                        color: PersonalizedLandingPage.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (SqliteBackend().currentUser != null) {
                    Navigator.pushNamed(context, '/profile');
                  } else {
                    Navigator.pushNamed(context, '/register');
                  }
                },
                icon: const Icon(Icons.settings_outlined),
                color: PersonalizedLandingPage.muted,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isOrganiser
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyEventsPage(),
                          ),
                        );
                      }
                    : null,
                child: Builder(
                  builder: (context) {
                    final liveCount = isOrganiser
                        ? SqliteBackend().events
                              .where(
                                (e) =>
                                    e['organizerEmail']?.toString() ==
                                    SqliteBackend().currentUser?.email,
                              )
                              .length
                        : SqliteBackend().purchasedTickets.length;
                    return _DashboardMetricCard(
                      title: isOrganiser ? 'Live Events' : 'Events Joined',
                      value: '$liveCount',
                      icon: isOrganiser
                          ? Icons.event_note_rounded
                          : Icons.event_available_outlined,
                      color: const Color(0xFF4F46E5),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardMetricCard(
                title: 'Upcoming',
                value: '${upcomingEvents.length}',
                icon: Icons.upcoming_rounded,
                color: const Color(0xFF0F766E),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ListenableBuilder(
          listenable: SqliteBackend(),
          builder: (context, _) {
            final ticketCount = SqliteBackend().purchasedTickets.length;
            final organiserEventCount = SqliteBackend().events
                .where(
                  (event) =>
                      event['organizerEmail']?.toString() ==
                      SqliteBackend().currentUser?.email,
                )
                .length;
            final organiserViews = organiserEventCount * 1000;
            return _DashboardMetricCard(
              title: isOrganiser ? 'Total Views' : 'My Tickets',
              value: isOrganiser
                  ? _formatCompactCount(organiserViews)
                  : '$ticketCount',
              icon: isOrganiser
                  ? Icons.bar_chart_rounded
                  : Icons.confirmation_number_outlined,
              color: const Color(0xFFEA580C),
              fullWidth: true,
            );
          },
        ),

        const SizedBox(height: 22),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!isOrganiser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyTicketsScreen(),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateEventScreen(),
                    ),
                  );
                },
                icon: Icon(
                  isOrganiser
                      ? Icons.add_rounded
                      : Icons.confirmation_number_outlined,
                  size: 18,
                ),
                label: Text(isOrganiser ? 'Create' : 'My Tickets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PersonalizedLandingPage.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: PersonalizedLandingPage.text,
          ),
        ),
        const SizedBox(height: 14),

        if (upcomingEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PersonalizedLandingPage.border),
            ),
            child: const Text(
              'No upcoming events in the next 30 days.',
              style: TextStyle(
                fontSize: 14,
                color: PersonalizedLandingPage.muted,
              ),
            ),
          )
        else ...[
          if (upcomingEvents.isNotEmpty && upcomingEvents.first['bannerImageData'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Image.memory(
                      upcomingEvents.first['bannerImageData'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[200],
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEXT EVENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            upcomingEvents.first['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ...upcomingEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UpcomingEventCard(event: event),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _DashboardMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PersonalizedLandingPage.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: PersonalizedLandingPage.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCompactCount(int value) {
  if (value <= 0) return '0';
  if (value < 1000) return '$value';

  final thousands = value ~/ 1000;
  final remainder = value % 1000;
  if (remainder == 0) {
    return '${thousands}K';
  }

  return '${thousands}.${(remainder / 100).floor()}K';
}

class _UpcomingEventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event['color'] as Color;
    final bannerData = event['bannerImageData'];
    final Uint8List? bannerBytes = bannerData is Uint8List ? bannerData : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PersonalizedLandingPage.border),
      ),
      child: Row(
        children: [
          bannerBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    bannerBytes,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 46,
                      height: 46,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                )
              : Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    event['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PersonalizedLandingPage.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['date'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: PersonalizedLandingPage.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event['location'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: PersonalizedLandingPage.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              event['category'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
