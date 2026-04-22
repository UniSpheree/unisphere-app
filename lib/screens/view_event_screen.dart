import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'create_event_screen.dart';

class ViewEventScreen extends StatefulWidget {
  final String role; // 'admin', 'organiser', 'student'
  final String currentUserId;
  final String organiserId;

  // Backend-friendly event payload fields
  final String? eventId;
  final String eventName;
  final String eventDescription;
  final String eventVenue;
  final String eventCategory;
  final String eventVisibility;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final int maxAttendees;
  final int? availableSlots;
  final String organiserName;
  final String organiserContact;

  // Breadcrumb config for reusable navigation hierarchy.
  final String dashboardLabel;
  final String dashboardRoute;
  final String? middleCrumbLabel;
  final String? middleCrumbRoute;

  const ViewEventScreen({
    super.key,
    required this.role,
    required this.currentUserId,
    required this.organiserId,
    this.eventId,
    this.eventName = 'Event Title',
    this.eventDescription =
        'This is the event description section. You can replace this text with the actual event details, schedule, venue information, and other relevant content.',
    this.eventVenue = 'Main Campus Gym',
    this.eventCategory = 'Sports',
    this.eventVisibility = 'Public',
    this.eventStartDate,
    this.eventEndDate,
    this.maxAttendees = 120,
    this.availableSlots,
    this.organiserName = 'Student Affairs Office',
    this.organiserContact = 'Contact: organiser@unisphere.edu',
    this.dashboardLabel = 'Dashboard',
    this.dashboardRoute = '/dashboard',
    this.middleCrumbLabel,
    this.middleCrumbRoute,
  });

  @override
  _ViewEventScreenState createState() => _ViewEventScreenState();
}

// Placeholder text will be replaced with relevant backend parameters later
class _ViewEventScreenState extends State<ViewEventScreen> {
  bool _hasJoined = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _rightPanelKey = GlobalKey();

  double _heroHeight = 0;
  double _rightPanelHeight = 0;
  double _rightPanelTranslateY = 0;
  late String _eventTitle;
  late String _eventDescription;
  late String _eventVenue;
  late String _eventCategory;
  late String _eventVisibility;
  late DateTime _eventStartDate;
  late DateTime _eventEndDate;
  late int _totalSlots;
  late int _availableSlots;
  late String _organiserName;
  late String _organiserContact;

  bool get canEdit =>
      widget.role == 'admin' ||
      (widget.role == 'organiser' &&
          widget.currentUserId == widget.organiserId);

