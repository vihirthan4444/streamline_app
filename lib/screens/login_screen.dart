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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Google/Card style usually has a very light grey background for the page
    final scaffoldBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    // And a white card
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFill = isDark ? Colors.grey[900] : Colors.grey[50];
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Constrain the width to avoid stretching on desktop
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.layers,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildGoogleStyleTextField(
                        controller: _emailController,
                        label: "Email",
                        context: context,
                        fillColor: inputFill,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildGoogleStyleTextField(
                        controller: _passwordController,
                        label: "Password",
                        context: context,
                        fillColor: inputFill,
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "New here? ",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Create account",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleStyleTextField({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
    required Color? fillColor,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
