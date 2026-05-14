import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/profile_page.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';
import 'package:unisphere_app/models/database_models.dart';

Future<void> pumpProfilePage(
  WidgetTester tester, {
  DbUser? user,
  double screenWidth = 2000,
  double screenHeight = 1000,
  Map<String, WidgetBuilder>? routes,
}) async {
  tester.view.physicalSize = Size(screenWidth, screenHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Inject mock user into the backend so the page reads the expected state.
  if (user != null) {
    SqliteBackend().injectMockState(user: user);
  } else {
    SqliteBackend().injectMockState(clearUser: true);
  }

  final Widget page = SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth),
        child: const ProfilePage(),
      ),
    ),
  );

  if (routes != null && routes.containsKey('/')) {
    final augmented = Map<String, WidgetBuilder>.from(routes);
    const testRoute = '/__test_profile';
    augmented[testRoute] = (_) => page;
    await tester.pumpWidget(
      MaterialApp(routes: augmented, initialRoute: testRoute),
    );
  } else {
    await tester.pumpWidget(MaterialApp(routes: routes ?? {}, home: page));
  }
  await tester.pumpAndSettle();
}

void main() {
  test('ProfilePage widget can be instantiated', () {
    final page = ProfilePage();
    expect(page, isNotNull);
    expect(page, isA<ProfilePage>());
  });

  test('SqliteBackend injectMockState sets current user', () async {
    final user = DbUser(
      id: 10,
      email: 'test@example.com',
      password: 'pw',
      firstName: 'Test',
      lastName: 'User',
      role: 'Attendee',
      university: 'Test U',
      description: '',
      isApproved: true,
      createdAt: DateTime.now(),
    );

    SqliteBackend().injectMockState(user: user);
    expect(SqliteBackend().currentUser?.email, equals('test@example.com'));
  });

  testWidgets('ProfilePage can be pumped (smoke test)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: SizedBox(width: 1400, child: ProfilePage())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
  });
}
