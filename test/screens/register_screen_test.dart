import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/screens/register_screen.dart';

void main() {
  test('RegisterScreen can be instantiated', () {
    final widget = const RegisterScreen();
    expect(widget, isNotNull);
    expect(widget, isA<RegisterScreen>());
  });
}
