import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/widgets/auth_header.dart';

void main() {
  testWidgets('AuthHeader renders brand and controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(appBar: const AuthHeader())),
    );
    await tester.pumpAndSettle();

    // Brand text and icon
    expect(find.text('UniSphere'), findsOneWidget);
    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);

    // Help Center button
    expect(find.text('Help Center'), findsOneWidget);
    await tester.tap(find.text('Help Center'));
    await tester.pumpAndSettle();

    // Language button
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
  });
}
