import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/module_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'pos/product_grid_screen.dart';
import 'reports/reports_screen.dart';
import 'stock/stock_reconcile_screen.dart';
import 'marketplace/marketplace_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final authProvider = context.watch<AuthProvider>();
    final modules = moduleProvider.modules;
    final allowedModules =
        authProvider.subscription?['modules_allowed'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Streamline POS"),
            Text(
              "Plan: ${authProvider.subscription?['plan_name'] ?? 'Loading...'}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.email ?? "User"),
              accountEmail: Text(
                "Plan: ${authProvider.subscription?['plan_name'] ?? 'Free'}",
              ),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.store),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Help & Support"),
              subtitle: const Text("Chat with us on WhatsApp"),
              onTap: () {
                // In a real app, use url_launcher
                // launchUrl(Uri.parse("https://wa.me/94770000000"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Redirecting to WhatsApp Support..."),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Streamline"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: modules.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
                final isAllowed = allowedModules.contains(m.code);

                return Card(
                  color: isAllowed
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[300],
                  child: InkWell(
                    onTap: !isAllowed
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Upgrade required for this feature",
                                ),
                              ),
                            );
                          }
                        : () {
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
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconForModule(m.code),
                                size: 48,
                                color: isAllowed
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAllowed
                                      ? Colors.black
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isAllowed)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.lock,
                              color: Colors.redAccent,
                              size: 20,
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

  IconData _getIconForModule(String code) {
    switch (code) {
      case 'POS':
        return Icons.point_of_sale;
      case 'REPORTS':
        return Icons.bar_chart;
      case 'INVENTORY':
        return Icons.inventory;
      case 'SALON':
        return Icons.content_cut;
      case 'HR':
        return Icons.people;
      default:
        return Icons.apps;
    }
  }
}
