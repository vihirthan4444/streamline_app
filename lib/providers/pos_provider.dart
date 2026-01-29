import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/database.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  double get total => product.price * qty;
}

class PosProvider with ChangeNotifier {
  final AppDatabase _db;
  final String _tenantId; // In real app, get from AuthProvider
  final String _cashierId; // In real app, get from AuthProvider

  List<CartItem> _cart = [];
  bool _isLoading = false;
  String? _activeShiftId;

  PosProvider(this._db, this._tenantId, this._cashierId);

  List<CartItem> get cart => _cart;
  double get total => _cart.fold(0, (sum, item) => sum + item.total);
  bool get isLoading => _isLoading;
  String? get activeShiftId => _activeShiftId;

  void addToCart(Product product) {
    final existingIndex = _cart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      _cart[existingIndex].qty++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _cart = [];
    notifyListeners();
  }

  Future<void> checkout() async {
    if (_cart.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final orderId = const Uuid().v4();
    final now = DateTime.now();

    // 1. Create Order
    await _db
        .into(_db.orders)
        .insert(
          OrdersCompanion.insert(
            id: orderId,
            tenantId: _tenantId,
            cashierId: _cashierId,
            shiftId: Value(_activeShiftId),
            total: total,
            status: const Value('PAID'),
            createdAt: now,
            isSynced: const Value(false),
          ),
        );

    // 2. Create Items & Stock Events
    for (var item in _cart) {
      await _db
          .into(_db.orderItems)
          .insert(
            OrderItemsCompanion.insert(
              id: const Uuid().v4(),
              orderId: orderId,
              productId: item.product.id,
              qty: item.qty,
              price: item.product.price,
            ),
          );

      // Stock Ledger
      await _db
          .into(_db.stockEvents)
          .insert(
            StockEventsCompanion.insert(
              id: const Uuid().v4(),
              productId: item.product.id,
              eventType: 'SALE',
              quantity: -item.qty,
              sourceId: Value(orderId),
              createdAt: now,
              isSynced: const Value(false),
            ),
          );
    }

    clearCart();
    _isLoading = false;
    notifyListeners();
  }

  // Products Logic
  Stream<List<Product>> get itemsStream => _db.select(_db.products).watch();

  Future<void> syncProducts() async {
    _isLoading = true;
    notifyListeners();

    // Production URL
    const baseUrl = "https://web-production-d9d24.up.railway.app";
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pos/products'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        await _db.batch((batch) {
          for (var item in data) {
            batch.insert(
              _db.products,
              ProductsCompanion.insert(
                id: item['id'],
                tenantId: item['tenant_id'],
                sku: item['sku'],
                name: item['name'],
                price: item['price'],
                isActive: Value(item['is_active'] ?? true),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      print("Product Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Shift Management (Simplified for V1)
  void setShift(String? shiftId) {
    _activeShiftId = shiftId;
    notifyListeners();
  }
}
