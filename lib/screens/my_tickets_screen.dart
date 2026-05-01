import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/event_details_screen.dart';
import 'package:unisphere_app/utils/mock_backend.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _ticketToEvent(PurchasedTicket ticket) {
    return {
      'title': ticket.title,
      'date': ticket.date,
      'location': ticket.location,
      'category': ticket.category,
      'price': ticket.price,
      'description':
          'Ticket details for ${ticket.title}. You can review the event information and keep this ticket handy for check-in.',
      'organizer': 'Event Organiser',
      'capacity': null,
      'tags': <String>['Purchased ticket'],
      'color': const Color(0xFF4F46E5),
    };
  }

  bool _matchesQuery(PurchasedTicket ticket) {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: MockBackend(),
          builder: (context, _) {
            final tickets = MockBackend().purchasedTickets;
            final filteredTickets = tickets.where(_matchesQuery).toList();

            final List<Widget> children = [];

            children.add(
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6D79FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tickets you bought',
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by event, date, venue, or category',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.78),
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
                                    color: Colors.white.withOpacity(0.78),
                                  ),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
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
                          color: const Color(0xFF4F46E5).withOpacity(0.5),
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
                        color: const Color(0xFF4F46E5).withOpacity(0.5),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedTicketCard extends StatelessWidget {
  final PurchasedTicket ticket;
  final VoidCallback onTap;

  const _SavedTicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.confirmation_number_outlined,
            color: Color(0xFF4F46E5),
            size: 26,
          ),
        ),
        title: Text(
          ticket.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('${ticket.date} • ${ticket.location}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ticket.category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ticket.price,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
