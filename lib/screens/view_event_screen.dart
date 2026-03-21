import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/header.dart';

class ViewEventScreen extends StatelessWidget {
  const ViewEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Title',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/900/500',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // NEW: quick event metadata (high priority for decision-making)
            // When viewed, the page will state information about the viewed event in segmented chips with correct icons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(Icons.calendar_today_outlined, 'May 25, 2026'),
                _infoChip(Icons.access_time_outlined, '2:00 PM - 5:00 PM'),
                _infoChip(Icons.location_on_outlined, 'Main Campus Gym'),
                _infoChip(Icons.group_outlined, '120 slots'),
                _infoChip(Icons.event_busy_outlined, 'Reg. until May 22'),
              ],
            ),

            const SizedBox(height: 20),
            _sectionTitle('Description'),
            const SizedBox(height: 8),
            const Text(
              'This is the event description section. You can replace this text '
              'with the actual event details, schedule, venue information, and '
              'other relevant content.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
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

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}


