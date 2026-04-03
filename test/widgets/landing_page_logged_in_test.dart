import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:unisphere_app/screens/landing_page_logged_in.dart';

void main() {
  testWidgets('PersonalizedLandingPage builds and shows welcome', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PersonalizedLandingPage()));

    // Allow any frames to settle
    await tester.pumpAndSettle();

    // There are multiple "Welcome back" occurrences (accent pill and dashboard card).
    // Verify at least one is present.
    expect(find.textContaining('Welcome back'), findsWidgets);
  });
}
