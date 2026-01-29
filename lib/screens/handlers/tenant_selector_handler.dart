import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/module_provider.dart';
import '../dashboard_screen.dart';

class TenantSelectorHandler {
  static Future<void> handleTenantSelection({
    required BuildContext context,
    required String tenantId,
  }) async {
    final success = await context.read<AuthProvider>().selectTenant(tenantId);
    if (success && context.mounted) {
      await Future.wait([
        context.read<ThemeProvider>().loadTheme(),
        context.read<ModuleProvider>().loadModules(),
      ]);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }
}
