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
      (widget.role == 'organiser' &&
          widget.currentUserId == widget.organiserId);

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
                        Expanded(flex: 2, child: _buildRightPanelPlaceholder()),
                      ],
                    ),

                  const SizedBox(height: 16),

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

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/900/500', // placeholder image
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Event Title',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _sectionTitle('Organiser', fontSize: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(child: Icon(Icons.person_outline)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Student Affairs Office'), // placeholder info
                    Text(
                      'Contact: organiser@unisphere.edu',
                    ), // placeholder info
                  ],
                ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoChip(
              Icons.calendar_today_outlined,
              'May 25, 2026',
            ), // placeholder info
            _infoChip(
              Icons.access_time_outlined,
              '2:00 PM - 5:00 PM',
            ), // placeholder info
            _infoChip(
              Icons.location_on_outlined,
              'Main Campus Gym',
            ), // placeholder info
            _infoChip(Icons.group_outlined, '120 slots'), // placeholder info
            _infoChip(
              Icons.event_busy_outlined,
              'Reg. until May 22',
            ), // placeholder info
          ],
        ),
        _sectionTitle('Overview'),
        const SizedBox(height: 8),
        const Text(
          'This is the event description section. You can replace this text '
          'with the actual event details, schedule, venue information, and '
          'other relevant content.', // placeholder info
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16, height: 1.5),
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
