import 'package:flutter/material.dart';
import '../core/version_service.dart';
import 'register_screen.dart';
import 'handlers/login_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    final versionService = VersionService();
    final updateRequired = await versionService.isUpdateRequired();
    if (updateRequired && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Update Required"),
          content: const Text(
            "A new version of Streamline is available. Please update to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // In real app, launch URL
              },
              child: const Text("UPDATE NOW"),
            ),
          ],
        ),
      );
    }
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    await LoginHandler.handleLogin(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login to Streamline",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).focusColor,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Theme.of(context).focusColor),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Theme.of(context).focusColor),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("New to Streamline? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
