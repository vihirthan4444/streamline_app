import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockReconcileScreen extends StatefulWidget {
  const StockReconcileScreen({super.key});

  @override
  State<StockReconcileScreen> createState() => _StockReconcileScreenState();
}

class _StockReconcileScreenState extends State<StockReconcileScreen> {
  final _productIdCtrl =
      TextEditingController(); // In real app, scan barcode or select
  final _countCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _isLoading = false;

  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stock/reconcile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': _productIdCtrl.text,
          'physical_count': int.tryParse(_countCtrl.text) ?? 0,
          'reason': _reasonCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Adjusted! Diff: ${data['difference']}"),
              backgroundColor: Colors.green,
            ),
          );
          _productIdCtrl.clear();
          _countCtrl.clear();
          _reasonCtrl.clear();
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Reconciliation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productIdCtrl,
              decoration: const InputDecoration(
                labelText: "Product ID (UUID)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countCtrl,
              decoration: const InputDecoration(
                labelText: "Physical Count",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? _submit
                    : null, // Fix: If loading, disable. Wait, logic is inverted in onPressed? No. null means disabled.
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("SUBMIT ADJUSTMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
