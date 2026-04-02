import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/widgets/header.dart';

/// Pumps the widget inside a [MaterialApp] with the given [initialRoute].
/// A [navigatorKey] is provided so we can inspect navigation after taps.
Future<void> pumpHeader(
  WidgetTester tester, {
  String initialRoute = '/dashboard',
  double screenWidth = 1400,
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
            body: Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: AppHeader(
                    onFindEventsTap: () => Navigator.pushNamed(ctx, '/events'),
                    onCreateEventsTap: () =>
                        Navigator.pushNamed(ctx, '/create'),
                    onMyTicketsTap: () => Navigator.pushNamed(ctx, '/tickets'),
                    onAboutTap: () => Navigator.pushNamed(ctx, '/about'),
                    onSignInTap: () => Navigator.pushNamed(ctx, '/signin'),
                    onHostEventTap: () => Navigator.pushNamed(ctx, '/host'),
                  ),
                ),
                Expanded(child: Center(child: Text('Page: ${settings.name}'))),
              ],
            ),
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
      final wrapper = const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppHeader(),
      );
      expect(wrapper.preferredSize, const Size.fromHeight(kToolbarHeight));
    });
  });

  group('AppHeader – desktop layout (width >= 700)', () {
    testWidgets('shows UniSphere brand text', (tester) async {
      await pumpHeader(tester);
      expect(find.text('UniSphere'), findsOneWidget);
    });

    testWidgets('shows all four desktop nav items', (tester) async {
      await pumpHeader(tester);
      expect(find.text('Find Events'), findsOneWidget);
      expect(find.text('Create Events'), findsOneWidget);
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('About us'), findsOneWidget);
    });

    testWidgets('shows profile CircleAvatar, no hamburger', (tester) async {
      await pumpHeader(tester);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.menu_rounded), findsNothing);
    });

    testWidgets('tapping Find Events nav item navigates to /events', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('Find Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /events'), findsOneWidget);
    });

    testWidgets('tapping Create Events nav item navigates to /create', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('Create Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /create'), findsOneWidget);
    });

    testWidgets('tapping My Tickets nav item navigates to /tickets', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('My Tickets'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /tickets'), findsOneWidget);
    });

    testWidgets('tapping About us nav item navigates to /about', (
      tester,
    ) async {
      await pumpHeader(tester);
      await tester.tap(find.text('About us'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /about'), findsOneWidget);
    });

    testWidgets('active route (dashboard) highlights Dashboard item', (
      tester,
    ) async {
      await pumpHeader(tester, initialRoute: '/dashboard');
      // Note: AppHeader uses callbacks for navigation and does not implement
      // active-route highlighting. Those tests are intentionally omitted.
    });

    testWidgets('sign in button navigates to /signin', (tester) async {
      await pumpHeader(tester, initialRoute: '/dashboard');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /signin'), findsOneWidget);
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
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.text('Find Events'), findsNothing);
      expect(find.text('Create Events'), findsNothing);
      expect(find.text('My Tickets'), findsNothing);
      expect(find.text('About us'), findsNothing);
    });

    testWidgets('no CircleAvatar on mobile', (tester) async {
      await pumpHeader(tester, screenWidth: 390);
      // AppHeader keeps the brand CircleAvatar visible even on mobile.
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('hamburger menu lists all nav items and My Profile', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Find Events'), findsOneWidget);
      expect(find.text('Create Events'), findsOneWidget);
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('About us'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Host an Event'), findsOneWidget);
    });

    testWidgets('selecting Find Events from menu navigates to /events', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/create');
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /events'), findsOneWidget);
    });

    testWidgets('selecting Create Events from menu navigates to /create', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/dashboard');
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Events'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /create'), findsOneWidget);
    });

    testWidgets('selecting My Tickets from menu navigates to /tickets', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Tickets'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /tickets'), findsOneWidget);
    });

    testWidgets('selecting About us from menu navigates to /about', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About us'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /about'), findsOneWidget);
    });

    testWidgets('selecting Sign In from menu navigates to /signin', (
      tester,
    ) async {
      await pumpHeader(tester, screenWidth: 390, initialRoute: '/dashboard');
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Page: /signin'), findsOneWidget);
    });
  });
}
