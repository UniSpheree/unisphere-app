import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

final TextEditingController eventNameController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController venueController = TextEditingController();
final TextEditingController maxAttendeesController = TextEditingController();

class _CreateEventScreenState extends State<CreateEventScreen> {
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
            const TextField(),

            const SizedBox(height: 16),

            _label('About the Event'),
            const TextField(maxLines: 4),

            const SizedBox(height: 16),

            _label('Start Date & Time'),
            OutlinedButton(
              onPressed: null,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select start date & time'),
              ),
            ),

            const SizedBox(height: 16),

            _label('End Date & Time'),
            OutlinedButton(
              onPressed: null,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select end date & time'),
              ),
            ),

            const SizedBox(height: 16),

            _label('Venue or Link'),
            const TextField(),

            const SizedBox(height: 16),

            _label('Max Attendees'),
            const TextField(keyboardType: TextInputType.number),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Create Event'),
              ),
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
