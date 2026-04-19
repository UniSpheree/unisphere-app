import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/header.dart';

class ViewEventScreen extends StatefulWidget {
  final String role; // 'admin', 'organiser', 'student'
  final String currentUserId;
  final String organiserId;

  const ViewEventScreen({
    super.key,
    required this.role,
    required this.currentUserId,
    required this.organiserId,
  });

  @override
  _ViewEventScreenState createState() => _ViewEventScreenState();
}

// Placeholder text will be replaced with relevant backend parameters later
class _ViewEventScreenState extends State<ViewEventScreen> {
  bool get canEdit =>
      widget.role == 'admin' ||
      (widget.role == 'organiser' && widget.currentUserId == widget.organiserId);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppHeader(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 16),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildHeroSection()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildRightPanelPlaceholder(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // NEW: quick event metadata (high priority for decision-making)
                  // When viewed, the page will state information about the viewed event in segmented chips with correct icons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.calendar_today_outlined, 'May 25, 2026'), // placeholder info
                      _infoChip(Icons.access_time_outlined, '2:00 PM - 5:00 PM'), // placeholder info
                      _infoChip(Icons.location_on_outlined, 'Main Campus Gym'), // placeholder info
                      _infoChip(Icons.group_outlined, '120 slots'), // placeholder info
                      _infoChip(Icons.event_busy_outlined, 'Reg. until May 22'), // placeholder info
                    ],
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Description'),
                  const SizedBox(height: 8),
                  const Text(
                    'This is the event description section. You can replace this text '
                    'with the actual event details, schedule, venue information, and '
                    'other relevant content.', // placeholder info
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Organiser'),
                  const SizedBox(height: 8),
                  const Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text('Student Affairs Office'), // placeholder info
                      subtitle: Text('Contact: organiser@unisphere.edu'), // placeholder info
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Actions'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: connect RSVP/join flow
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Join Event'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: connect save/bookmark flow
                        },
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Save'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: connect share flow
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                      ),

                      // Admin/Organiser-only actions
                      if (canEdit)
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: navigate to edit screen or open edit modal
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Event'),
                        ),
                      if (canEdit)
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: archive/delete action with confirmation
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Title',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/900/500', // placeholder image
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanelPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Text(
        'Availability and attendee actions panel will go here.',
        style: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
