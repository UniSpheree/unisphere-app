import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/widgets/header.dart';

/// Pumps the widget inside a [MaterialApp] with the given [initialRoute].
/// A [navigatorKey] is provided so we can inspect navigation after taps.
Future<void> pumpHeader(
  WidgetTester tester, {
  String initialRoute = '/dashboard',
  double screenWidth = 1024,
  double screenHeight = 800,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => Scaffold(
            appBar: const AppHeader(),
            body: Text('Page: ${settings.name}'),
          ),
        );
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AppHeader – preferredSize', () {
    test('returns kToolbarHeight', () {
      const header = AppHeader();
      expect(header.preferredSize, const Size.fromHeight(kToolbarHeight));
    });
  });

  group('AppHeader – desktop layout (width >= 700)', () {
    testWidgets('shows UniSphere brand text', (tester) async {
      await pumpHeader(tester);
      expect(find.text('UniSphere'), findsOneWidget);
    });

    testWidgets('shows all four desktop nav items', (tester) async {
      await pumpHeader(tester);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows profile CircleAvatar, no hamburger', (tester) async {
      await pumpHeader(tester);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('logo tap navigates to /dashboard', (tester) async {
      await pumpHeader(tester, initialRoute: '/events');
      await tester.tap(find.text('UniSphere'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /dashboard'), findsOneWidget);
    });

    testWidgets('tapping Events nav item navigates to /events', (tester) async {
      await pumpHeader(tester);
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /events'), findsOneWidget);
    });

    testWidgets('tapping My Tickets nav item navigates to /tickets', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('My Tickets'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /tickets'), findsOneWidget);
    });

    testWidgets('tapping Calendar nav item navigates to /calendar', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /calendar'), findsOneWidget);
    });

    testWidgets('active route (dashboard) highlights Dashboard item', (
      tester,
    ) async {
      await pumpHeader(tester, initialRoute: '/dashboard');
      // The active TextButton should have an indigo background tint.
      // We verify via the TextButton styles: find all TextButton.icon widgets.
      // At minimum the widget tree contains indigo-coloured text for Dashboard.
      final dashboardText = tester.widget<Text>(find.text('Dashboard'));
      expect(dashboardText.style?.color, Colors.indigo);
    });

    testWidgets('inactive route does not highlight Dashboard item', (
      tester,
    ) async {
      await pumpHeader(tester, initialRoute: '/events');
      final eventsText = tester.widget<Text>(find.text('Events'));
      expect(eventsText.style?.color, Colors.indigo);

      final dashboardText = tester.widget<Text>(find.text('Dashboard'));
      expect(dashboardText.style?.color, isNot(Colors.indigo));
    });

    testWidgets('profile icon button does not navigate (TODO)', (tester) async {
      await pumpHeader(tester, initialRoute: '/dashboard');
      await tester.tap(find.byTooltip('My Profile'));
      await tester.pumpAndSettle();
      // Still on dashboard – no crash, no navigation
      expect(find.text('Page: /dashboard'), findsOneWidget);
    });
  });

  group('AppHeader – mobile layout (width < 700)', () {
    testWidgets('shows UniSphere brand text', (tester) async {
      await pumpHeader(tester, screenWidth: 390);
      expect(find.text('UniSphere'), findsOneWidget);
    });

    testWidgets('shows hamburger menu icon, no desktop nav items', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Events'), findsNothing);
      expect(find.text('My Tickets'), findsNothing);
      expect(find.text('Calendar'), findsNothing);
    });

    testWidgets('no CircleAvatar on mobile', (tester) async {
      await pumpHeader(tester, screenWidth: 390);
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('hamburger menu lists all nav items and My Profile', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('selecting Dashboard from menu navigates to /dashboard', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/events');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /dashboard'), findsOneWidget);
    });

    testWidgets('selecting Events from menu navigates to /events', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/dashboard');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /events'), findsOneWidget);
    });

    testWidgets('selecting My Tickets from menu navigates to /tickets', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Tickets'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /tickets'), findsOneWidget);
    });

    testWidgets('selecting Calendar from menu navigates to /calendar', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /calendar'), findsOneWidget);
    });

    testWidgets('selecting My Profile from menu does not navigate (TODO)', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/dashboard');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Profile'));
      await tester.pumpAndSettle();
      // Still on dashboard – TODO branch hit, no crash
      expect(find.text('Page: /dashboard'), findsOneWidget);
    });
  });
}
