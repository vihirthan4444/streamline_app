import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class TenantSelectorScreen extends StatelessWidget {
  const TenantSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<AuthProvider>().tenants;
    return Scaffold(
      appBar: AppBar(title: const Text("Select Business")),
      body: tenants.isEmpty
          ? const Center(child: Text("No businesses found"))
          : ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(tenants[i].name),
                subtitle: Text(tenants[i].businessType),
                onTap: () async {
                  final success = await context
                      .read<AuthProvider>()
                      .selectTenant(tenants[i].id);
                  if (success && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
