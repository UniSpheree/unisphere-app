import 'package:flutter/material.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill in the details below to launch your event.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            _label('Event Name'),
            const TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Annual Tech Symposium 2024',
              ),
            ),

            const SizedBox(height: 16),

            _label('About the Event'),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Provide a brief summary of your event',
              ),
            ),

            const SizedBox(height: 16),

            _label('Venue or Link'),
            const TextField(
              decoration: InputDecoration(hintText: 'Physical address or URL'),
            ),

            const SizedBox(height: 16),

            _label('Max Attendees'),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'e.g. 100'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
