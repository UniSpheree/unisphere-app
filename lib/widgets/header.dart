import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onFindEventsTap;
  final VoidCallback? onCreateEventsTap;
  final VoidCallback? onMyTicketsTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onSignInTap;
  final VoidCallback? onHostEventTap;

  const AppHeader({
    super.key,
    this.onFindEventsTap,
    this.onCreateEventsTap,
    this.onMyTicketsTap,
    this.onAboutTap,
    this.onSignInTap,
    this.onHostEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 850;

    return Container(
      width: double.infinity,
      color: Colors.white.withOpacity(0.96),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _HeaderSpacing.maxWidth),
          child: isMobile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Brand(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: _HeaderColors.text,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'find':
                            onFindEventsTap?.call();
                            break;
                          case 'create':
                            if (onCreateEventsTap != null) {
                              onCreateEventsTap!.call();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateEventScreen(),
                                ),
                              );
                            }
                            break;
                          case 'tickets':
                            onMyTicketsTap?.call();
                            break;
                          case 'about':
                            onAboutTap?.call();
                            break;
                          case 'signin':
                            onSignInTap?.call();
                            break;
                          case 'host':
                            onHostEventTap?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'find',
                          child: Text('Find Events'),
                        ),
                        PopupMenuItem(
                          value: 'create',
                          child: Text('Create Events'),
                        ),
                        PopupMenuItem(
                          value: 'tickets',
                          child: Text('My Tickets'),
                        ),
                        PopupMenuItem(value: 'about', child: Text('About us')),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'signin', child: Text('Sign In')),
                        PopupMenuItem(
                          value: 'host',
                          child: Text('Host an Event'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Brand(),
                    Row(
                      children: [
                        _NavItem(
                          label: 'Find Events',
                          onTap: onFindEventsTap ?? () {},
                        ),
                        _NavItem(
                          label: 'Create Events',
                          onTap: onCreateEventsTap ?? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateEventScreen(),
                              ),
                            );
                          },
                        ),
                        _NavItem(
                          label: 'My Tickets',
                          onTap: onMyTicketsTap ?? () {},
                        ),
                        _NavItem(label: 'About us', onTap: onAboutTap ?? () {}),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: onSignInTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _HeaderColors.primary,
                            side: const BorderSide(color: _HeaderColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(width: 12),
                        // Profile icon
                        IconButton(
                          tooltip: 'My Profile',
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                          icon: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.indigo.withOpacity(0.12),
                            child: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeaderColors {
  static const primary = Color(0xff4f46e5);
  static const text = Color(0xff111827);
  static const border = Color(0xffe5e7eb);
}

class _HeaderSpacing {
  static const double maxWidth = 1200;
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _HeaderColors.primary,
          child: Icon(Icons.public, color: Colors.white, size: 18),
        ),
        SizedBox(width: 12),
        Text(
          'UniSphere',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _HeaderColors.text,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: _HeaderColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onFindEventsTap;
  final VoidCallback? onCreateEventsTap;
  final VoidCallback? onMyTicketsTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onSignInTap;
  final VoidCallback? onHostEventTap;

  const AppHeader({
    super.key,
    this.onFindEventsTap,
    this.onCreateEventsTap,
    this.onMyTicketsTap,
    this.onAboutTap,
    this.onSignInTap,
    this.onHostEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 850;

    return Container(
      width: double.infinity,
      color: Colors.white.withOpacity(0.96),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _HeaderSpacing.maxWidth),
          child: isMobile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Brand(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: _HeaderColors.text,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'find':
                            onFindEventsTap?.call();
                            break;
                          case 'create':
                            if (onCreateEventsTap != null) {
                              onCreateEventsTap!.call();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventScreen(),
                                ),
                              );
                            }
                            break;
                          case 'tickets':
                            onMyTicketsTap?.call();
                            break;
                          case 'about':
                            onAboutTap?.call();
                            break;
                          case 'signin':
                            onSignInTap?.call();
                            break;
                          case 'host':
                            onHostEventTap?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'find',
                          child: Text('Find Events'),
                        ),
                        PopupMenuItem(
                          value: 'create',
                          child: Text('Create Events'),
                        ),
<<<<<<< HEAD
                        PopupMenuItem(
                          value: 'tickets',
                          child: Text('My Tickets'),
                        ),
                        PopupMenuItem(value: 'about', child: Text('About us')),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'signin', child: Text('Sign In')),
                        PopupMenuItem(
                          value: 'host',
                          child: Text('Host an Event'),
=======
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
            ] else
              const Spacer(),

            // Profile icon (desktop)
            if (!isMobile)
              IconButton(
                tooltip: 'My Profile',
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.indigo.withOpacity(0.12),
                  child: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.indigo,
                  ),
                ),
              )
            else
              // Mobile: hamburger menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (route) {
                  if (route == '/profile') {
                    Navigator.pushNamed(context, '/profile');
                    return;
                  }
                  Navigator.pushNamed(context, route);
                },
                itemBuilder: (context) => [
                  ..._navItems.map(
                    (item) => PopupMenuItem<String>(
                      value: item['route'] as String,
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 10),
                          Text(item['label'] as String),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: '/profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.indigo,
>>>>>>> origin/main
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Brand(),
                    Row(
                      children: [
                        _NavItem(
                          label: 'Find Events',
                          onTap: onFindEventsTap ?? () {},
                        ),
                        _NavItem(
                          label: 'Create Events',
                          onTap:
                              onCreateEventsTap ??
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateEventScreen(),
                                  ),
                                );
                              },
                        ),
                        _NavItem(
                          label: 'My Tickets',
                          onTap: onMyTicketsTap ?? () {},
                        ),
                        _NavItem(label: 'About us', onTap: onAboutTap ?? () {}),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: onSignInTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _HeaderColors.primary,
                            side: const BorderSide(color: _HeaderColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeaderColors {
  static const primary = Color(0xff4f46e5);
  static const text = Color(0xff111827);
  static const border = Color(0xffe5e7eb);
}

class _HeaderSpacing {
  static const double maxWidth = 1200;
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _HeaderColors.primary,
          child: Icon(Icons.public, color: Colors.white, size: 18),
        ),
        SizedBox(width: 12),
        Text(
          'UniSphere',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _HeaderColors.text,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: _HeaderColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
