import 'package:flutter/material.dart';

import '../utils/mock_backend.dart';
import '../widgets/app_footer.dart';
import '../widgets/header.dart';
import 'calendar_page.dart';
import 'chat_page.dart';
import 'create_event_screen.dart';
import 'discover_event_screen.dart';
import 'friends_list_page.dart';
import 'my_events_page.dart';

class ProfilePage extends StatefulWidget {
  final ImageProvider? image;

  const ProfilePage({super.key, this.image});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  MockUser? _user;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final List<_MessagePreview> _messages = const [
    _MessagePreview(
      name: 'Jane Smith',
      status: 'Online',
      preview: 'Are you still going to the networking event later?',
      time: '2m ago',
      accent: Color(0xFF4F46E5),
    ),
    _MessagePreview(
      name: 'Emily Doe',
      status: 'Away',
      preview: 'I shared the slides from the last workshop.',
      time: '18m ago',
      accent: Color(0xFF0F766E),
    ),
    _MessagePreview(
      name: 'John App',
      status: 'Offline',
      preview: 'Let me know if you want to join the event team.',
      time: '1h ago',
      accent: Color(0xFFEA580C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _user = MockBackend().currentUser;
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
    if (user == null) return 'Guest User';
    return user.fullName.isNotEmpty ? user.fullName : 'Guest User';
  }

  String get _displayDescription {
    final description = _user?.description.trim() ?? '';
    if (description.isNotEmpty) return description;
    return 'Add a short bio to introduce yourself to the community.';
  }

  String get _displayEmail => _user?.email ?? 'alex@university.edu';

  String get _displayUniversity => _user?.university ?? 'University of Example';

  String get _displayRole => _user?.role ?? 'Attendee';

  bool get _isOrganiser => _displayRole.toLowerCase() == 'organiser';

  Future<void> _openEditDialog() async {
    _nameController.text = _displayName;
    _descriptionController.text = _user?.description.isNotEmpty == true
        ? _user!.description
        : '';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<MockUser>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Edit profile',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Only your name and description can be updated here. Email and university stay locked to your account.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name is too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 72),
                          child: Icon(Icons.notes_outlined),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().length > 220) {
                          return 'Keep it under 220 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final updatedUser = await MockBackend()
                                .updateCurrentUserProfile(
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                );

                            if (!mounted) return;

                            if (updatedUser == null) {
                              Navigator.pop(context);
                              return;
                            }

                            setState(() {
                              _user = updatedUser;
                              _nameController.text = updatedUser.fullName;
                              _descriptionController.text =
                                  updatedUser.description;
                            });

                            Navigator.pop(context, updatedUser);
                          },
                          child: const Text('Save changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated for ${result.fullName}.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _openChat(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(friendName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _isOrganiser
        ? 'Manage your events, connections and updates from one polished profile hub.'
        : 'Keep your profile current and stay connected with your campus community.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(88),
        child: AppHeader(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 960;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Breadcrumb(
                      onHomeTap: () {
                        Navigator.pushReplacementNamed(context, '/logged-in');
                      },
                    ),
                    const SizedBox(height: 16),
                    _HeroProfileCard(
                      name: _displayName,
                      description: _displayDescription,
                      email: _displayEmail,
                      university: _displayUniversity,
                      role: _displayRole,
                      image: widget.image,
                      onEditProfile: _openEditDialog,
                      onExploreEvents: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiscoverEventScreen(),
                          ),
                        );
                      },
                      onViewCalendar: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (isCompact)
                      Column(
                        children: [
                          _ProfileInfoPanel(
                            email: _displayEmail,
                            university: _displayUniversity,
                            role: _displayRole,
                            isOrganiser: _isOrganiser,
                            onOpenCreateEvent: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventScreen(),
                                ),
                              );
                            },
                            onOpenMyEvents: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyEventsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _MessagesPanel(
                            messages: _messages,
                            onOpenAllFriends: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendsListPage(),
                                ),
                              );
                            },
                            onOpenChat: _openChat,
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _ProfileInfoPanel(
                              email: _displayEmail,
                              university: _displayUniversity,
                              role: _displayRole,
                              isOrganiser: _isOrganiser,
                              onOpenCreateEvent: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateEventScreen(),
                                  ),
                                );
                              },
                              onOpenMyEvents: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyEventsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 7,
                            child: _MessagesPanel(
                              messages: _messages,
                              onOpenAllFriends: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FriendsListPage(),
                                  ),
                                );
                              },
                              onOpenChat: _openChat,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 22),
                    _ConnectionsPanel(
                      onDashboardTap: () {
                        Navigator.pushReplacementNamed(context, '/logged-in');
                      },
                      onCreateEventTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventScreen(),
                          ),
                        );
                      },
                      onCalendarTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarPage(),
                          ),
                        );
                      },
                      onFriendsTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FriendsListPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final VoidCallback onHomeTap;

  const _Breadcrumb({required this.onHomeTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onHomeTap,
          borderRadius: BorderRadius.circular(8),
          child: const Icon(Icons.arrow_back, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onHomeTap,
          child: const Text(
            'Home',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const Text('  /  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeroProfileCard extends StatelessWidget {
  final String name;
  final String description;
  final String email;
  final String university;
  final String role;
  final ImageProvider? image;
  final VoidCallback onEditProfile;
  final VoidCallback onExploreEvents;
  final VoidCallback onViewCalendar;

  const _HeroProfileCard({
    required this.name,
    required this.description,
    required this.email,
    required this.university,
    required this.role,
    required this.image,
    required this.onEditProfile,
    required this.onExploreEvents,
    required this.onViewCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4338CA), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 820;

          final avatar = CircleAvatar(
            radius: 46,
            backgroundColor: Colors.white.withOpacity(0.14),
            backgroundImage: image,
            child: image == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: Colors.white,
                  )
                : null,
          );

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    _Pill(label: role, color: Colors.white.withOpacity(0.18)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaChip(icon: Icons.email_outlined, label: email),
                    _MetaChip(icon: Icons.school_outlined, label: university),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onEditProfile,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit profile'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111827),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onExploreEvents,
                      icon: const Icon(Icons.explore_outlined, size: 18),
                      label: const Text('Explore events'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.34)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onViewCalendar,
                      icon: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: const Text('Calendar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [avatar, const SizedBox(height: 18), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [avatar, const SizedBox(width: 22), details],
          );
        },
      ),
    );
  }
}

class _ProfileInfoPanel extends StatelessWidget {
  final String email;
  final String university;
  final String role;
  final bool isOrganiser;
  final VoidCallback onOpenCreateEvent;
  final VoidCallback onOpenMyEvents;

  const _ProfileInfoPanel({
    required this.email,
    required this.university,
    required this.role,
    required this.isOrganiser,
    required this.onOpenCreateEvent,
    required this.onOpenMyEvents,
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Email and university are locked for account integrity.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          _InfoTile(icon: Icons.email_outlined, label: 'Email', value: email),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.school_outlined,
            label: 'University',
            value: university,
          ),
          const SizedBox(height: 12),
          _InfoTile(icon: Icons.badge_outlined, label: 'Role', value: role),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Active and synced',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenCreateEvent,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Create event'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (isOrganiser) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenMyEvents,
                icon: const Icon(Icons.event_note_outlined, size: 18),
                label: const Text('My events'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessagesPanel extends StatelessWidget {
  final List<_MessagePreview> messages;
  final VoidCallback onOpenAllFriends;
  final void Function(String name) onOpenChat;

  const _MessagesPanel({
    required this.messages,
    required this.onOpenAllFriends,
    required this.onOpenChat,
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Recent conversations with your connections',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              TextButton(
                onPressed: onOpenAllFriends,
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MessageTile(message: message, onOpenChat: onOpenChat),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsPanel extends StatelessWidget {
  final VoidCallback onDashboardTap;
  final VoidCallback onCreateEventTap;
  final VoidCallback onCalendarTap;
  final VoidCallback onFriendsTap;

  const _ConnectionsPanel({
    required this.onDashboardTap,
    required this.onCreateEventTap,
    required this.onCalendarTap,
    required this.onFriendsTap,
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick connections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Move around the app from one place without losing context.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionChip(
                label: 'Dashboard',
                icon: Icons.home_outlined,
                onTap: onDashboardTap,
              ),
              _ActionChip(
                label: 'Create event',
                icon: Icons.add_circle_outline,
                onTap: onCreateEventTap,
              ),
              _ActionChip(
                label: 'Calendar',
                icon: Icons.calendar_month_outlined,
                onTap: onCalendarTap,
              ),
              _ActionChip(
                label: 'Friends',
                icon: Icons.people_outline,
                onTap: onFriendsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final _MessagePreview message;
  final void Function(String name) onOpenChat;

  const _MessageTile({required this.message, required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpenChat(message.name),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: message.accent.withOpacity(0.16),
              child: Text(
                message.name.characters.first,
                style: TextStyle(
                  color: message.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Pill(
                        label: message.status,
                        color: message.accent.withOpacity(0.12),
                        textColor: message.accent,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => onOpenChat(message.name),
                        child: const Text('Open chat'),
                      ),
                    ],
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
      label: Text(label),
      labelStyle: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Pill({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

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
        style: TextStyle(
          color: textColor,
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

class _MessagePreview {
  final String name;
  final String status;
  final String preview;
  final String time;
  final Color accent;

  const _MessagePreview({
    required this.name,
    required this.status,
    required this.preview,
    required this.time,
    required this.accent,
  });
}
