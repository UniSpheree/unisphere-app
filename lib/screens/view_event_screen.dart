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
            const SizedBox(height: 12),
            const Text(
              'Description\n\n'
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
}


