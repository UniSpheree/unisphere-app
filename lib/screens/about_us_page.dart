import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/app_footer.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'About UniSphere',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'UniSphere is the ultimate platform for university students to discover, manage, and share events with confidence. Built for the modern campus, we aim to bridge the gap between organizers and attendees.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.6,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 60),
                                Container(
                                  padding: const EdgeInsets.all(32),
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
                                        'Our Mission',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Our mission is to bring campus life into the digital age. Whether it is an academic symposium, a social gathering, or a career fair, UniSphere provides the tools to ensure every event is a resounding success.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.6,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      const Text(
                                        'Why UniSphere?',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'We realized that finding the right events on campus was often chaotic and fragmented. UniSphere centralizes the experience, offering sleek discovery features for students and powerful management tools for organizers.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.6,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
}
