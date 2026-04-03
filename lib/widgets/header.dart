import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';
import 'package:unisphere_app/utils/mock_backend.dart';

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
                          case 'profile':
                            if (MockBackend().currentUser != null) {
                              Navigator.pushNamed(context, '/profile');
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
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
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'profile',
                          child: Text('My Profile'),
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
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: onHostEventTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: _HeaderColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Host an Event'),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: MockBackend().currentUser != null
                              ? 'Profile'
                              : 'Register',
                          onPressed: () {
                            if (MockBackend().currentUser != null) {
                              Navigator.pushNamed(context, '/profile');
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
                          },
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
    return Row(
      children: [
        // Use the bundled asset but visually scale the image so it appears larger
        // without increasing the header's layout height: keep the container fixed
        // and scale the image inside it.
        SizedBox(
          width: 48,
          height: 48,
          // Allow the image to render larger than the boxed layout without
          // clipping by using an OverflowBox. We intentionally avoid ClipRRect
          // here so the scaled image isn't cropped by the container bounds.
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: OverflowBox(
                maxWidth: 80,
                maxHeight: 80,
                child: Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                  width: 64,
                  height: 64,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
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
