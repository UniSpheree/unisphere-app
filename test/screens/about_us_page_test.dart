import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/about_us_page.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

void main() {
  testWidgets('AboutUsPage renders correctly', (WidgetTester tester) async {
    // Set a larger surface size to prevent overflow in tests
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 0.8),
          child: const AboutUsPage(),
        ),
      ),
    );

    // Verify that the title is present
    expect(find.text('About UniSphere'), findsOneWidget);
    
    // Verify that the mission section is present
    expect(find.text('Our Mission'), findsOneWidget);
    expect(find.textContaining('bringing campus life into the digital age'), findsNothing); // It uses "bring campus life"
    expect(find.textContaining('bring campus life into the digital age'), findsOneWidget);

    // Verify that "Why UniSphere?" section is present
    expect(find.text('Why UniSphere?'), findsOneWidget);

    // Verify widgets
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
  });

  testWidgets('AboutUsPage scrollability', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 0.8),
          child: const AboutUsPage(),
        ),
      ),
    );

    // Ensure we can find the footer (it might be off-screen initially)
    final footerFinder = find.byType(AppFooter);
    await tester.scrollUntilVisible(footerFinder, 100);
    expect(footerFinder, findsOneWidget);
  });

  testWidgets('AboutUsPage navigation interaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
        },
        home: MediaQuery(
          data: const MediaQueryData(textScaleFactor: 0.8),
          child: const AboutUsPage(),
        ),
      ),
    );

    // Find the Sign In button in the header and tap it
    final signInFinder = find.text('Sign In');
    expect(signInFinder, findsOneWidget);
    await tester.tap(signInFinder);
    await tester.pumpAndSettle();

    // Verify we navigated (or at least attempted to)
    expect(find.text('Login Page'), findsOneWidget);
  });
}
