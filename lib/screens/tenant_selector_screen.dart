import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'handlers/tenant_selector_handler.dart';

class TenantSelectorScreen extends StatelessWidget {
  const TenantSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<AuthProvider>().tenants;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Business",
          style: TextStyle(color: Theme.of(context).focusColor),
        ),
      ),
      body: tenants.isEmpty
          ? Center(
              child: Text(
                "No businesses found",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
            )
          : ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(
                  tenants[i].name,
                  style: TextStyle(color: Theme.of(context).focusColor),
                ),
                subtitle: Text(
                  tenants[i].businessType,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                onTap: () => TenantSelectorHandler.handleTenantSelection(
                  context: context,
                  tenantId: tenants[i].id,
                ),
              ),
            ),
    );
  }
}
