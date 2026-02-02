import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'tenant_selector_screen.dart';
import '../services/version_check_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add artificial delay for branding if needed (optional)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Check for updates (Blocking if forced)
    await VersionCheckService().checkForUpdate(context);

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TenantSelectorScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo
            Icon(Icons.layers, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            const Text(
              "Streamline",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text("Loading..."),
          ],
        ),
      ),
    );
  }
}
