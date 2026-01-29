import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../tenant_selector_screen.dart';

class LoginHandler {
  static Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TenantSelectorScreen()),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Failed")));
    }
  }
}
