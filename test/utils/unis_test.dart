import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/unis.dart';

void main() {
  test('ukUniversities contains core universities', () {
    expect(ukUniversities, contains('University of Oxford'));
    expect(ukUniversities, contains('University of Cambridge'));
    expect(ukUniversities.length, greaterThan(10));
  });
}
