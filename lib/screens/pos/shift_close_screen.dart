import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';

class ShiftCloseScreen extends StatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  State<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends State<ShiftCloseScreen> {
  final _cashController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  Future<void> _closeShift() async {
    final cashStr = _cashController.text;
    if (cashStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter closing cash amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final closingCash = double.tryParse(cashStr);
      if (closingCash == null) throw Exception("Invalid amount");

      final provider = context.read<PosProvider>();
      final result = await provider.closeShift(
        closingCash,
        _noteController.text,
      );

      if (mounted && result != null) {
        // Show Reconciliation Result
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final expected = result['expected_cash'] ?? 0.0;
    final diff = result['difference'] ?? 0.0;
    final isBalanced = (diff as num).abs() < 0.01;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isBalanced ? "Shift Balanced ✅" : "Cash Mismatch ⚠️"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Expected Cash: \$${expected.toStringAsFixed(2)}"),
            Text("Actual Cash: \$${_cashController.text}"),
            const SizedBox(height: 10),
            Text(
              "Difference: \$${diff.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBalanced ? Colors.green : Colors.red,
                fontSize: 18,
              ),
            ),
            if (!isBalanced)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "This mismatch has been logged for audit.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context); // Close Screen
            },
            child: const Text("CLOSE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Close Shift")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cashController,
              decoration: const InputDecoration(
                labelText: "Closing Cash Amount",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "Note (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _closeShift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CLOSE SHIFT & RECONCILE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
