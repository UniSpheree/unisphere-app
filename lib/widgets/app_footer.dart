import 'package:flutter/material.dart';

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
                    links: ['How it Works', 'Pricing', 'Content Standards', 'FAQs'],
                  ),
                  _FooterColumn(
                    title: 'Plan Events',
                    links: ['Create and Set Up', 'Sell Tickets', 'Online RSVPs', 'Online Events'],
                  ),
                  _FooterColumn(
                    title: 'Find Events',
                    links: ['Browse Events', 'Discover by Category', 'Local Events', 'Online Events'],
                  ),
                  _FooterColumn(
                    title: 'Connect With Us',
                    links: ['Contact Support', 'Twitter', 'Facebook', 'LinkedIn'],
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
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Text('About', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            SizedBox(width: 16),
                            Text('Privacy', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            SizedBox(width: 16),
                            Text('Terms', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        copyrightText,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      Row(
                        children: const [
                          Text('About', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          SizedBox(width: 24),
                          Text('Privacy', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          SizedBox(width: 24),
                          Text('Terms', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        ],
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
  final List<String> links;

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
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
