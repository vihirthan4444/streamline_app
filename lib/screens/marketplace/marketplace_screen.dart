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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Marketplace",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Themes", icon: Icon(Icons.palette_outlined)),
            Tab(text: "Modules", icon: Icon(Icons.extension_outlined)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text("Loading Marketplace...",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildThemeGrid(isDark, cardBg, textColor),
                _buildModuleList(isDark, cardBg, textColor, primaryColor),
              ],
            ),
    );
  }

  Widget _buildThemeGrid(bool isDark, Color cardBg, Color textColor) {
    if (_themes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No themes available yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Check back soon for new looks!",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: _themes.length,
          itemBuilder: (context, index) {
            final t = _themes[index];
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      t['preview_url'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              size: 40, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${t['price']}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => _buyTheme(t['id']),
                              child: const Text("Apply Theme"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleList(
      bool isDark, Color cardBg, Color textColor, Color primaryColor) {
    if (_modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension_off_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No modules available yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Check back soon for new features!",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _modules.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final m = _modules[index];
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.extension, color: primaryColor, size: 28),
                ),
                title: Text(
                  m['name'],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    m['description'],
                    style: TextStyle(color: Colors.grey[600], height: 1.3),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${m['price']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey),
                  ],
                ),
                onTap: () => _activateModule(m['code']),
              ),
            );
          },
        ),
      ),
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
