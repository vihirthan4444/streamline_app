import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tenant.dart';
import '../models/user.dart';

class AuthService {
  // Production URL from Railway
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['access_token'];
        await _storage.write(key: 'jwt_token', value: token);
        return token;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> selectTenant(String tenantId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/select-tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'tenant_id': tenantId}),
      );

      if (response.statusCode == 200) {
        final newToken = jsonDecode(response.body)['access_token'];
        await _storage.write(key: 'jwt_token', value: newToken);

        // Parse Role from JWT
        final payload = _parseJwt(newToken);
        return {
          'token': newToken,
          'role': payload['role'],
          'tenant_id': payload['tenant_id'],
        };
      }
    } catch (e) {
      print('Select Tenant error: $e');
    }
    return null;
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }

  Future<List<Tenant>> getMyTenants() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tenant/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tenant.fromJson(json)).toList();
      }
    } catch (e) {
      print('Get Tenants error: $e');
    }
    return [];
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Get User error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>?> getMySubscription() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/billing/my-subscription'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Get Subscription error: $e');
    }
    return null;
  }
}
