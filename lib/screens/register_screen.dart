import 'package:flutter/material.dart';
import 'handlers/register_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    await RegisterHandler.handleRegister(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register for Streamline",
          style: TextStyle(color: Theme.of(context).focusColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              style: TextStyle(color: Theme.of(context).focusColor),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(
                  Icons.email,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: Theme.of(context).focusColor),
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              style: TextStyle(color: Theme.of(context).focusColor),
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text("Create Account"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
