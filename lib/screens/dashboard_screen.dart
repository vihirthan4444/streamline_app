import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/module_provider.dart';
import '../providers/auth_provider.dart';
import 'pos/product_grid_screen.dart';
import 'reports/reports_screen.dart';
import 'stock/stock_reconcile_screen.dart';
import 'handlers/dashboard_handler.dart';
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
            Text(
              "Streamline POS",
              style: TextStyle(color: Theme.of(context).focusColor),
            ),
            Text(
              "Plan: ${authProvider.subscription?['plan_name'] ?? 'Loading...'}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            onPressed: () => DashboardHandler.handleLogout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                authProvider.user?.email ?? "User",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
              accountEmail: Text(
                "Plan: ${authProvider.subscription?['plan_name'] ?? 'Free'}",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(Icons.store, color: Theme.of(context).primaryColor),
              ),
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
            ),
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                "Help & Support",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
              subtitle: Text(
                "Chat with us on WhatsApp",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Redirecting to WhatsApp Support..."),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                "About Streamline",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
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
