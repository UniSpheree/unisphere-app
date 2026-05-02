import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:unisphere_app/screens/event_details_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  Map<String, dynamic>? _findMatchingEvent(DbPurchasedTicket ticket) {
    for (final event in SqliteBackend().events) {
      final eventId = int.tryParse(event['id']?.toString() ?? '');
      if (ticket.eventId != null && eventId == ticket.eventId) {
        return event;
      }
    }

    for (final event in SqliteBackend().events) {
      final sameTitle = event['title']?.toString() == ticket.title;
      final sameDate = event['date']?.toString() == ticket.date;
      final sameLocation = event['location']?.toString() == ticket.location;
      if (sameTitle && sameDate && sameLocation) {
        return event;
      }
    }

    return null;
  }

  bool _hasExistingEvent(DbPurchasedTicket ticket) {
    return _findMatchingEvent(ticket) != null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _ticketToEvent(DbPurchasedTicket ticket) {
    final matchingEvent = _findMatchingEvent(ticket);

    return {
      'id': matchingEvent?['id'],
      'title': ticket.title,
      'date': ticket.date,
      'location': ticket.location,
      'category': ticket.category,
      'price': ticket.price,
      'description':
          'Ticket details for ${ticket.title}. You can review the event information and keep this ticket handy for check-in.',
      'organizer': matchingEvent != null
        ? (matchingEvent['organizer']?.toString() ?? 'UniSphere')
          : 'UniSphere',
      'organizerEmail': matchingEvent != null
        ? matchingEvent['organizerEmail']?.toString()
          : null,
      'bannerImageData': matchingEvent != null
        ? matchingEvent['bannerImageData']
          : null,
      'capacity': null,
      'tags': <String>['Purchased ticket'],
      'color': const Color(0xFF4F46E5),
    };
  }

  bool _matchesQuery(DbPurchasedTicket ticket) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;

    return [
      ticket.title,
      ticket.date,
      ticket.location,
      ticket.category,
      ticket.price,
    ].any((value) => value.toLowerCase().contains(query));
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
                        onFindEventsTap: () =>
                            Navigator.pushNamed(context, '/discover'),
                        onCreateEventsTap: () =>
                            Navigator.pushNamed(context, '/create-event'),
                        onMyTicketsTap: () {},
                        onAboutTap: () =>
                            Navigator.pushNamed(context, '/about'),
                        onSignInTap: () =>
                            Navigator.pushNamed(context, '/login'),
                      ),
                      SafeArea(
                        child: AnimatedBuilder(
                          animation: SqliteBackend(),
                          builder: (context, _) {
                            final tickets = SqliteBackend()
                              .purchasedTickets
                              .where(_hasExistingEvent)
                              .toList();
                            final filteredTickets = tickets
                                .where((t) => _matchesQuery(t) && t.title.toLowerCase() != 'demo event')
                                .toList();

                            final List<Widget> children = [];

                            // Breadcrumbs
                            children.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Row(
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
                                        'My Tickets',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            children.add(
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF6D79FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4F46E5,
                                      ).withOpacity(0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Tickets',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tickets.isEmpty
                                          ? 'You have not bought any tickets yet.'
                                          : 'Search and open any ticket in seconds.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.88),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.16),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          setState(() => _query = value);
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search by event, date, venue, or category',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.72,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            color: Colors.white.withOpacity(
                                              0.78,
                                            ),
                                          ),
                                          suffixIcon: _query.isEmpty
                                              ? null
                                              : IconButton(
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() => _query = '');
                                                  },
                                                  icon: Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.white
                                                        .withOpacity(0.78),
                                                  ),
                                                ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            children.add(const SizedBox(height: 14));

                            if (tickets.isNotEmpty) {
                              children.add(
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _query.trim().isEmpty
                                        ? '${tickets.length} ticket${tickets.length == 1 ? '' : 's'} available'
                                        : '${filteredTickets.length} match${filteredTickets.length == 1 ? '' : 'es'} found',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (tickets.isEmpty) {
                              children.add(
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.confirmation_number_outlined,
                                          size: 40,
                                          color: const Color(
                                            0xFF4F46E5,
                                          ).withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No tickets saved yet',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Go back and browse events to buy one.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else if (filteredTickets.isEmpty) {
                              children.add(
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 40,
                                        color: const Color(
                                          0xFF4F46E5,
                                        ).withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No matching tickets',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Try a different keyword, venue, or category.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              for (final ticket in filteredTickets) {
                                children.add(
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _SavedTicketCard(
                                      ticket: ticket,
                                      eventData: _ticketToEvent(ticket),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EventDetailsScreen(
                                              event: _ticketToEvent(ticket),
                                              allowPurchase: false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 860,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: children,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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

class _SavedTicketCard extends StatelessWidget {
  final DbPurchasedTicket ticket;
  final Map<String, dynamic> eventData;
  final VoidCallback onTap;

  const _SavedTicketCard({
    required this.ticket,
    required this.eventData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bannerData = eventData['bannerImageData'];
    final Uint8List? bannerBytes = bannerData is Uint8List ? bannerData : null;
    final organizer = eventData['organizer']?.toString() ?? 'UniSphere';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading image
            bannerBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      bannerBytes,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Color(0xFF4F46E5),
                      size: 28,
                    ),
                  ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ticket.date} • ${ticket.location}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By $organizer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F46E5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Trailing price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ticket.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
