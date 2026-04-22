import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/widgets/app_footer.dart';

Future<void> pumpFooter(
  WidgetTester tester, {
  double screenWidth = 1400,
  double screenHeight = 800,
  String? brandName,
  String? tagline,
  String? copyright,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppFooter(
            brandName: brandName ?? 'UniSphere',
            tagline:
                tagline ??
                'Discover, share, and manage events with confidence.',
            copyrightText:
                copyright ?? '© UniSphere — Event Discovery Platform',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('footer shows brand, tagline and copyright on desktop', (
    WidgetTester tester,
  ) async {
    await pumpFooter(tester);

    expect(find.text('UniSphere'), findsOneWidget);
    expect(
      find.text('Discover, share, and manage events with confidence.'),
      findsOneWidget,
    );
    expect(find.text('© UniSphere — Event Discovery Platform'), findsOneWidget);
  });

  testWidgets('footer shows brand, tagline and copyright on mobile', (
    WidgetTester tester,
  ) async {
    await pumpFooter(tester, screenWidth: 390);

    expect(find.text('UniSphere'), findsOneWidget);
    expect(
      find.text('Discover, share, and manage events with confidence.'),
      findsOneWidget,
    );
    expect(find.text('© UniSphere — Event Discovery Platform'), findsOneWidget);
  });

  testWidgets('custom values are displayed', (WidgetTester tester) async {
    await pumpFooter(
      tester,
      brandName: 'TestBrand',
      tagline: 'My Tag',
      copyright: '© Test',
    );

    expect(find.text('TestBrand'), findsOneWidget);
    expect(find.text('My Tag'), findsOneWidget);
    expect(find.text('© Test'), findsOneWidget);
  });
}
