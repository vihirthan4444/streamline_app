import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/module_provider.dart';
import 'dashboard_screen.dart';

class AppInitializerScreen extends StatefulWidget {
  const AppInitializerScreen({super.key});

  @override
  State<AppInitializerScreen> createState() => _AppInitializerScreenState();
}

class _AppInitializerScreenState extends State<AppInitializerScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Parallel loading of configuration
      await Future.wait([
        context.read<ThemeProvider>().loadTheme(),
        context.read<ModuleProvider>().loadModules(),
      ]);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      // Error handling (Retry logic could go here)
      print("Initialization failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load configuration: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple UI as requested
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Loading configuration..."),
          ],
        ),
      ),
    );
  }
}
