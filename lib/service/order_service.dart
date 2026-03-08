import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _db = Supabase.instance.client;

  Stream<List<OrderModel>> getOrdersStream(String vendorID) {
    return _db
        .from(CollectionName.restaurantOrders)
        .stream(primaryKey: ['id'])
        .eq('vendorID', vendorID)
        .order('createdAt', ascending: false)
        .map((rows) => rows.map((r) => OrderModel.fromJson(r)).toList());
  }

  Future<void> updateOrderStatus(OrderModel order, String status) async {
    order.status = status;
    await _db.from(CollectionName.restaurantOrders).upsert(order.toJson());
  }
}
