import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../app_initializer_screen.dart';

class TenantSelectorHandler {
  static Future<void> handleTenantSelection({
    required BuildContext context,
    required String tenantId,
  }) async {
    final success = await context.read<AuthProvider>().selectTenant(tenantId);
    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppInitializerScreen()),
      );
    }
  }
}
