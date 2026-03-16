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
      color: const Color(0xff0f172a),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: footerMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brandName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tagline,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          copyrightText,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              brandName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tagline,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        Text(
                          copyrightText,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
