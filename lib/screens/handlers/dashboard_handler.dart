import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

class DashboardHandler {
  static Future<void> handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static void handleModuleNavigation({
    required BuildContext context,
    required String moduleCode,
    required Widget targetScreen,
    bool isAllowed = true,
  }) {
    if (!isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upgrade required for this feature")),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
  }
}
