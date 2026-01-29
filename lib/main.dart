import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

import 'providers/theme_provider.dart';
import 'providers/module_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
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
      title: 'Streamline',
      theme: themeProvider.themeData,
      home: const LoginScreen(),
    );
  }
}
