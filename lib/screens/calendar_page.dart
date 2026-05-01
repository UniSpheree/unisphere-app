import 'package:flutter/material.dart';
import '../utils/mock_backend.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentWeekStart = _getStartOfWeek(DateTime(2026, 5, 17));

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = MockBackend().currentUser;
    final isOrganiser = user?.isOrganiser ?? false;

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
                        onHostEventTap: () => Navigator.pushNamed(context, '/create-event'),
                        onFindEventsTap: () => Navigator.pushNamed(context, '/discover'),
                        onCreateEventsTap: () => Navigator.pushNamed(context, '/create-event'),
                        onMyTicketsTap: () => Navigator.pushNamed(context, '/my-tickets'),
                        onAboutTap: () => Navigator.pushNamed(context, '/about'),
                        onSignInTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                      if (!isOrganiser)
                        _buildLockedState(context)
                      else
                        _buildCalendarView(context, constraints),
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

  Widget _buildLockedState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF4F46E5),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Organiser calendar locked',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Switch your profile to Organiser to view the calendar for events you create and schedule new experiences.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Open profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, BoxConstraints constraints) {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final weekDates = List.generate(
      7,
      (i) => _currentWeekStart.add(Duration(days: i)),
    );
    final hours = List.generate(24, (i) => i);
    final isMobile = constraints.maxWidth < 800;

    final email = MockBackend().currentUser?.email;
    final userEvents = MockBackend().events.where((e) => e['organizerEmail']?.toString() == email).toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
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
                      'Back',
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
                      'Organiser Calendar',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Organiser Calendar',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_monthName(weekDates.first.month)} ${weekDates.first.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: _goToPreviousWeek,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: _goToNextWeek,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    
                    // Days Row
                    Container(
                      color: const Color(0xFFF9FAFB),
                      padding: const EdgeInsets.only(left: 60),
                      child: Row(
                        children: List.generate(7, (i) {
                          // Check if "today" is in this week for highlight
                          final now = DateTime.now();
                          final isToday = weekDates[i].day == 20 && weekDates[i].month == 5; // Hardcoded mock today
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    daysOfWeek[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isToday ? const Color(0xFF4F46E5) : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isToday ? const Color(0xFF4F46E5) : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${weekDates[i].day}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                          color: isToday ? Colors.white : const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    
                    // Hours Grid
                    SizedBox(
                      height: 600,
                      child: ListView.builder(
                        itemCount: hours.length,
                        itemBuilder: (context, hourIdx) {
                          final hour = hours[hourIdx];
                          return SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, right: 12),
                                      child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...List.generate(7, (dayIdx) {
                                  final dayDate = weekDates[dayIdx];
                                  
                                  final matchingEvents = userEvents.where((e) {
                                    try {
                                      final start = DateTime.parse(e['date'].toString());
                                      final end = e['endDate'] != null 
                                          ? DateTime.parse(e['endDate'].toString())
                                          : start.add(const Duration(hours: 1));
                                      
                                      // Check if this hour/day slot falls within start and end
                                      final slotStart = DateTime(dayDate.year, dayDate.month, dayDate.day, hour);
                                      final slotEnd = slotStart.add(const Duration(hours: 1));
                                      
                                      return (start.isBefore(slotEnd) && end.isAfter(slotStart));
                                    } catch (_) {
                                      return false;
                                    }
                                  }).toList();

                                  return Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Color(0xFFF3F4F6)),
                                          bottom: BorderSide(color: Color(0xFFF3F4F6)),
                                        ),
                                      ),
                                      child: Stack(
                                        children: matchingEvents.map((ev) {
                                          return _buildEventBlock(ev, hour, dayDate);
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventBlock(Map<String, dynamic> event, int currentHour, DateTime currentDay) {
    // Precise positioning would require calculating offset if it starts mid-hour
    // For now, we'll just show it in the slots it overlaps
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF).withOpacity(0.9),
          border: Border.all(color: const Color(0xFF818CF8)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title']?.toString() ?? 'Event',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3730A3),
              ),
            ),
            if (event['location'] != null)
              Text(
                event['location'].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF4F46E5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}
