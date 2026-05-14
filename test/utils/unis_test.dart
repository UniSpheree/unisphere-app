import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere_app/utils/unis.dart';

void main() {
  group('ukUniversities list', () {
    test('contains core Russell Group universities', () {
      expect(ukUniversities, contains('University of Oxford'));
      expect(ukUniversities, contains('University of Cambridge'));
      expect(ukUniversities, contains('Imperial College London'));
      expect(ukUniversities, contains('University College London'));
      expect(ukUniversities, contains('London School of Economics'));
    });

    test('contains redbrick universities', () {
      expect(ukUniversities, contains('University of Manchester'));
      expect(ukUniversities, contains('University of Edinburgh'));
      expect(ukUniversities, contains('University of Bristol'));
      expect(ukUniversities, contains('University of Birmingham'));
      expect(ukUniversities, contains('University of Leeds'));
    });

    test('contains modern universities', () {
      expect(ukUniversities, contains('University of Warwick'));
      expect(ukUniversities, contains('University of York'));
      expect(ukUniversities, contains('University of Sussex'));
    });

    test('contains Scottish universities', () {
      expect(ukUniversities, contains('University of Edinburgh'));
      expect(ukUniversities, contains('University of Glasgow'));
      expect(ukUniversities, contains('University of St Andrews'));
      expect(ukUniversities, contains('University of Aberdeen'));
      expect(ukUniversities, contains('University of Dundee'));
    });

    test('contains Welsh universities', () {
      expect(ukUniversities, contains('University of Cardiff'));
    });

    test('contains Northern Irish universities', () {
      expect(ukUniversities, contains('University of Ulster'));
    });

    test('has sufficient number of universities', () {
      expect(ukUniversities.length, greaterThan(30));
    });

    test('does not contain duplicates', () {
      final uniqueCount = ukUniversities.toSet().length;
      expect(uniqueCount, equals(ukUniversities.length));
    });

    test('all entries are non-empty strings', () {
      for (final uni in ukUniversities) {
        expect(uni, isNotEmpty);
        expect(uni, isA<String>());
      }
    });

    test('starts with prominent Russell Group universities', () {
      // Oxford and Cambridge are intentionally first
      expect(ukUniversities.first, 'University of Oxford');
      expect(ukUniversities[1], 'University of Cambridge');
    });

    test('contains at least 45 universities', () {
      expect(ukUniversities.length, greaterThanOrEqualTo(45));
    });
  });
}
