import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

import 'providers/theme_provider.dart';
import 'providers/module_provider.dart';
import 'providers/pos_provider.dart';
import 'providers/reports_provider.dart';
import 'core/database.dart';

void main() {
  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        // Provide Database and PosProvider
        Provider<AppDatabase>.value(value: database),
        // Simplification: In real app, tenantId/cashierId should be dynamic.
        // For V1, we rely on AuthProvider or pass dummy for now until we link them properly.
        // Actually PosProvider needs tenantId/cashierId.
        // We can use ProxyProvider to get them from AuthProvider?
        // Or simpler: Initialize PosProvider later or lazy load?
        // Let's use ProxyProvider to depend on AuthProvider.
        ProxyProvider<AuthProvider, PosProvider>(
          update: (_, auth, __) =>
              PosProvider(database, auth.tenantId ?? '', auth.userId ?? ''),
        ),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: const StreamlineApp(),
    ),
  );
}

class StreamlineApp extends StatelessWidget {
  const StreamlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch ThemeProvider to rebuild when theme changes
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Streamline',
      theme: themeProvider.themeData,
      home: const SplashScreen(),
    );
  }
}
