import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';

class DiscoverEventScreen extends StatelessWidget {
  const DiscoverEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppHeader(
          onFindEventsTap: () {
            // Already on discover events page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main content area
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder for event discovery content
                          const Text(
                            'Discover Events',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1F36),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 28),
                          // Event list will go here
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  );
              },
            ),
            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
