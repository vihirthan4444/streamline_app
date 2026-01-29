import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database.dart';
import '../../providers/pos_provider.dart';
import '../handlers/pos_handler.dart';
import 'cart_widget.dart';

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
        title: Text(
          "POS - Sales",
          style: TextStyle(color: Theme.of(context).focusColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: Theme.of(context).primaryColor),
            onPressed: () => PosHandler.handleSyncProducts(context),
          ),
          IconButton(
            icon: Icon(
              Icons.work_history,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () => PosHandler.handleOpenShift(context),
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
                  return Center(
                    child: Text(
                      "No products found. Tap sync.",
                      style: TextStyle(color: Theme.of(context).focusColor),
                    ),
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
                            Icon(
                              Icons.inventory,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).focusColor,
                              ),
                            ),
                            Text(
                              "\$${p.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
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
