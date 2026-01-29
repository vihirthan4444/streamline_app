import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'CASH';
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PosProvider>();
      _amountController.text = provider.balanceDue.toStringAsFixed(2);
    });
  }

  void _addPayment() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final provider = context.read<PosProvider>();
    if (amount > provider.balanceDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount exceeds balance due')),
      );
      return;
    }

    provider.addPayment(_selectedMethod, amount);
    _amountController.text = provider.balanceDue.toStringAsFixed(2);
  }

  Future<void> _completeCheckout() async {
    setState(() => _isProcessing = true);
    try {
      final provider = context.read<PosProvider>();
      await provider.checkout();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order Completed!')));
        Navigator.pop(context); // Close Payment Screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Order Total:", style: TextStyle(fontSize: 18)),
                Text(
                  "\$${provider.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Balance Due:",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                Text(
                  "\$${provider.balanceDue.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount to Pay",
                border: OutlineInputBorder(),
                prefixText: "\$ ",
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildSmallMethodOption("CASH", Icons.money)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallMethodOption("CARD", Icons.credit_card),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallMethodOption("QR", Icons.qr_code)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.balanceDue <= 0 ? null : _addPayment,
                icon: const Icon(Icons.add),
                label: const Text("ADD PAYMENT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Payments Added:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.currentPayments.length,
                itemBuilder: (context, index) {
                  final p = provider.currentPayments[index];
                  return ListTile(
                    dense: true,
                    title: Text(p.method),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("\$${p.amount.toStringAsFixed(2)}"),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.removePayment(index),
                        ),
                      ],
                    ),
                    leading: const Icon(Icons.payment),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (provider.balanceDue > 0 || _isProcessing)
                    ? null
                    : _completeCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("FINALIZE ORDER"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMethodOption(String method, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black54),
            Text(
              method,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
