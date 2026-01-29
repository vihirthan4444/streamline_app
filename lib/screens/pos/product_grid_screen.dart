import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database.dart';
import '../../providers/pos_provider.dart';
import 'cart_widget.dart';
import 'shift_screen.dart';

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  @override
  void initState() {
    super.initState();
    // Sync products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().syncProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<PosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("POS - Sales"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await posProvider.syncProducts();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Products Synced")),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.work_history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Product Grid
          Expanded(
            flex: 2,
            child: StreamBuilder<List<Product>>(
              stream: posProvider.itemsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final products = snapshot.data!;
                if (products.isEmpty) {
                  return const Center(
                    child: Text("No products found. Tap sync."),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          posProvider.addToCart(p);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("\$${p.price.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Cart Panel
          const VerticalDivider(width: 1),
          const Expanded(flex: 1, child: CartWidget()),
        ],
      ),
    );
  }
}
