import 'package:flutter/material.dart';

import '../services/sqlite_backend.dart';
import '../models/database_models.dart';
import '../widgets/app_footer.dart';
import '../widgets/header.dart';
import 'calendar_page.dart';
import 'create_event_screen.dart';
import 'discover_event_screen.dart';
import 'my_events_page.dart';

class ProfilePage extends StatefulWidget {
  final ImageProvider? image;

  const ProfilePage({super.key, this.image});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DbUser? _user;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _user = SqliteBackend().currentUser;
    _nameController = TextEditingController(text: _displayName);
    _descriptionController = TextEditingController(text: _displayDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _displayName {
    final user = _user;
    if (user == null || user.fullName.trim().isEmpty) return 'Guest User';
    return user.fullName;
  }

  String get _displayDescription {
    final description = _user?.description.trim() ?? '';
    return description.isNotEmpty
        ? description
        : 'Add a short bio to introduce yourself to the community.';
  }

  String get _email => _user?.email ?? 'alex@university.edu';
  String get _university => _user?.university ?? 'University of Example';
  String get _role => _user?.role ?? 'Attendee';
  bool get _isOrganiser => _role.toLowerCase() == 'organiser';

  Future<void> _saveProfile() async {
    final updatedUser = await SqliteBackend().updateCurrentUserProfile(
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (!mounted || updatedUser == null) return;
    setState(() {
      _user = updatedUser;
      _nameController.text = updatedUser.fullName;
      _descriptionController.text = updatedUser.description;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated for ${updatedUser.fullName}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _setRole(bool organiser) async {
    final nextRole = organiser ? 'Organiser' : 'Attendee';
    final updatedUser = await SqliteBackend().updateCurrentUserRole(nextRole);
    if (!mounted || updatedUser == null) return;

    setState(() => _user = updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Role changed to ${updatedUser.role}. Permissions updated.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLockedMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is available to organisers only.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openEditDialog() async {
    _nameController.text = _displayName;
    _descriptionController.text = _user?.description ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Edit profile'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Only name and description can be changed here.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReadOnlyField(label: 'Email', value: _email),
                  const SizedBox(height: 12),
                  _ReadOnlyField(label: 'University', value: _university),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _saveProfile();
              },
              child: const Text('Save changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      AppHeader(
                        onHostEventTap: () =>
                            Navigator.pushNamed(context, '/create-event'),
                        onFindEventsTap: () =>
                            Navigator.pushNamed(context, '/discover'),
                        onCreateEventsTap: () =>
                            Navigator.pushNamed(context, '/create-event'),
                        onMyTicketsTap: () =>
                            Navigator.pushNamed(context, '/my-tickets'),
                        onAboutTap: () =>
                            Navigator.pushNamed(context, '/about'),
                        onSignInTap: () =>
                            Navigator.pushNamed(context, '/login'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/logged-in',
                                          ),
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
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/logged-in',
                                          ),
                                      child: const Text(
                                        'Home',
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
                                    const Text(
                                      'Profile',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF111827),
                                        Color(0xFF4F46E5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 28,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final stacked =
                                          constraints.maxWidth < 820;
                                      final avatar = CircleAvatar(
                                        radius: 46,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.14),
                                        backgroundImage: widget.image,
                                        child: widget.image == null
                                            ? const Icon(
                                                Icons.person_rounded,
                                                size: 42,
                                                color: Colors.white,
                                              )
                                            : null,
                                      );

                                      final heroContent = Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                _displayName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              _Pill(
                                                label: _role,
                                                color: Colors.white
                                                    .withOpacity(0.18),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _displayDescription,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.88,
                                              ),
                                              fontSize: 15,
                                              height: 1.55,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              _MetaChip(
                                                icon: Icons.email_outlined,
                                                label: _email,
                                              ),
                                              _MetaChip(
                                                icon: Icons.school_outlined,
                                                label: _university,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              FilledButton.icon(
                                                onPressed: _openEditDialog,
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Edit profile',
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white,
                                                  foregroundColor:
                                                      const Color(0xFF111827),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const DiscoverEventScreen(),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.explore_outlined,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Browse events',
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.white,
                                                  side: BorderSide(
                                                    color: Colors.white
                                                        .withOpacity(0.34),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );

                                      if (stacked) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            avatar,
                                            const SizedBox(height: 18),
                                            heroContent,
                                          ],
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          avatar,
                                          const SizedBox(width: 22),
                                          Expanded(child: heroContent),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 22),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final narrow = constraints.maxWidth < 860;

                                    final accountCard = _SectionCard(
                                      title: 'Account details',
                                      subtitle:
                                          'Email and university stay fixed to the account.',
                                      child: Column(
                                        children: [
                                          _InfoRow(
                                            icon: Icons.email_outlined,
                                            label: 'Email',
                                            value: _email,
                                          ),
                                          const SizedBox(height: 12),
                                          _InfoRow(
                                            icon: Icons.school_outlined,
                                            label: 'University',
                                            value: _university,
                                          ),
                                          const SizedBox(height: 12),
                                          _InfoRow(
                                            icon: Icons.badge_outlined,
                                            label: 'Role',
                                            value: _role,
                                          ),
                                        ],
                                      ),
                                    );

                                    final roleCard = _SectionCard(
                                      title: 'Role & permissions',
                                      subtitle:
                                          'Switch access level and update what this profile can do.',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ChoiceChip(
                                                label: const Text('Attendee'),
                                                selected: !_isOrganiser,
                                                onSelected: (_) =>
                                                    _setRole(false),
                                              ),
                                              const SizedBox(width: 10),
                                              ChoiceChip(
                                                label: const Text('Organiser'),
                                                selected: _isOrganiser,
                                                onSelected: (_) =>
                                                    _setRole(true),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            _isOrganiser
                                                ? 'Organiser mode is active. Event creation, organiser calendar, and event management are available.'
                                                : 'Attendee mode is active. Event creation, organiser calendar, and my events are locked.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    final toolsCard = _SectionCard(
                                      title: 'Useful pages',
                                      subtitle:
                                          'Keep the profile focused on relevant navigation.',
                                      child: Column(
                                        children: [
                                          _ActionTile(
                                            icon: Icons.explore_outlined,
                                            title: 'Discover events',
                                            subtitle:
                                                'Browse the public event feed and find something to join.',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const DiscoverEventScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          _ActionTile(
                                            icon: Icons.add_circle_outline,
                                            title: 'Create event',
                                            subtitle: _isOrganiser
                                                ? 'Open the organiser form to launch a new event.'
                                                : 'Locked for attendees until you switch to organiser.',
                                            enabled: _isOrganiser,
                                            onTap: _isOrganiser
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const CreateEventScreen(),
                                                      ),
                                                    );
                                                  }
                                                : () => _showLockedMessage(
                                                    'Create event',
                                                  ),
                                          ),
                                          const SizedBox(height: 12),
                                          _ActionTile(
                                            icon: Icons.calendar_month_outlined,
                                            title: 'Organiser calendar',
                                            subtitle: _isOrganiser
                                                ? 'View your event calendar and schedule.'
                                                : 'Locked for attendees until organiser mode is enabled.',
                                            enabled: _isOrganiser,
                                            onTap: _isOrganiser
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const CalendarPage(),
                                                      ),
                                                    );
                                                  }
                                                : () => _showLockedMessage(
                                                    'Organiser calendar',
                                                  ),
                                          ),
                                          const SizedBox(height: 12),
                                          _ActionTile(
                                            icon: Icons.event_note_outlined,
                                            title: 'My events',
                                            subtitle: _isOrganiser
                                                ? 'Manage the events you created.'
                                                : 'Locked for attendees until role is changed.',
                                            enabled: _isOrganiser,
                                            onTap: _isOrganiser
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const MyEventsPage(),
                                                      ),
                                                    );
                                                  }
                                                : () => _showLockedMessage(
                                                    'My events',
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );

                                    return narrow
                                        ? Column(
                                            children: [
                                              accountCard,
                                              const SizedBox(height: 18),
                                              roleCard,
                                              const SizedBox(height: 18),
                                              toolsCard,
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: accountCard),
                                              const SizedBox(width: 18),
                                              Expanded(child: roleCard),
                                              const SizedBox(width: 18),
                                              Expanded(child: toolsCard),
                                            ],
                                          );
                                  },
                                ),
                                const SizedBox(height: 22),
                                _SectionCard(
                                  title: 'Session',
                                  subtitle:
                                      'Sign out when you are finished using UniSphere.',
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            SqliteBackend().logout();
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/',
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.logout,
                                            size: 18,
                                          ),
                                          label: const Text('Log out'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFFDC2626,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFFCA5A5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Delete account',
                                                  ),
                                                  content: const Text(
                                                    'Deleting your account will remove your profile, all events you created, and any tickets you own. This action cannot be undone. Are you sure you want to continue?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            dialogContext,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            dialogContext,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                      style:
                                                          FilledButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFFDC2626,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm != true) return;
                                            final ok = await SqliteBackend()
                                                .deleteAccount();
                                            if (ok) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Account deleted.',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/',
                                              );
                                            } else {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Failed to delete account.',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Color(0xFFDC2626),
                                          ),
                                          label: const Text('Delete account'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFFDC2626,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFFCA5A5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled ? const Color(0xFFE5E7EB) : const Color(0xFFF0F0F0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled ? const Color(0xFF4F46E5) : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: enabled
                                ? const Color(0xFF111827)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      if (!enabled)
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
