import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/screens/about_us_page.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget _buildTestApp({NavigatorObserver? observer}) {
    return MaterialApp(
      navigatorObservers: observer != null ? [observer] : [],
      routes: {
        '/': (_) => const AboutUsPage(),
        '/create-event': (_) => Scaffold(appBar: AppBar(), body: const Text('Create Event Screen')),
        '/discover': (_) => Scaffold(appBar: AppBar(), body: const Text('Discover Screen')),
        '/my-tickets': (_) => Scaffold(appBar: AppBar(), body: const Text('My Tickets Screen')),
        '/login': (_) => Scaffold(appBar: AppBar(), body: const Text('Login Screen')),
        '/register': (_) => Scaffold(appBar: AppBar(), body: const Text('Register Screen')),
      },
      initialRoute: '/',
    );
  }

  Future<void> _pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();
  }

  group('AboutUsPage', () {
    testWidgets('renders all main UI elements', (tester) async {
      await _pumpApp(tester);
      addTearDown(tester.view.reset);

      // Verify Header and Footer are present
      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byType(AppFooter), findsOneWidget);

      // Verify main texts
      expect(find.text('About UniSphere'), findsOneWidget);
      expect(
        find.text(
          'UniSphere is the ultimate platform for university students to discover, manage, and share events with confidence. Built for the modern campus, we aim to bridge the gap between organizers and attendees.',
        ),
        findsOneWidget,
      );
      expect(find.text('Our Mission'), findsOneWidget);
      expect(
        find.text(
          'Our mission is to bring campus life into the digital age. Whether it is an academic symposium, a social gathering, or a career fair, UniSphere provides the tools to ensure every event is a resounding success.',
        ),
        findsOneWidget,
      );
      expect(find.text('Why UniSphere?'), findsOneWidget);
      expect(
        find.text(
          'We realized that finding the right events on campus was often chaotic and fragmented. UniSphere centralizes the experience, offering sleek discovery features for students and powerful management tools for organizers.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('AppHeader navigation callbacks push correct routes', (tester) async {
      await _pumpApp(tester);
      addTearDown(tester.view.reset);

      // The AboutUsPage instantiates AppHeader with several callbacks.
      // We will extract the AppHeader widget and call them directly to ensure
      // 100% coverage of the lambda expressions in about_us_page.dart, 
      // even if AppHeader doesn't expose UI for all of them (e.g. onMyTicketsTap).
      final appHeader = tester.widget<AppHeader>(find.byType(AppHeader));

      // 1. onHostEventTap -> /create-event
      appHeader.onHostEventTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Create Event Screen'), findsOneWidget);

      // Navigate back to About us
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 2. onFindEventsTap -> /discover
      appHeader.onFindEventsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Discover Screen'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 3. onCreateEventsTap -> /create-event
      appHeader.onCreateEventsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Create Event Screen'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 4. onMyTicketsTap -> /my-tickets
      appHeader.onMyTicketsTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('My Tickets Screen'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 5. onSignInTap -> /login
      appHeader.onSignInTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 6. onAboutTap -> () {} (Does nothing, we just ensure it doesn't crash or navigate)
      appHeader.onAboutTap?.call();
      await tester.pumpAndSettle();
      // Should still be on About page
      expect(find.text('About UniSphere'), findsOneWidget);
    });
  });
}
