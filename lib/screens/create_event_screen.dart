import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDateTime = selectedDateTime;
      } else {
        endDateTime = selectedDateTime;
      }
    });
  }

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
            TextField(controller: eventNameController),

            const SizedBox(height: 16),

            _label('About the Event'),
            TextField(controller: descriptionController, maxLines: 4),

            const SizedBox(height: 16),

            _label('Start Date & Time'),
            OutlinedButton(
              onPressed: () => _pickDateTime(true),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  startDateTime == null
                      ? 'Select start date & time'
                      : startDateTime.toString(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _label('End Date & Time'),
            OutlinedButton(
              onPressed: () => _pickDateTime(false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  endDateTime == null
                      ? 'Select end date & time'
                      : endDateTime.toString(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _label('Venue or Link'),
            TextField(controller: venueController),

            const SizedBox(height: 16),

            _label('Max Attendees'),
            TextField(
              controller: maxAttendeesController,
              keyboardType: TextInputType.number,
            ),

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
