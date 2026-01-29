import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../pos/shift_screen.dart';

class PosHandler {
  static Future<void> handleSyncProducts(BuildContext context) async {
    await context.read<PosProvider>().syncProducts();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Products Synced")));
    }
  }

  static void handleOpenShift(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShiftScreen()),
    );
  }
}
