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
      final token = body['access_token'];

      // 4. Create Tenant
      print('Attempting to create tenant...');
      final createTenantResponse = await http.post(
        Uri.parse('$baseUrl/tenant/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': 'Test Business', 'business_type': 'Retail'}),
      );

      if (createTenantResponse.statusCode != 200) {
        fail(
          'Create Tenant failed: ${createTenantResponse.statusCode} - ${createTenantResponse.body}',
        );
      }

      final tenantData = jsonDecode(createTenantResponse.body);
      final tenantId = tenantData['id'];
      print('Tenant Created: $tenantId');

      // 5. List Tenants (Data Isolation Check: Should see my tenant)
      print('Attempting to list tenants...');
      final listTenantsResponse = await http.get(
        Uri.parse('$baseUrl/tenant/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (listTenantsResponse.statusCode != 200) {
        fail(
          'List Tenants failed: ${listTenantsResponse.statusCode} - ${listTenantsResponse.body}',
        );
      }

      final List<dynamic> tenants = jsonDecode(listTenantsResponse.body);
      if (!tenants.any((t) => t['id'] == tenantId)) {
        fail('Created tenant not found in "my tenants" list.');
      }
      print('Tenant found in list.');

      // 6. Select Tenant
      print('Attempting to select tenant...');
      // Important: The endpoint expects tenant_id in body
      final selectTenantResponse = await http.post(
        Uri.parse('$baseUrl/auth/select-tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'tenant_id': tenantId}),
      );

      if (selectTenantResponse.statusCode != 200) {
        fail(
          'Select Tenant failed: ${selectTenantResponse.statusCode} - ${selectTenantResponse.body}',
        );
      }

      final newToken = jsonDecode(selectTenantResponse.body)['access_token'];
      print('New Token Received.');

      // 7. Verify JWT Payload (Contains tenant_id and role)
      final parts = newToken.split('.');
      if (parts.length != 3) fail('Invalid JWT format');
      final payloadPart = parts[1];
      var normalized = base64Url.normalize(payloadPart);
      var payloadString = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadString);

      if (payload['tenant_id'] != tenantId) {
        fail(
          'JWT Payload missing correct tenant_id. Got: ${payload['tenant_id']}',
        );
      }
      if (payload['role'] != 'OWNER') {
        fail('JWT Payload missing correct role. Got: ${payload['role']}');
      }
      print('JWT Verification Successful: Tenant ID and Role correct.');
    });
  });
}
