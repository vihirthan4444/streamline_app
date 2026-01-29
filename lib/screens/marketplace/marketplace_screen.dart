import 'package:flutter/material.dart';
import '../../services/marketplace_service.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/module_provider.dart';
import '../../providers/auth_provider.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceService _service = MarketplaceService();
  bool _isLoading = false;
  List<dynamic> _themes = [];
  List<dynamic> _modules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _themes = await _service.getStoreThemes();
    _modules = await _service.getStoreModules();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Themes", icon: Icon(Icons.palette)),
            Tab(text: "Modules", icon: Icon(Icons.extension)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildThemeGrid(), _buildModuleList()],
            ),
    );
  }

  Widget _buildThemeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final t = _themes[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  t['preview_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${t['price']}",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _buyTheme(t['id']),
                        child: const Text("APPLY"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModuleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final m = _modules[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.extension, size: 40),
            title: Text(m['name']),
            subtitle: Text(m['description']),
            trailing: Text(
              "\$${m['price']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _activateModule(m['code']),
          ),
        );
      },
    );
  }

  Future<void> _buyTheme(String id) async {
    setState(() => _isLoading = true);
    final success = await _service.buyTheme(id);
    if (success) {
      await context.read<ThemeProvider>().loadTheme();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Theme applied!')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _activateModule(String code) async {
    setState(() => _isLoading = true);
    final success = await _service.activateModule(code);
    if (success) {
      await context.read<ModuleProvider>().loadModules();
      // Also refresh subscription info to update UI locks
      await context.read<AuthProvider>().fetchSubscription();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Module activated!')));
    }
    setState(() => _isLoading = false);
  }
}
