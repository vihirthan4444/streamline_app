import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../providers/pos_provider.dart';
import 'shift_close_screen.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;
  String? _currentShiftId;
  DateTime? _openedAt;

  // Production URL
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Check provider state or fetch active shift?
    // For now, simple UI to open/close
  }

  Future<void> _openShift() async {
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pos/shift/open'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'opening_cash': double.tryParse(_amountCtrl.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentShiftId = data['id'];
          _openedAt = DateTime.parse(data['opened_at']);
        });
        if (mounted) {
          context.read<PosProvider>().setShift(_currentShiftId);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Shift Opened")));
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Network Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync with provider if needed
    final providerShift = context.read<PosProvider>().activeShiftId;
    if (providerShift != null && _currentShiftId == null) {
      // Assumption: Provider holds valid shift ID from previous session if persisted.
      // For V1, we rely on local State or Manual Open.
      _currentShiftId = providerShift;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Shift Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.point_of_sale,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              if (_currentShiftId == null) ...[
                const Text(
                  "No active shift. Open one to start selling.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Opening Cash",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _openShift,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("OPEN SHIFT"),
                ),
              ] else ...[
                Text(
                  "active Shift: $_currentShiftId",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_openedAt != null)
                  Text("Opened At: ${_openedAt.toString()}"),
                const SizedBox(height: 30),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Closing Cash",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShiftCloseScreen(),
                      ),
                    );
                  },
                  child: const Text("CLOSE SHIFT"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
