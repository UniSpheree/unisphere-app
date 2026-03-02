// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/header.dart';

class DashboardScreen extends StatelessWidget {
  final String role; // 'Attendee' | 'Organiser'

  const DashboardScreen({super.key, this.role = 'Attendee'});

  // Fake upcoming events for the attendee dashboard
  static const _upcomingEvents = [
    {
      'title': 'Flutter Workshop',
      'category': 'Workshop',
      'date': 'Mar 10, 2026 · 14:00',
      'venue': 'Room A101',
      'icon': Icons.code,
      'color': Color(0xFF2D3A8C),
    },
    {
      'title': 'Career Fair 2026',
      'category': 'Career',
      'date': 'Mar 15, 2026 · 10:00',
      'venue': 'Main Hall',
      'icon': Icons.work_outline,
      'color': Color(0xFF00897B),
    },
    {
      'title': 'Sports Day',
      'category': 'Sports',
      'date': 'Mar 20, 2026 · 09:00',
      'venue': 'University Grounds',
      'icon': Icons.sports_soccer,
      'color': Color(0xFFE65100),
    },
    {
      'title': 'Academic Symposium',
      'category': 'Academic',
      'date': 'Mar 25, 2026 · 13:00',
      'venue': 'Lecture Theatre B',
      'icon': Icons.school_outlined,
      'color': Color(0xFF6A1B9A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppHeader(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back breadcrumb ─────────────────────────────────
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Text(
                          '  /  ',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Color(0xFF1A1F36),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Welcome banner ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D3A8C), Color(0xFF4A5CBA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back, Alex! 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Discover and join university events around you.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.celebration_outlined,
                            color: Colors.white,
                            size: 48,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Organiser call-to-action ────────────────────────
                    if (role == 'Organiser') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2D3A8C).withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3A8C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ready to create an event?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Manage and publish your university events.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/create-event',
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Login to Create Events'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D3A8C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Stats row ───────────────────────────────────────
                    Row(
                      children: [
                        _StatCard(
                          label: 'Events Joined',
                          value: '8',
                          icon: Icons.event_available_outlined,
                          color: const Color(0xFF2D3A8C),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Upcoming',
                          value: '4',
                          icon: Icons.upcoming_outlined,
                          color: const Color(0xFF00897B),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'My Tickets',
                          value: '3',
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFFE65100),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Upcoming events ─────────────────────────────────
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 14),

                    ...(_upcomingEvents.map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: event),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event card ─────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(event['icon'] as IconData, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${event['date']}  ·  ${event['venue']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
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
