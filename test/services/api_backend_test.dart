import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisphere_app/services/sqlite_backend.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('getEventById returns mapped event with organizer name', () async {
    final backend = SqliteBackend();

    final mockClient = MockClient((request) async {
      final path = request.url.path;

      if (path == '/events/1') {
        final event = {
          'id': 1,
          'title': 'Event One',
          'date': '2024-01-01',
          'organizerEmail': 'org@uni.ac.uk',
        };
        return http.Response(jsonEncode(event), 200);
      }

      if (path.startsWith('/profiles/')) {
        final profile = {'firstName': 'Org', 'lastName': 'Name'};
        return http.Response(jsonEncode(profile), 200);
      }

      // Default: not found
      return http.Response('Not found', 404);
    });

    backend.client = mockClient;

    final result = await backend.getEventById('1');
    expect(result, isNotNull);
    expect(result!['title'], 'Event One');
    expect(result['organizer'], 'Org Name');
  });
}
