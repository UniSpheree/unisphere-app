import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unisphere_app/models/database_models.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

class CreateEventScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;
  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => CreateEventScreenState();
}

class CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final eventNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  final maxAttendeesController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? eventCategory;
  String eventVisibility = 'Public';
  String? _dateError;
  bool _isSubmitting = false;
  XFile? _bannerImage;
  bool _bannerHovered = false;
  final ImagePicker _imagePicker = ImagePicker();

  @visibleForTesting
  set bannerImage(XFile? file) => setState(() => _bannerImage = file);

  int _formResetVersion = 0;

  static const List<String> _categories = [
    'Academic',
    'Social',
    'Workshop',
    'Seminar',
    'Sports',
    'Cultural',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      final ev = widget.existingEvent!;
      eventNameController.text = ev['title']?.toString() ?? '';
      descriptionController.text = ev['description']?.toString() ?? '';
      venueController.text = ev['location']?.toString() ?? '';
      maxAttendeesController.text = (ev['maxAttendees'] ?? '').toString();
      eventCategory = ev['category']?.toString();
      eventVisibility = ev['visibility']?.toString() ?? 'Public';

      final dateStr = ev['date']?.toString();
      if (dateStr != null) {
        try {
          startDate = DateTime.parse(dateStr);
          endDate = ev['endDate'] != null
              ? DateTime.parse(ev['endDate'].toString())
              : startDate?.add(const Duration(hours: 1));
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    eventNameController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 630,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _bannerImage = pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final initialDate = (isStart ? startDate : endDate) ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      final fullDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (isStart) {
        startDate = fullDateTime;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = startDate!.add(const Duration(hours: 1));
        }
      } else {
        endDate = fullDateTime;
      }

      if (startDate != null && endDate != null) {
        if (endDate!.isBefore(startDate!) || endDate == startDate) {
          _dateError = 'End date & time must be after start date & time.';
        } else {
          _dateError = null;
        }
      }
    });
  }

  Future<void> _submitForm() async {
    setState(() => _dateError = null);

    if (startDate == null || endDate == null) {
      setState(() => _dateError = 'Both start and end date & time are required.');
    } else if (endDate!.isBefore(startDate!) || endDate == startDate) {
      setState(() => _dateError = 'End date & time must be after start date & time.');
    }

    if (!_formKey.currentState!.validate() || _dateError != null) return;

    final isLoggedIn = SqliteBackend().currentUser != null;

    final payload = <String, dynamic>{
      'title': eventNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'location': venueController.text.trim(),
      'category': eventCategory ?? 'Other',
      'visibility': eventVisibility,
      'date': startDate?.toIso8601String() ?? '',
      'endDate': endDate?.toIso8601String() ?? '',
      'maxAttendees': int.tryParse(maxAttendeesController.text.trim()) ?? 0,
      'organizerEmail': SqliteBackend().currentUser?.email,
    };

    if (!isLoggedIn) {
      SqliteBackend().setPendingEvent(payload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.indigo.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your event draft was saved locally since you are not logged in. Register now to finalize it!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamed(context, '/register');
        }
      });

      return;
    }

    setState(() => _isSubmitting = true);

    if (_bannerImage != null) {
      try {
        payload['bannerImageData'] = await _bannerImage!.readAsBytes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not read banner image: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }
    }

    if (widget.existingEvent != null) {
      await SqliteBackend().updateEvent(
        widget.existingEvent!['id'].toString(),
        payload,
      );
    } else {
      await SqliteBackend().createEvent(payload);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.existingEvent != null
                    ? 'Event updated successfully!'
                    : 'Event created successfully!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    _clearForm();
    Navigator.pop(context);
  }

  void _clearForm() {
    FocusScope.of(context).unfocus();
    eventNameController.text = '';
    descriptionController.text = '';
    venueController.text = '';
    maxAttendeesController.text = '';
    setState(() {
      _formResetVersion++;
      startDate = null;
      endDate = null;
      eventCategory = null;
      eventVisibility = 'Public';
      _dateError = null;
      _bannerImage = null;
      _bannerHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    final currentUser =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['user'];
    final user = currentUser ?? SqliteBackend().currentUser;

    if (user != null && !user.isOrganiser) {
      return _buildLockedPage(context);
    }
    final showApprovalBanner =
        user != null &&
        user.role.toLowerCase() == 'organiser' &&
        user.isApproved == false;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      if (!const bool.fromEnvironment('FLUTTER_TEST_RUN', defaultValue: false))
                        AppHeader(
                          showProfile: true,
                          onFindEventsTap: () =>
                              Navigator.pushNamed(context, '/discover'),
                          onCreateEventsTap: () {},
                          onMyTicketsTap: () =>
                              Navigator.pushNamed(context, '/my-tickets'),
                          onAboutTap: () =>
                              Navigator.pushNamed(context, '/about'),
                          onSignInTap: () =>
                              Navigator.pushNamed(context, '/login'),
                          onHostEventTap: () {},
                        ),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showApprovalBanner)
                              Container(
                                width: double.infinity,
                                color: Colors.orange.shade100,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Organizer approval pending',
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 900),
                              padding: EdgeInsets.all(isMobile ? 16 : 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBreadcrumbs(),
                                  const SizedBox(height: 24),
                                  _buildHeader(isMobile),
                                  const SizedBox(height: 32),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildBannerPicker(),
                                        const SizedBox(height: 32),
                                        _buildSectionTitle('Basic Information'),
                                        const SizedBox(height: 16),
                                        _buildBasicInfoFields(isDesktop),
                                        const SizedBox(height: 32),
                                        _buildSectionTitle('Date and Time'),
                                        const SizedBox(height: 16),
                                        _buildDateTimeFields(isDesktop),
                                        const SizedBox(height: 32),
                                        _buildSectionTitle('Additional Details'),
                                        const SizedBox(height: 16),
                                        _buildAdditionalDetailsFields(
                                          isDesktop,
                                        ),
                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton.icon(
                                            key: const Key('submit_event_button'),
                                            onPressed:
                                                _isSubmitting
                                                    ? null
                                                    : _submitForm,
                                            icon:
                                                _isSubmitting
                                                    ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                    : const Icon(
                                                      Icons.rocket_launch,
                                                    ),
                                            label: Text(
                                              _isSubmitting
                                                  ? (widget.existingEvent !=
                                                          null
                                                      ? 'Updating...'
                                                      : 'Creating Event...')
                                                  : (widget.existingEvent !=
                                                          null
                                                      ? 'Update Event'
                                                      : 'Create Event'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.indigo,
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor: Colors
                                                  .indigo
                                                  .withOpacity(0.6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text(
          'Dashboard',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
        const Text(
          'Events',
          style: TextStyle(
            color: Colors.indigo,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.existingEvent != null ? 'Edit Event' : 'Create New Event',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w900,
            color: const Color(0xff1a1c1e),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to host your amazing event.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBannerPicker() {
    return MouseRegion(
      onEnter: (_) => setState(() => _bannerHovered = true),
      onExit: (_) => setState(() => _bannerHovered = false),
      child: GestureDetector(
        onTap: _pickBannerImage,
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _bannerHovered ? Colors.indigo : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child:
              _bannerImage == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Event Banner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1a1c1e),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended: 1200 x 630 px',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  )
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        kIsWeb
                            ? Image.network(_bannerImage!.path, fit: BoxFit.cover)
                            : Image.file(
                              File(_bannerImage!.path),
                              fit: BoxFit.cover,
                            ),
                        Container(color: Colors.black.withOpacity(0.2)),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            onPressed: () => setState(() => _bannerImage = null),
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xff1a1c1e),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildBasicInfoFields(bool isDesktop) {
    return Column(
      children: [
        _buildTextField(
          label: 'Event Name',
          controller: eventNameController,
          hint: 'e.g. Annual Tech Symposium 2024',
          icon: Icons.title_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Event Name is required';
            if (!RegExp(r"^[a-zA-Z0-9 &',.\-()]+$").hasMatch(value)) {
              return 'Event name contains invalid special characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Description',
          controller: descriptionController,
          hint: 'Tell attendees what your event is about...',
          icon: Icons.description_outlined,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Event description is required';
            }
            if (value.length < 10) {
              return 'Description should be at least 10 characters';
            }
            if (!RegExp(r'[a-zA-Z0-9]').hasMatch(value)) {
              return 'Description must contain meaningful text';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeFields(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildDateTimeSelector(true)),
              const SizedBox(width: 20),
              Expanded(child: _buildDateTimeSelector(false)),
            ],
          )
        else ...[
          _buildDateTimeSelector(true),
          const SizedBox(height: 20),
          _buildDateTimeSelector(false),
        ],
        if (_dateError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _dateError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeSelector(bool isStart) {
    final dt = isStart ? startDate : endDate;
    final label = isStart ? 'Start Date & Time' : 'End Date & Time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDateTime(isStart),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.indigo.shade400),
                const SizedBox(width: 12),
                Text(
                  dt != null
                      ? '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                      : 'dd/mm/yyyy --:--',
                  style: TextStyle(
                    color: dt != null ? const Color(0xff1a1c1e) : Colors.grey.shade400,
                    fontWeight: dt != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsFields(bool isDesktop) {
    return Column(
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Venue Location',
                  controller: venueController,
                  hint: 'e.g. Main Auditorium, Block A',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Venue is required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  label: 'Max Attendees',
                  controller: maxAttendeesController,
                  hint: 'e.g. 100',
                  icon: Icons.people_outline,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Maximum attendees is required';
                    final n = int.tryParse(value);
                    if (n == null || n <= 0) return 'Must be a positive number';
                    return null;
                  },
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            label: 'Venue Location',
            controller: venueController,
            hint: 'e.g. Main Auditorium, Block A',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Venue is required';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Max Attendees',
            controller: maxAttendeesController,
            hint: 'e.g. 100',
            icon: Icons.people_outline,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Maximum attendees is required';
              final n = int.tryParse(value);
              if (n == null || n <= 0) return 'Must be a positive number';
              return null;
            },
          ),
        ],
        const SizedBox(height: 20),
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: 20),
              Expanded(child: _buildVisibilityToggle()),
            ],
          )
        else ...[
          _buildCategoryDropdown(),
          const SizedBox(height: 20),
          _buildVisibilityToggle(),
        ],
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: eventCategory,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(Icons.category_outlined, color: Colors.indigo.shade400),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          hint: const Text('Select a category'),
          items: _categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (val) => setState(() => eventCategory = val),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Event category is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _buildVisibilityOption('Public')),
              Expanded(child: _buildVisibilityOption('Internal')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(String value) {
    final isSelected = eventVisibility == value;
    return GestureDetector(
      onTap: () => setState(() => eventVisibility = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.indigo : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.indigo.shade400),
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline, size: 64, color: Colors.red.shade400),
              ),
              const SizedBox(height: 32),
              const Text(
                'Create events is locked',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Only approved organizers can create new events. Please update your profile to request access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Open profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go back', style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
