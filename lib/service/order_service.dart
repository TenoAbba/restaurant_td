import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getOrdersStream(String vendorID) {
    return _firestore
        .collection(CollectionName.restaurantOrders)
        .where('vendorID', isEqualTo: vendorID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> updateOrderStatus(OrderModel order, String status) async {
    order.status = status;
    await _firestore
        .collection(CollectionName.restaurantOrders)
        .doc(order.id)
        .update(order.toJson());
  }
}
