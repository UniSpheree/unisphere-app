import 'package:flutter/material.dart';
import 'screens/create_event_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3A8C)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F8),
        fontFamily: 'Roboto',
      ),
      // ── Initial route ────────────────────────────────────────────────────
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/create-event': (_) => const CreateEventScreen(),
      },
    );
  }
}
