import 'package:flutter/material.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

class AppFooter extends StatelessWidget {
  final String brandName;
  final String tagline;
  final String copyrightText;

  const AppFooter({
    super.key,
    this.brandName = 'UniSphere',
    this.tagline = 'Discover, share, and manage events with confidence.',
    this.copyrightText = '© UniSphere — Event Discovery Platform',
  });

  static const double footerMaxWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xff111827), // Dark, professional background
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: footerMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 80,
                runSpacing: 40,
                children: const [
                  _FooterColumn(
                    title: 'Use UniSphere',
                    links: [
                      {'label': 'About Us', 'route': '/about'},
                      {'label': 'How it Works', 'route': null},
                      {'label': 'Pricing', 'route': null},
                      {'label': 'FAQs', 'route': null},
                    ],
                  ),
                  _FooterColumn(
                    title: 'Plan Events',
                    links: [
                      {'label': 'Create and Set Up', 'route': '/create-event'},
                      {'label': 'Sell Tickets', 'route': null},
                      {'label': 'Online RSVPs', 'route': null},
                      {'label': 'Online Events', 'route': null},
                    ],
                  ),
                  _FooterColumn(
                    title: 'Find Events',
                    links: [
                      {'label': 'Browse Events', 'route': '/discover'},
                      {'label': 'Discover by Category', 'route': '/discover'},
                      {'label': 'Local Events', 'route': '/discover'},
                      {'label': 'Online Events', 'route': '/discover'},
                    ],
                  ),
                  _FooterColumn(
                    title: 'Connect With Us',
                    links: [
                      {'label': 'Contact Support', 'route': null},
                      {'label': 'Twitter', 'route': null},
                      {'label': 'Facebook', 'route': null},
                      {'label': 'LinkedIn', 'route': null},
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copyrightText,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/about');
                                  }
                                });
                              },
                              child: const Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/privacy');
                                  }
                                });
                              },
                              child: const Text(
                                'Privacy',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/terms');
                                  }
                                });
                              },
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        copyrightText,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/about');
                                  }
                                });
                              },
                              child: const Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/privacy');
                                  }
                                });
                              },
                              child: const Text(
                                'Privacy',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () {
                                Future.microtask(() {
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/terms');
                                  }
                                });
                              },
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<Map<String, String?>> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...links.map(
            (linkData) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final route = linkData['route'];
                  if (route != null) {
                    Future.microtask(() {
                      if (context.mounted) {
                        final requiresAuth = [
                          '/create-event',
                          '/profile',
                          '/calendar',
                          '/my-events',
                        ].contains(route);
                        if (requiresAuth &&
                            SqliteBackend().currentUser == null) {
                          Navigator.pushNamed(context, '/register');
                        } else {
                          Navigator.pushNamed(context, route);
                        }
                      }
                    });
                  }
                },
                child: Text(
                  linkData['label'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
