import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/module_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'pos/product_grid_screen.dart';
import 'reports/reports_screen.dart';
import 'stock/stock_reconcile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = context.watch<ModuleProvider>().enabledModules;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Streamline POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: modules.isEmpty
          ? const Center(child: Text("No modules enabled for this tenant"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: modules.length,
              itemBuilder: (ctx, i) {
                final m = modules[i];
                return Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: InkWell(
                    onTap: () {
                      if (m.code == 'POS') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductGridScreen(),
                          ),
                        );
                      } else if (m.code == 'REPORTS') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        );
                      } else if (m.code == 'INVENTORY') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockReconcileScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Open ${m.name}")),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apps,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
