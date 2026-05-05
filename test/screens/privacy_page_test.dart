import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/privacy_page.dart';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';

Future<void> pumpPrivacyPage(
  WidgetTester tester, {
  double screenWidth = 1400,
  double screenHeight = 1200,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MaterialApp(home: PrivacyPage()));
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
}
