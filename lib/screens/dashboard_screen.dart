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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Streamline POS",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (authProvider.subscription != null)
              Text(
                "Plan: ${authProvider.subscription!['plan_name']}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: Colors.red[400]),
              onPressed: () => DashboardHandler.handleLogout(context),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: scaffoldBg,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              accountName: Text(
                authProvider.user?.email ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "Plan: ${authProvider.subscription?['plan_name'] ?? 'Free'}",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: primaryColor),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: primaryColor),
              title: Text("Help & Support", style: TextStyle(color: textColor)),
              subtitle: Text("Chat with us",
                  style: TextStyle(color: Colors.grey[600])),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Redirecting to WhatsApp Support...")),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title:
                  Text("About Streamline", style: TextStyle(color: textColor)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: moduleProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Loading Modules...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : modules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard_customize_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No modules enabled",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Contact support to upgrade your plan",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<ModuleProvider>().loadModules(),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: modules.length,
                      itemBuilder: (ctx, i) {
                        final m = modules[i];
                        final isAllowed = allowedModules.contains(m.code);
                        return _buildModuleCard(
                          context: context,
                          module: m,
                          isAllowed: isAllowed,
                          cardBg: cardBg,
                          textColor: textColor,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required dynamic module,
    required bool isAllowed,
    required Color cardBg,
    required Color textColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: !isAllowed
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Upgrade required for this feature"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : () {
                  if (module.code == 'POS') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductGridScreen()));
                  } else if (module.code == 'REPORTS') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportsScreen()));
                  } else if (module.code == 'INVENTORY') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StockReconcileScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Open ${module.name}")),
                    );
                  }
                },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isAllowed
                            ? primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForModule(module.code),
                        size: 40,
                        color: isAllowed ? primaryColor : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      module.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isAllowed ? textColor : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isAllowed)
                      Text(
                        "Locked",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isAllowed)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.red[300],
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForModule(String code) {
    switch (code) {
      case 'POS':
        return Icons.point_of_sale_rounded;
      case 'REPORTS':
        return Icons.bar_chart_rounded;
      case 'INVENTORY':
        return Icons.inventory_2_rounded;
      case 'SALON':
        return Icons.content_cut_rounded;
      case 'HR':
        return Icons.people_alt_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}
