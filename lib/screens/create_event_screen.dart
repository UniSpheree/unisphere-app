// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/header.dart';

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
  String? eventCategory;
  String eventVisibility = 'Public';
  bool _bannerHovered = false;
  String? _dateError;
  bool _isSubmitting = false;

  final List<String> eventCategories = [
    'Academic',
    'Social',
    'Sports',
    'Career',
    'Workshop',
    'Other',
  ];

  final List<Map<String, dynamic>> visibilityOptions = [
    {'value': 'Public', 'icon': Icons.public, 'desc': 'Any student'},
    {'value': 'Private', 'icon': Icons.lock_outline, 'desc': 'Invite only'},
    {
      'value': 'Restricted',
      'icon': Icons.group_outlined,
      'desc': 'Society / course',
    },
  ];

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
        // clear error and re-validate if end date already set
        if (endDate != null && selected.isAfter(endDate!)) {
          endDate = null;
          _dateError =
              'End date was cleared because it was before the new start date.';
        } else {
          _dateError = null;
        }
      } else {
        if (startDate != null && !selected.isAfter(startDate!)) {
          _dateError = 'End date & time must be after start date & time.';
        } else {
          endDate = selected;
          _dateError = null;
        }
      }
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      if (startDate == null || endDate == null) {
        _dateError = 'Both start and end date & time are required.';
      } else if (!endDate!.isAfter(startDate!)) {
        _dateError = 'End date & time must be after start date & time.';
      } else {
        _dateError = null;
      }
    });

    if (!_formKey.currentState!.validate() || _dateError != null) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Event created successfully!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    eventNameController.clear();
    descriptionController.clear();
    venueController.clear();
    maxAttendeesController.clear();
    _formKey.currentState!.reset();
    setState(() {
      startDate = null;
      endDate = null;
      eventCategory = null;
      eventVisibility = 'Public';
      _dateError = null;
    });

    Navigator.pushNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? double.infinity : 720,
                    margin: EdgeInsets.fromLTRB(
                      isMobile ? 12 : 16,
                      isMobile ? 20 : 32,
                      isMobile ? 12 : 16,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/dashboard'),
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/dashboard'),
                              child: const Text(
                                'Dashboard',
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
                            const Flexible(
                              child: Text(
                                'Create New Event',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                  Container(
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
                          _label('Event Banner'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _bannerHovered = true),
                              onExit: (_) =>
                                  setState(() => _bannerHovered = false),
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: _bannerHovered
                                        ? Colors.indigo.withOpacity(0.06)
                                        : Colors.indigo.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _bannerHovered
                                          ? Colors.indigo
                                          : Colors.indigo.withOpacity(0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: _bannerHovered
                                              ? Colors.indigo.withOpacity(0.12)
                                              : Colors.indigo.withOpacity(0.07),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 36,
                                          color: _bannerHovered
                                              ? Colors.indigo
                                              : Colors.indigo.withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Upload Event Banner',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _bannerHovered
                                              ? Colors.indigo
                                              : Colors.indigo.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Recommended size: 1200 × 630px (PNG, JPG)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          _label('Event Name'),
                          _textField(
                            controller: eventNameController,
                            hint: 'e.g. Annual Tech Symposium 2024',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Event Name is required';
                              }
                              final trimmed = value.trim();
                              final validName = RegExp(
                                r"^[a-zA-Z0-9 &',.\-()]+$",
                              );
                              if (!validName.hasMatch(trimmed)) {
                                return 'Event name contains invalid special characters';
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
                              if (value == null || value.trim().isEmpty) {
                                return 'Event description is required';
                              }
                              final trimmed = value.trim();
                              final hasAlphanumeric = RegExp(r'[a-zA-Z0-9]');
                              if (!hasAlphanumeric.hasMatch(trimmed)) {
                                return 'Description must contain meaningful text';
                              }
                              return null;
                            },
                          ),

                          _label('Event Type / Category'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              initialValue: eventCategory,
                              hint: const Text('Select a category'),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF7F9FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: eventCategories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => eventCategory = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Event category is required';
                                }
                                return null;
                              },
                            ),
                          ),

                          _label('Visibility / Privacy'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: visibilityOptions.map((option) {
                                final isSelected =
                                    eventVisibility == option['value'];
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => eventVisibility = option['value'],
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: EdgeInsets.only(
                                        right: option['value'] != 'Restricted'
                                            ? 8
                                            : 0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        // ignore: duplicate_ignore
                                        // ignore: deprecated_member_use
                                        color: isSelected
                                            ? Colors.indigo.withOpacity(0.08)
                                            : const Color(0xFFF7F9FC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.indigo
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            option['icon'] as IconData,
                                            color: isSelected
                                                ? Colors.indigo
                                                : Colors.grey,
                                            size: 22,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            option['value'] as String,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.indigo
                                                  : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            option['desc'] as String,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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

                          if (_dateError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _dateError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                        if (value == null ||
                                            value.trim().isEmpty) {
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
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Max Attendees is required';
                                        }
                                        if (int.tryParse(value.trim()) ==
                                            null) {
                                          return 'Max Attendees must be a number';
                                        }
                                        if (int.parse(value.trim()) < 1) {
                                          return 'Max Attendees must be at least 1';
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
                                          if (value == null ||
                                              value.trim().isEmpty) {
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
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Max Attendees is required';
                                          }
                                          if (int.tryParse(value.trim()) ==
                                              null) {
                                            return 'Max Attendees must be a number';
                                          }
                                          if (int.parse(value.trim()) < 1) {
                                            return 'Max Attendees must be at least 1';
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
                              onPressed: _isSubmitting ? null : _submitForm,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.rocket_launch),
                              label: Text(
                                _isSubmitting
                                    ? 'Creating Event...'
                                    : 'Create Event',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.indigo
                                    .withOpacity(0.6),
                                disabledForegroundColor: Colors.white,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
