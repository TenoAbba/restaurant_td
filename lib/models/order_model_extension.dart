import 'package:restaurant_td/models/order_model.dart';
import 'package:restaurant_td/utils/order_calculator.dart';

extension OrderModelExtension on OrderModel {
  double get subTotal => OrderCalculator.calculateSubtotal(this);
  double get totalSpecialDiscount =>
      OrderCalculator.calculateSpecialDiscount(this);
  double get discountAmount => double.tryParse(discount.toString()) ?? 0.0;
  double get totalTaxAmount => OrderCalculator.calculateTaxAmount(
      this, subTotal, discountAmount, totalSpecialDiscount);
  double get totalAmount => OrderCalculator.calculateTotal(this);
  double get totalAdminCommission =>
      OrderCalculator.calculateAdminCommission(this, subTotal);
}
