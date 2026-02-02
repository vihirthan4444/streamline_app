import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MarketplaceService {
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> getStoreThemes() async {
    try {
      final url = Uri.parse('$baseUrl/marketplace/themes');
      print("[Marketplace] Fetching themes from: $url");
      final response = await http.get(url);
      print(
          "[Marketplace] Themes Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) return data;
      }
    } catch (e) {
      print('[Marketplace] Themes Error: $e');
    }
    print("[Marketplace] Returning Mock Themes");
    return _getMockThemes();
  }

  Future<List<dynamic>> getStoreModules() async {
    try {
      final url = Uri.parse('$baseUrl/marketplace/modules');
      print("[Marketplace] Fetching modules from: $url");
      final response = await http.get(url);
      print(
          "[Marketplace] Modules Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) return data;
      }
    } catch (e) {
      print('[Marketplace] Modules Error: $e');
    }
    print("[Marketplace] Returning Mock Modules");
    return _getMockModules();
  }

  List<dynamic> _getMockThemes() {
    return [
      {
        "id": "theme_1",
        "name": "Midnight Pro",
        "price": 0.0,
        "preview_url":
            "https://cdn.dribbble.com/users/1615584/screenshots/15710288/media/6c7a7f41a8a2d1d0f813952f4c2c0400.jpg",
        "description": "A sleek, dark theme for professional environments."
      },
      {
        "id": "theme_2",
        "name": "Oceanic Blue",
        "price": 9.99,
        "preview_url":
            "https://cdn.dribbble.com/users/418188/screenshots/16434447/media/64627192667104840871317181056588.png",
        "description": "Calming blue tones for a relaxed customer experience."
      },
      {
        "id": "theme_3",
        "name": "Sunny Day",
        "price": 4.99,
        "preview_url":
            "https://cdn.dribbble.com/users/795775/screenshots/15697200/media/84683056066265008064406288827598.png",
        "description": "Bright and energetic theme for high-traffic stores."
      }
    ];
  }

  List<dynamic> _getMockModules() {
    return [
      {
        "code": "mod_loyalty",
        "name": "Customer Loyalty",
        "price": 19.99,
        "description":
            "Points, rewards, and membership tiers to retain customers."
      },
      {
        "code": "mod_kitchen",
        "name": "Kitchen Display",
        "price": 29.99,
        "description":
            "Send orders directly to the kitchen with real-time updates."
      },
      {
        "code": "mod_accounting",
        "name": "Accounting Sync",
        "price": 14.99,
        "description": "Auto-sync your daily sales with Xero and QuickBooks."
      },
      {
        "code": "mod_reservations",
        "name": "Table Reservations",
        "price": 0.0,
        "description": "Manage table bookings and optimize seating usage."
      }
    ];
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
