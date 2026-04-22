import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/landing_page.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

Future<void> pumpLanding(
  WidgetTester tester, {
  double screenWidth = 1400,
  double screenHeight = 900,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MaterialApp(home: LandingPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('landing page shows header, hero, stats and footer', (
    WidgetTester tester,
  ) async {
    await pumpLanding(tester);

    // Header brand
    expect(find.text('UniSphere'), findsWidgets);

    // Hero text and Host button
    expect(find.text('Host an Event'), findsOneWidget);

    // Some hero/stat content
    expect(find.textContaining('Discover local events'), findsOneWidget);
    expect(find.text('10K+'), findsOneWidget);

    // Footer present
    expect(find.byType(AppFooter), findsOneWidget);
  });

  testWidgets('tapping Host an Event navigates to CreateEventScreen', (
    WidgetTester tester,
  ) async {
    await pumpLanding(tester);

    // Ensure the Host button is visible (scroll into view) then tap
    final hostFinder = find.text('Host an Event');
    await tester.ensureVisible(hostFinder);
    await tester.pumpAndSettle();
    await tester.tap(hostFinder);
    await tester.pumpAndSettle();

    // CreateEventScreen contains the title 'Create New Event' (may appear
    // multiple times: breadcrumb + title). Ensure at least one instance.
    expect(find.text('Create New Event'), findsWidgets);
  });

  testWidgets('mobile layout still shows host button and footer', (
    WidgetTester tester,
  ) async {
    await pumpLanding(tester, screenWidth: 390, screenHeight: 800);

    expect(find.text('Host an Event'), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
  });
}
