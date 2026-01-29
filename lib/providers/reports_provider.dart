import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DailySales {
  final String date;
  final double totalSales;
  final double cashSales;
  final double cardSales;
  final int orderCount;

  DailySales({
    required this.date,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
    required this.orderCount,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'],
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      cashSales: (json['cash_sales'] ?? 0).toDouble(),
      cardSales: (json['card_sales'] ?? 0).toDouble(),
      orderCount: json['order_count'] ?? 0,
    );
  }
}

class ReportsProvider with ChangeNotifier {
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<DailySales?> fetchDailySales() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/reports/daily-sales'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return DailySales.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print("Fetch Reports Error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
