import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDate = selected;
      } else {
        endDate = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'UniSphere',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isMobile ? double.infinity : 720,
                margin: EdgeInsets.all(isMobile ? 12 : 16),
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Event',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in the details below to launch your event and start inviting attendees.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      _label('Event Name'),
                      _textField(
                        controller: eventNameController,
                        hint: 'e.g. Annual Tech Symposium 2024',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Event Name is required';
                          }
                          return null;
                        },
                      ),

                      _label('About the Event'),
                      _textField(
                        controller: descriptionController,
                        hint:
                            'Provide a brief summary of what makes your event special...',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Event description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      isMobile
                          ? Column(
                              children: [
                                _datePicker(
                                  label: 'Start Date & Time',
                                  value: startDate,
                                  onTap: () => pickDateTime(true),
                                ),
                                const SizedBox(height: 16),
                                _datePicker(
                                  label: 'End Date & Time',
                                  value: endDate,
                                  onTap: () => pickDateTime(false),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _datePicker(
                                    label: 'Start Date & Time',
                                    value: startDate,
                                    onTap: () => pickDateTime(true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _datePicker(
                                    label: 'End Date & Time',
                                    value: endDate,
                                    onTap: () => pickDateTime(false),
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 16),

                      isMobile
                          ? Column(
                              children: [
                                _textField(
                                  controller: venueController,
                                  label: 'Venue or Link',
                                  hint: 'Physical address or URL',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Venue or Link is required';
                                    }
                                    return null;
                                  },
                                ),
                                _textField(
                                  controller: maxAttendeesController,
                                  label: 'Max Attendees',
                                  hint: 'e.g. 100',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Max Attendees is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _textField(
                                    controller: venueController,
                                    label: 'Venue or Link',
                                    hint: 'Physical address or URL',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Venue or Link is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _textField(
                                    controller: maxAttendeesController,
                                    label: 'Max Attendees',
                                    hint: 'e.g. 100',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Max Attendees is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Proceed with event creation
                            }
                          },
                          icon: const Icon(Icons.rocket_launch),
                          label: const Text(
                            'Create Event',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'By clicking "Create Event", you agree to our organizer terms of service.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value == null
                  ? 'dd/mm/yyyy --:--'
                  : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
