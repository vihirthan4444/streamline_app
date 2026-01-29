import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_module.dart';

class ModuleService {
  // Production URL from Railway
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<List<AppModule>> getTenantModules() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tenant-config/my-modules'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AppModule.fromJson(json)).toList();
      }
    } catch (e) {
      print('Get Modules error: $e');
    }
    return [];
  }
}
