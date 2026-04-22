import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'create_event_screen.dart';

class DiscoverEventScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const DiscoverEventScreen({super.key, this.initialSearchQuery});

  @override
  State<DiscoverEventScreen> createState() => _DiscoverEventScreenState();
}

class _DiscoverEventScreenState extends State<DiscoverEventScreen> {
  String _selectedFilter = 'All';
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _submittedSearchQuery = '';

  static const List<String> _filterChips = [
    'All',
    'Technology',
    'Music',
    'Career',
    'Sports',
    'Workshops',
  ];

  static const List<Map<String, dynamic>> _discoverEvents = [
    {
      'title': 'Campus Tech Meetup',
      'date': 'Today • 6:30 PM',
      'location': 'Innovation Hub',
      'category': 'Technology',
      'imageColor': Color(0xFFE0E7FF),
      'icon': Icons.memory_rounded,
    },
    {
      'title': 'Indie Music Night',
      'date': 'Fri • 8:00 PM',
      'location': 'Student Union Hall',
      'category': 'Music',
      'imageColor': Color(0xFFFCE7F3),
      'icon': Icons.music_note_rounded,
    },
    {
      'title': 'Startup Networking',
      'date': 'Sat • 3:00 PM',
      'location': 'Business School',
      'category': 'Career',
      'imageColor': Color(0xFFDCFCE7),
      'icon': Icons.handshake_rounded,
    },
    {
      'title': 'Wellbeing Workshop',
      'date': 'Mon • 11:00 AM',
      'location': 'Room B204',
      'category': 'Workshops',
      'imageColor': Color(0xFFE0F2FE),
      'icon': Icons.spa_rounded,
    },
    {
      'title': 'Design Showcase',
      'date': 'Tue • 5:00 PM',
      'location': 'Creative Studio',
      'category': 'Technology',
      'imageColor': Color(0xFFFFF7ED),
      'icon': Icons.palette_rounded,
    },
    {
      'title': 'Charity Fun Run',
      'date': 'Sun • 9:00 AM',
      'location': 'University Grounds',
      'category': 'Sports',
      'imageColor': Color(0xFFFFEDD5),
      'icon': Icons.directions_run_rounded,
    },
  ];

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _searchQuery = widget.initialSearchQuery!;
      _submittedSearchQuery = widget.initialSearchQuery!;
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> events = _selectedFilter == 'All'
        ? _discoverEvents
        : _discoverEvents
              .where((event) => event['category'] == _selectedFilter)
              .toList();

    if (_searchQuery.isEmpty) {
      return events;
    }

    final searchLower = _searchQuery.toLowerCase();
    return events.where((event) {
      final titleLower = (event['title'] as String).toLowerCase();
      final categoryLower = (event['category'] as String).toLowerCase();
      return titleLower.contains(searchLower) ||
          categoryLower.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              onHostEventTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              onRegisterTap: () {
                Navigator.pushNamed(context, '/register');
              },
              onFindEventsTap: () {
                // already on this page
              },
              onCreateEventsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              onMyTicketsTap: () {},
              onAboutTap: () {},
              onSignInTap: () {
                Navigator.pushNamed(context, '/login');
              },
              showProfile: false,
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
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _submittedSearchQuery = '';
                                      });
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _submittedSearchQuery = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search events...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF9CA3AF),
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
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
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    // optional extra filter actions
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
                          if (_submittedSearchQuery.isEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _filterChips.map((chip) {
                                    final isSelected = chip == _selectedFilter;
                                    return GestureDetector(
                                      onTap: () => _setFilter(chip),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF4F46E5)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
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
                              final availableWidth = constraints.maxWidth;
                              final crossAxisCount = availableWidth > 800
                                  ? 3
                                  : (availableWidth > 400 ? 2 : 1);

                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _filteredEvents.map((event) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
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
                                                  event['imageColor'] as Color,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(22),
                                                  ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                event['icon'] as IconData,
                                                size: 42,
                                                color: const Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event['title'] as String,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1F36),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                event['date'] as String,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                event['location'] as String,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
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
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF4F46E5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  TextButton(
                                                    onPressed: () {},
                                                    child: const Text(
                                                      'View details',
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
                                }).toList(),
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
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
