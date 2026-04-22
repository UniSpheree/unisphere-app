import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unisphere_app/screens/friends_list_page.dart';
import 'package:unisphere_app/screens/profile_page.dart';

Future<void> _pumpLargeApp(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('friends list message icon opens chat page', (tester) async {
    await _pumpLargeApp(tester, const FriendsListPage());
    addTearDown(tester.view.reset);

    await tester.tap(find.byIcon(Icons.message).first);
    await tester.pumpAndSettle();

    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('Write a message'), findsOneWidget);
  });

  testWidgets('profile preview message icon opens chat page', (tester) async {
    await _pumpLargeApp(tester, const ProfilePage());
    addTearDown(tester.view.reset);

    await tester.tap(find.byIcon(Icons.message).first);
    await tester.pumpAndSettle();

    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('Write a message'), findsOneWidget);
  });
}
