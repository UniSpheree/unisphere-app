import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  static const _navItems = [
    {'label': 'Dashboard', 'route': '/dashboard', 'icon': Icons.home_outlined},
    {'label': 'Events', 'route': '/events', 'icon': Icons.event_outlined},
    {
      'label': 'My Tickets',
      'route': '/tickets',
      'icon': Icons.confirmation_number_outlined,
    },
    {
      'label': 'Calendar',
      'route': '/calendar',
      'icon': Icons.calendar_month_outlined,
    },
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Logo / Brand
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/dashboard'),
              child: const Text(
                'UniSphere',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.indigo,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Middle nav (desktop only)
            if (!isMobile) ...[
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _navItems.map((item) {
                  final isActive = currentRoute == item['route'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, item['route'] as String),
                      icon: Icon(
                        item['icon'] as IconData,
                        size: 18,
                        color: isActive ? Colors.indigo : Colors.grey.shade600,
                      ),
                      label: Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? Colors.indigo
                              : Colors.grey.shade700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: isActive
                            ? Colors.indigo.withOpacity(0.08)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
            ] else
              const Spacer(),

            // Profile icon (placeholder)
            if (!isMobile)
              IconButton(
                tooltip: 'My Profile',
                onPressed: () {
                  // TODO: Navigate to profile screen
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
                    // TODO: Navigate to profile screen
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
                        ),
                        SizedBox(width: 10),
                        Text('My Profile'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
