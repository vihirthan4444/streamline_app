import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_theme.dart';

class ThemeService {
  // Production URL from Railway
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<AppTheme?> getTenantTheme() async {
    // 1. Try local cache first
    final cached = await _storage.read(key: 'cached_theme');
    if (cached != null) {
      try {
        return AppTheme.fromJson(jsonDecode(cached));
      } catch (_) {}
    }

    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/config/theme'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'cached_theme', value: response.body);
        return AppTheme.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Get Theme error: $e');
    }
    return null;
  }
}