  @override
  void initState() {
    super.initState();

    // Seed local mutable state from constructor payload so callers can pass
    // event data directly from list/discovery screens or backend responses.
    _eventTitle = widget.eventName;
    _eventDescription = widget.eventDescription;
    _eventVenue = widget.eventVenue;
    _eventCategory = widget.eventCategory;
    _eventVisibility = widget.eventVisibility;
    _eventStartDate = widget.eventStartDate ?? DateTime(2026, 5, 25, 14, 0);
    _eventEndDate = widget.eventEndDate ?? DateTime(2026, 5, 25, 17, 0);
    _totalSlots = widget.maxAttendees;
    _availableSlots = widget.availableSlots ?? widget.maxAttendees;
    _organiserName = widget.organiserName;
    _organiserContact = widget.organiserContact;

    _scrollController.addListener(_handleScrollForStickyPanel);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollForStickyPanel);
    _scrollController.dispose();
    super.dispose();
  }

  // Measures rendered heights of the hero and right panel so sticky movement
  // can be bounded to the hero section's vertical range.
  void _measurePanelBounds() {
    final heroContext = _heroKey.currentContext;
    final panelContext = _rightPanelKey.currentContext;

    if (heroContext == null || panelContext == null) return;

    final heroBox = heroContext.findRenderObject() as RenderBox?;
    final panelBox = panelContext.findRenderObject() as RenderBox?;

    if (heroBox == null || panelBox == null) return;

    final nextHeroHeight = heroBox.size.height;
    final nextRightPanelHeight = panelBox.size.height;

    if (_heroHeight != nextHeroHeight ||
        _rightPanelHeight != nextRightPanelHeight) {
      setState(() {
        _heroHeight = nextHeroHeight;
        _rightPanelHeight = nextRightPanelHeight;
      });
    }
  }

  // Keeps the right panel "sticky" on desktop by translating it with page
  // scroll, clamped so it never moves above the top or past the hero bottom.
  void _handleScrollForStickyPanel() {
    final maxTranslate = (_heroHeight - _rightPanelHeight).clamp(
      0.0,
      double.infinity,
    );
    final nextTranslate = _scrollController.offset.clamp(0.0, maxTranslate);

    if ((_rightPanelTranslateY - nextTranslate).abs() > 0.5) {
      setState(() {
        _rightPanelTranslateY = nextTranslate;
      });
    }
  }

  void _handleJoinEvent() {
    // TODO: replace with backend join-event request when API is available.
    setState(() {
      _hasJoined = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Joined event!!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime value) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month - 1]} ${value.day}, ${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _handleEditEvent() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEventScreen(
          initialEventName: _eventTitle,
          initialDescription: _eventDescription,
          initialVenue: _eventVenue,
          initialMaxAttendees: _totalSlots.toString(),
          initialStartDate: _eventStartDate,
          initialEndDate: _eventEndDate,
          initialCategory: _eventCategory,
          initialVisibility: _eventVisibility,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _eventTitle = (result['eventName'] as String?) ?? _eventTitle;
      _eventDescription =
          (result['description'] as String?) ?? _eventDescription;
      _eventVenue = (result['venue'] as String?) ?? _eventVenue;
      _eventCategory = (result['category'] as String?) ?? _eventCategory;
      _eventVisibility = (result['visibility'] as String?) ?? _eventVisibility;

      final parsedMaxAttendees = int.tryParse(
        (result['maxAttendees'] as String?) ?? '',
      );
      if (parsedMaxAttendees != null) {
        _totalSlots = parsedMaxAttendees;
        _availableSlots = parsedMaxAttendees;
      }

      final startDate = result['startDate'] as DateTime?;
      final endDate = result['endDate'] as DateTime?;
      if (startDate != null) _eventStartDate = startDate;
      if (endDate != null) _eventEndDate = endDate;
    });
  }

  Widget _buildBreadcrumbs() {
    // TODO: Insert Discover Events breadcrumb by passing middleCrumbLabel and middleCrumbRoute from the caller.
    // TODO: Correct breadcrumbs from View-Event to Create-Event
    final hasMiddleCrumb =
        widget.middleCrumbLabel != null && widget.middleCrumbLabel!.isNotEmpty;

    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(context, widget.dashboardRoute),
          borderRadius: BorderRadius.circular(8),
          child: const Icon(Icons.arrow_back, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, widget.dashboardRoute),
          child: Text(
            widget.dashboardLabel,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const Text('  /  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
        if (hasMiddleCrumb) ...[
          GestureDetector(
            onTap: widget.middleCrumbRoute == null
                ? null
                : () => Navigator.pushNamed(context, widget.middleCrumbRoute!),
            child: Text(
              widget.middleCrumbLabel!,
              style: TextStyle(
                color: widget.middleCrumbRoute == null
                    ? Colors.grey
                    : const Color(0xFF2D3A8C),
                fontSize: 14,
              ),
            ),
          ),
          const Text(
            '  /  ',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
        Flexible(
          child: Text(
            _eventTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2D3A8C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || isMobile) return;
      _measurePanelBounds();
      _handleScrollForStickyPanel();
    });

    return Scaffold(
      appBar: AppHeader(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 14),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroSection(),
                            const SizedBox(height: 18),
                            _buildRightPanel(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: KeyedSubtree(
                                key: _heroKey,
                                child: _buildHeroSection(),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 2,
                              child: Transform.translate(
                                offset: Offset(0, _rightPanelTranslateY),
                                child: KeyedSubtree(
                                  key: _rightPanelKey,
                                  child: _buildRightPanel(),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              'https://picsum.photos/900/500', // placeholder image
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _sectionTitle('Organiser', fontSize: 18),
              ],
            ),
          ),
          // Organiser card
          Card(
            margin: EdgeInsets.symmetric(horizontal: 18.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(Icons.person_outline)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_organiserName, overflow: TextOverflow.ellipsis),
                        Text(
                          _organiserContact,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(
                      Icons.calendar_today_outlined,
                      _formatDate(_eventStartDate),
                    ),
                    _infoChip(
                      Icons.access_time_outlined,
                      '${_formatTime(_eventStartDate)} - ${_formatTime(_eventEndDate)}',
                    ),
                    _infoChip(Icons.location_on_outlined, _eventVenue),
                  ],
                ),
                const SizedBox(height: 10),
                _sectionTitle('Overview'),
                const SizedBox(height: 8),
                Text(
                  _eventDescription,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    final double availability = _totalSlots == 0
        ? 0
        : _availableSlots.clamp(0, _totalSlots) / _totalSlots;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionTitle('Availability', fontSize: 18),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: availability,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6D28D9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_availableSlots / $_totalSlots slots Available',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Actions', fontSize: 18),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: canEdit
                    ? _handleEditEvent
                    : _availableSlots == 0
                    ? null
                    : () {
                        _handleJoinEvent();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: canEdit
                      ? const Color.fromARGB(255, 40, 58, 217)
                      : _hasJoined
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  canEdit ? Icons.edit_outlined : Icons.check_circle_outline,
                ),
                label: Text(
                  canEdit ? 'Edit' : (_hasJoined ? 'Joined' : 'Join Event'),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Unvisited share button, may implement later
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6D28D9),
                  side: const BorderSide(color: Color(0xFF6D28D9)),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, {int fontSize = 22}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize.toDouble(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
