import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../core/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncService {
  final AppDatabase _db;
  // Use Production URL for verification, or inject via config in real app
  final String baseUrl = "https://web-production-d9d24.up.railway.app";
  final _storage = const FlutterSecureStorage();

  SyncService(this._db);

  Future<void> syncPendingData() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    // 1. Fetch Pending Orders
    final pendingOrders = await (_db.select(
      _db.orders,
    )..where((tbl) => tbl.isSynced.equals(false))).get();
    if (pendingOrders.isEmpty) return;

    // 2. Fetch Pending Events
    final pendingEvents = await (_db.select(
      _db.stockEvents,
    )..where((tbl) => tbl.isSynced.equals(false))).get();

    // 3. Prepare Batch
    final List<Map<String, dynamic>> ordersJson = [];

    for (var order in pendingOrders) {
      final items = await (_db.select(
        _db.orderItems,
      )..where((tbl) => tbl.orderId.equals(order.id))).get();

      ordersJson.add({
        "id": order.id,
        "cashier_id": order.cashierId,
        "shift_id": order.shiftId,
        "total": order.total,
        "status": order.status,
        "created_at": order.createdAt.toIso8601String(),
        "items": items
            .map(
              (i) => {
                "product_id": i.productId,
                "qty": i.qty,
                "price": i.price,
              },
            )
            .toList(),
      });
    }

    final eventsJson = pendingEvents
        .map(
          (e) => {
            "product_id": e.productId,
            "event_type": e.eventType,
            "quantity": e.quantity,
            "source_id": e.sourceId,
          },
        )
        .toList();

    final payload = {"orders": ordersJson, "stock_events": eventsJson};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pos/sync/batch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          // Mark as Synced
          await (_db.update(_db.orders)..where((t) => t.isSynced.equals(false)))
              .write(const OrdersCompanion(isSynced: Value(true)));
          await (_db.update(_db.stockEvents)
                ..where((t) => t.isSynced.equals(false)))
              .write(const StockEventsCompanion(isSynced: Value(true)));
          print("Sync Successful: ${result['processed_orders']} orders");
        } else {
          print("Sync Partial/Failed: ${result['errors']}");
        }
      } else {
        print("Sync Error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Sync Network Error: $e");
    }
  }
}
