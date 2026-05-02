import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/models/database_models.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool allowPurchase;

  const EventDetailsScreen({
    super.key,
    required this.event,
    this.allowPurchase = true,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  void _onBackendChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SqliteBackend().addListener(_onBackendChanged);
  }

  @override
  void dispose() {
    SqliteBackend().removeListener(_onBackendChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEventId = widget.event['id']?.toString();
    final latestEvent = currentEventId == null
        ? widget.event
        : SqliteBackend().events.firstWhere(
            (e) => e['id']?.toString() == currentEventId,
            orElse: () => widget.event,
          );
    final isDeleted = currentEventId != null &&
        !SqliteBackend().events.any((e) => e['id']?.toString() == currentEventId);

    if (isDeleted) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F8),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_busy, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    'This event was deleted',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The event is no longer available.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final event = latestEvent;
    final allowPurchase = widget.allowPurchase;
    final color = event['color'] as Color? ?? const Color(0xFF4F46E5);
    final description =
        event['description'] as String? ??
        'No extra description provided for this event.';
    final bannerImageData = event['bannerImageData'];
    final Uint8List? bannerBytes = bannerImageData is Uint8List
        ? bannerImageData
        : null;

    final organizer =
        event['organizer'] as String? ?? 'Organizer not specified';
    final capacity = event['capacity'] != null ? '${event['capacity']}' : null;
    final tags = (event['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final price = (event['price'] as String?)?.trim();

    final eventId = int.tryParse(event['id']?.toString() ?? '');
    final canonicalEvent = SqliteBackend().events.cast<Map<String, dynamic>?>().firstWhere(
      (e) =>
        e != null &&
        int.tryParse(e['id']?.toString() ?? '') == eventId,
      orElse: () => null,
    );
    final organizerEmail =
      (canonicalEvent?['organizerEmail'] ?? event['organizerEmail'])
        ?.toString() ??
      '';

    final isOrganizerViewing =
      SqliteBackend().currentUser?.email == organizerEmail;

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
                      const AppHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
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
                                    Flexible(
                                      child: Text(
                                        event['title'] as String,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Large header card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (bannerBytes != null) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.memory(
                                            bannerBytes,
                                            width: double.infinity,
                                            height: 240,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 240,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                      Text(
                                        event['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            event['date'] as String,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              event['location'] as String,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.10),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              event['category'] as String,
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          if (tags.isNotEmpty)
                                            ...tags.map(
                                              (t) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Text(
                                                  t,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: color.withOpacity(
                                              0.1,
                                            ),
                                            child: Icon(
                                              Icons.person_outline,
                                              size: 20,
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Organizer',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              Text(
                                                organizer,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (capacity != null) ...[
                                            const SizedBox(width: 40),
                                            Icon(
                                              Icons.people_outline,
                                              size: 20,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Capacity: $capacity',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Description
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'About this event',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.6,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Action bar
                                if (allowPurchase && !isOrganizerViewing)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (price != null && price.isNotEmpty)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Price per ticket',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              Text(
                                                price,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ],
                                          ),
                                        FilledButton(
                                          onPressed: () {
                                            if (SqliteBackend().currentUser ==
                                                null) {
                                              final pending = DbPurchasedTicket(
                                                userEmail: '',
                                                title: event['title'] as String,
                                                date: event['date'] as String,
                                                location:
                                                    event['location'] as String,
                                                category:
                                                    event['category'] as String,
                                                price: price ?? '',
                                                purchasedAt: DateTime.now(),
                                              );
                                              SqliteBackend()
                                                  .setPendingPurchase(pending);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please register or sign in to complete your purchase.',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                              Navigator.pushNamed(
                                                context,
                                                '/register',
                                              );
                                              return;
                                            }

                                            SqliteBackend().purchaseTicket(
                                              DbPurchasedTicket(
                                                userEmail:
                                                    SqliteBackend()
                                                        .currentUser
                                                        ?.email ??
                                                    '',
                                                title: event['title'] as String,
                                                date: event['date'] as String,
                                                location:
                                                    event['location'] as String,
                                                category:
                                                    event['category'] as String,
                                                price: price ?? '',
                                                purchasedAt: DateTime.now(),
                                                eventId: int.tryParse(
                                                  event['id']?.toString() ?? '',
                                                ),
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Ticket purchased for ${event['title']}',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                            Navigator.pushNamed(
                                              context,
                                              '/my-tickets',
                                            );
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: color,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Text(
                                            'Buy ticket now',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (isOrganizerViewing)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: color.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_available_outlined,
                                          color: color,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Text(
                                            'This is your event. You can manage it from the My Events page.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.18),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Text(
                                            'You already have a ticket for this event.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
