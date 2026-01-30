import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  group('Auth API Integration Test', () {
    // We use the real backend URL from AuthService
    final String baseUrl = "https://web-production-d9d24.up.railway.app";
    final String uniqueEmail =
        "test_user_${Random().nextInt(10000)}@example.com";
    final String password = "password123";

    test('Health Check', () async {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      print('Health Status: ${response.statusCode}');
      print('Health Body: ${response.body}');
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['status'], 'ok');
    });

    test('Register New User', () async {
      print('Attempting to register: $uniqueEmail');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': uniqueEmail, 'password': password}),
      );

      print('Register Status: ${response.statusCode}');
      print('Register Body: ${response.body}');

      if (response.statusCode != 200) {
        fail(
          'Registration failed with status ${response.statusCode}. Body: ${response.body}',
        );
      }

      final body = jsonDecode(response.body);
      expect(body.containsKey('access_token'), true);
    });

    test('Login User', () async {
      print('Attempting to login: $uniqueEmail');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': uniqueEmail, 'password': password}),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Body: ${response.body}');

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body.containsKey('access_token'), true);
    });
  });
}
