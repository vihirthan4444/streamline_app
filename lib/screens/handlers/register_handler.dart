import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../tenant_selector_screen.dart';

class RegisterHandler {
  static Future<void> handleRegister({
    required BuildContext context,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.register(email, password);
      if (success && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TenantSelectorScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Extract message if it's an exception we threw
        final message = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Failed: $message")),
        );
      }
    }
  }
}
