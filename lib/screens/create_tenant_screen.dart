import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CreateTenantScreen extends StatefulWidget {
  const CreateTenantScreen({super.key});

  @override
  State<CreateTenantScreen> createState() => _CreateTenantScreenState();
}

class _CreateTenantScreenState extends State<CreateTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'Retail';
  final List<String> _businessTypes = [
    'Retail',
    'Restaurant',
    'Service',
    'Other',
  ];

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      try {
        final success = await authProvider.createTenant(
          _nameController.text.trim(),
          _selectedType,
        );
        if (success && mounted) {
          Navigator.pop(context); // Return to selector, list will refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create business: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFill = isDark ? Colors.grey[900] : Colors.grey[50];
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Create Business",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(32),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_business_outlined,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "New Business",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your business details below",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStyledTextField(
                      controller: _nameController,
                      label: "Business Name",
                      context: context,
                      fillColor: inputFill,
                      icon: Icons.store,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _businessTypes
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                      style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Business Type",
                        prefixIcon: Icon(Icons.category,
                            size: 20, color: Colors.grey[600]),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: 'LKR',
                      items: ['LKR', 'USD', 'EUR']
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {},
                      style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Currency",
                        prefixIcon: Icon(Icons.attach_money,
                            size: 20, color: Colors.grey[600]),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Create Business",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
    required Color? fillColor,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (val) => val == null || val.isEmpty ? "Name required" : null,
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
