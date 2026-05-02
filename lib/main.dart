import 'package:flutter/material.dart';
import 'screens/create_event_screen.dart';
import 'screens/profile_page.dart';
import 'screens/landing_page.dart';
import 'screens/landing_page_logged_in.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/discover_event_screen.dart';
import 'screens/about_us_page.dart';
import 'screens/terms_page.dart';
import 'screens/privacy_page.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/my_events_page.dart';
import 'screens/calendar_page.dart';
import 'services/sqlite_backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize backend
  final backend = SqliteBackend();
  await backend.initializeDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final startRoute = SqliteBackend().currentUser != null ? '/logged-in' : '/';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniSphere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3A8C)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F8),
        fontFamily: 'Roboto',
      ),
      // ── Initial route (landing page as the app entry point)
      initialRoute: startRoute,
      routes: {
        '/': (_) => const LandingPage(),
        '/logged-in': (_) {
          final user = SqliteBackend().currentUser;
          return PersonalizedLandingPage(
            userName: user?.fullName ?? 'Guest',
            role: user?.role ?? 'Attendee',
          );
        },
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/profile': (_) => const ProfilePage(),
        '/create-event': (_) => const CreateEventScreen(),
        '/discover': (_) => const DiscoverEventScreen(),
        '/about': (_) => const AboutUsPage(),
        '/terms': (_) => const TermsPage(),
        '/privacy': (_) => const PrivacyPage(),
        '/my-tickets': (_) => const MyTicketsScreen(),
        '/my-events': (_) => const MyEventsPage(),
        '/calendar': (_) => const CalendarPage(),
      },
    );
  }
}
