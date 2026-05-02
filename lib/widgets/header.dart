import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/create_event_screen.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onFindEventsTap;
  final VoidCallback? onCreateEventsTap;
  final VoidCallback? onMyTicketsTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onSignInTap;
  final VoidCallback? onHostEventTap;
  final VoidCallback? onRegisterTap;
  final bool showProfile;
  final bool showBackButton;

  const AppHeader({
    super.key,
    this.onFindEventsTap,
    this.onCreateEventsTap,
    this.onMyTicketsTap,
    this.onAboutTap,
    this.onSignInTap,
    this.onHostEventTap,
    this.onRegisterTap,
    this.showProfile = true,
    this.showBackButton = false,
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: _HeaderSpacing.maxWidth),
          child: isMobile
              ? Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                            if (onFindEventsTap != null) {
                              onFindEventsTap!.call();
                            } else {
                              Future.microtask(() {
                                if (context.mounted)
                                  Navigator.pushNamed(context, '/discover');
                              });
                            }
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
                          case 'dashboard':
                            final user = SqliteBackend().currentUser;
                            if (user != null) {
                              Navigator.pushNamed(context, '/logged-in');
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
                            break;
                          case 'about':
                            if (onAboutTap != null) {
                              onAboutTap!.call();
                            } else {
                              Future.microtask(() {
                                if (context.mounted)
                                  Navigator.pushNamed(context, '/about');
                              });
                            }
                            break;
                          case 'signin':
                            onSignInTap?.call();
                            break;
                          case 'host':
                            if (onRegisterTap != null) {
                              onRegisterTap!.call();
                            } else if (onHostEventTap != null) {
                              onHostEventTap!.call();
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
                            break;
                          case 'profile':
                            if (SqliteBackend().currentUser != null) {
                              Navigator.pushNamed(context, '/profile');
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final isLoggedIn = SqliteBackend().currentUser != null;
                        final items = <PopupMenuEntry<String>>[
                          const PopupMenuItem(
                            value: 'find',
                            child: Text('Find Events'),
                          ),
                          const PopupMenuItem(
                            value: 'create',
                            child: Text('Create Events'),
                          ),
                          const PopupMenuItem(
                            value: 'dashboard',
                            child: Text('Dashboard'),
                          ),
                          const PopupMenuItem(
                            value: 'about',
                            child: Text('About us'),
                          ),
                          const PopupMenuDivider(),
                          if (!isLoggedIn) ...[
                            const PopupMenuItem(
                              value: 'signin',
                              child: Text('Sign In'),
                            ),
                            const PopupMenuItem(
                              value: 'host',
                              child: Text('Register'),
                            ),
                          ],
                        ];

                        if (showProfile) {
                          items.add(const PopupMenuDivider());
                          items.add(
                            const PopupMenuItem(
                              value: 'profile',
                              child: Text('My Profile'),
                            ),
                          );
                        }

                        return items;
                      },
                    ),
                  ],
                )
              : Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (showBackButton) ...[
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: _HeaderColors.text,
                            ),
                            tooltip: 'Back',
                          ),
                        ],
                        const _Brand(),
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _NavItem(
                          label: 'Find Events',
                          onTap:
                              onFindEventsTap ??
                              () {
                                Navigator.pushNamed(context, '/discover');
                              },
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
                          label: 'Dashboard',
                          onTap: () {
                            final user = SqliteBackend().currentUser;
                            if (user != null) {
                              Navigator.pushNamed(context, '/logged-in');
                            } else {
                              Navigator.pushNamed(context, '/register');
                            }
                          },
                        ),
                        _NavItem(
                          label: 'About us',
                          onTap:
                              onAboutTap ??
                              () {
                                Navigator.pushNamed(context, '/about');
                              },
                        ),
                        const SizedBox(width: 12),
                        if (SqliteBackend().currentUser == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: OutlinedButton(
                              onPressed: onSignInTap,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _HeaderColors.primary,
                                side: const BorderSide(
                                  color: _HeaderColors.border,
                                ),
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
                          ),
                        const SizedBox(width: 12),
                        if (SqliteBackend().currentUser == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: FilledButton(
                              onPressed:
                                  onRegisterTap ??
                                  onHostEventTap ??
                                  () {
                                    Navigator.pushNamed(context, '/register');
                                  },
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
                              child: const Text('Register'),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (showProfile)
                          IconButton(
                            tooltip: SqliteBackend().currentUser != null
                                ? 'Profile'
                                : 'Register',
                            onPressed: () {
                              if (SqliteBackend().currentUser != null) {
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
    return GestureDetector(
      onTap: () {
        // Always navigate to the initial welcome page
        Future.microtask(() {
          if (context.mounted)
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        });
      },
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
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
      ),
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
