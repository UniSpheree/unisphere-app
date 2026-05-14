import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/privacy_page.dart';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';

Future<void> pumpPrivacyPage(
  WidgetTester tester, {
  double screenWidth = 1400,
  double screenHeight = 1200,
  Map<String, WidgetBuilder>? routes,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // If the caller provided a '/' route, we cannot pass `home:` (the
  // framework asserts against having both). Instead, register a synthetic
  // initial route that builds the PrivacyPage and set that as the
  // initialRoute so navigation to '/' still works in tests.
  if (routes != null && routes.containsKey('/')) {
    final Map<String, WidgetBuilder> augmented = Map.from(routes);
    const testRoute = '/__test_privacy';
    augmented[testRoute] = (_) => const PrivacyPage();
    await tester.pumpWidget(
      MaterialApp(routes: augmented, initialRoute: testRoute),
    );
  } else {
    await tester.pumpWidget(
      MaterialApp(routes: routes ?? {}, home: const PrivacyPage()),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders privacy policy title, sections, header and footer', (
    tester,
  ) async {
    await pumpPrivacyPage(tester);

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Last updated: May 2026'), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsOneWidget);
    expect(find.text('2. How We Use Your Information'), findsOneWidget);
    expect(find.text('3. Data Sharing'), findsOneWidget);
    expect(find.text('4. Security'), findsOneWidget);
    expect(find.text('5. Your Rights'), findsOneWidget);
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
  });

  testWidgets('shows policy body text for collection and security', (
    tester,
  ) async {
    await pumpPrivacyPage(tester, screenWidth: 390, screenHeight: 1000);

    expect(
      find.textContaining('We collect personal information that you provide'),
      findsOneWidget,
    );
    expect(
      find.textContaining('We implement reasonable security measures'),
      findsOneWidget,
    );
  });

  testWidgets('footer links navigate to their routes', (tester) async {
    // Provide simple placeholders for the routes the footer links push.
    final routes = <String, WidgetBuilder>{
      '/about': (_) => const Scaffold(body: Center(child: Text('about page'))),
      '/privacy': (_) =>
          const Scaffold(body: Center(child: Text('privacy page'))),
      '/terms': (_) => const Scaffold(body: Center(child: Text('terms page'))),
    };

    await pumpPrivacyPage(tester, routes: routes);

    // Ensure the footer is visible and scope finds to the footer to avoid
    // ambiguity with other 'About' / 'Privacy' text elsewhere.
    final footerFinder = find.byType(AppFooter);
    await tester.ensureVisible(footerFinder);
    await tester.pumpAndSettle();

    final aboutFinder = find.descendant(
      of: footerFinder,
      matching: find.text('About'),
    );
    expect(aboutFinder, findsOneWidget);
    await tester.tap(aboutFinder);
    await tester.pumpAndSettle();
    expect(find.text('about page'), findsOneWidget);

    // Back and test privacy link
    Navigator.of(tester.element(find.byType(Scaffold))).pop();
    await tester.pumpAndSettle();

    final privacyFinder = find.descendant(
      of: footerFinder,
      matching: find.text('Privacy'),
    );
    expect(privacyFinder, findsOneWidget);
    await tester.tap(privacyFinder);
    await tester.pumpAndSettle();
    expect(find.text('privacy page'), findsOneWidget);

    Navigator.of(tester.element(find.byType(Scaffold))).pop();
    await tester.pumpAndSettle();

    final termsFinder = find.descendant(
      of: footerFinder,
      matching: find.text('Terms'),
    );
    expect(termsFinder, findsOneWidget);
    await tester.tap(termsFinder);
    await tester.pumpAndSettle();
    expect(find.text('terms page'), findsOneWidget);
  });

  testWidgets('tapping brand navigates to landing route', (tester) async {
    final routes = <String, WidgetBuilder>{
      '/': (_) => const Scaffold(body: Center(child: Text('landing page'))),
    };

    await pumpPrivacyPage(tester, routes: routes);

    // Tap the brand text 'UniSphere' inside the AppHeader to avoid
    // matching other occurrences (the footer also includes the brand).
    final headerFinder = find.byType(AppHeader);
    expect(headerFinder, findsOneWidget);
    final brandInHeader = find.descendant(
      of: headerFinder,
      matching: find.text('UniSphere'),
    );
    expect(brandInHeader, findsOneWidget);
    await tester.tap(brandInHeader);
    await tester.pumpAndSettle();

    expect(find.text('landing page'), findsOneWidget);
  });
}
