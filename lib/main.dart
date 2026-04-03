import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/landing_page.dart';
=======
import 'screens/create_event_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
>>>>>>> origin/main

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
<<<<<<< HEAD
      home: const LandingPage(),
=======
      // ── Initial route ────────────────────────────────────────────────────
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/create-event': (_) => const CreateEventScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final role = (settings.arguments as String?) ?? 'Attendee';
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DashboardScreen(role: role),
          );
        }
        return null;
      },
>>>>>>> origin/main
    );
  }
}
