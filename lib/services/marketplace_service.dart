import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MarketplaceService {
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> getStoreThemes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/marketplace/themes'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print('Marketplace Themes Error: $e');
    }
    return [];
  }

  Future<List<dynamic>> getStoreModules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/modules'),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print('Marketplace Modules Error: $e');
    }
    return [];
  }

  Future<bool> buyTheme(String themeStoreId) async {
    final token = await _storage.read(key: 'jwt_token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/buy-theme/$themeStoreId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Buy Theme Error: $e');
    }
    return false;
  }

  Future<bool> activateModule(String moduleCode) async {
    final token = await _storage.read(key: 'jwt_token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/activate-module/$moduleCode'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Activate Module Error: $e');
    }
    return false;
  }
}
