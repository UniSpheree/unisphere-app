import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                                    'Privacy Policy',
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
                                    '1. Information We Collect',
                                    'We collect personal information that you provide to us, such as your name, email address, and university affiliation when you register. We also collect event attendance data and usage metrics.',
                                  ),
                                  _buildSection(
                                    '2. How We Use Your Information',
                                    'Your information is used to provide and improve the UniSphere platform, manage event registrations, communicate with you about your account, and personalize your experience.',
                                  ),
                                  _buildSection(
                                    '3. Data Sharing',
                                    'We do not sell your personal data. We may share limited information with event organizers (such as your name and email) when you register for their events to facilitate attendance.',
                                  ),
                                  _buildSection(
                                    '4. Security',
                                    'We implement reasonable security measures to protect your data. However, no method of transmission over the Internet is 100% secure, and we cannot guarantee absolute security.',
                                  ),
                                  _buildSection(
                                    '5. Your Rights',
                                    'You have the right to access, correct, or delete your personal data. You can manage most of this information directly from your profile settings.',
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
