import 'package:flutter/material.dart';
import 'screens/create_event_screen.dart';
import 'screens/view_event_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniSphere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const ViewEventScreen(
        role: 'organizer',
        currentUserId: 'user123',
        organiserId: 'user123',
      ),
      // Temporary ViewEventScreen for debugging purposes
      // Do not match organiserId to see Attendee view
    );
  }
}
