import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const AppHeader(),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Terms of Service',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last updated: May 2026',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSection(
                                    '1. Acceptance of Terms',
                                    'By accessing and using UniSphere, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our platform.',
                                  ),
                                  _buildSection(
                                    '2. User Responsibilities',
                                    'You are responsible for maintaining the confidentiality of your account credentials. Any activities that occur under your account are your sole responsibility.',
                                  ),
                                  _buildSection(
                                    '3. Event Content',
                                    'Event organizers are solely responsible for the content and details of the events they post. UniSphere reserves the right to remove any events that violate our community standards.',
                                  ),
                                  _buildSection(
                                    '4. Prohibited Conduct',
                                    'Users may not use UniSphere for any unlawful purposes, including but not limited to the distribution of malicious software, harassment, or unauthorized data collection.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
