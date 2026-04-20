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
                          const SizedBox(height: 24),
                          // Search bar and filter button
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search events...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                  },
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFF4F46E5),
                                    size: 20,
                                  ),
                                  tooltip: 'Filter events',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
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
