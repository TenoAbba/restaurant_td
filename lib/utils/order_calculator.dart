import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/order_model.dart';

class OrderCalculator {
  static double calculateSubtotal(OrderModel order) {
    double subTotal = 0.0;
    if (order.products == null) return subTotal;

    for (var element in order.products!) {
      double price = double.tryParse(element.discountPrice.toString()) ?? 0.0;
      if (price <= 0) {
        price = double.tryParse(element.price.toString()) ?? 0.0;
      }

      int quantity = element.quantity ?? 0;
      double extrasPrice =
          double.tryParse(element.extrasPrice.toString()) ?? 0.0;

      subTotal += (price * quantity) + (extrasPrice * quantity);
    }
    return subTotal;
  }

  static double calculateSpecialDiscount(OrderModel order) {
    double specialDiscount = 0.0;
    if (order.specialDiscount != null &&
        order.specialDiscount!['special_discount'] != null) {
      specialDiscount = double.tryParse(
              order.specialDiscount!['special_discount'].toString()) ??
          0.0;
    }
    return specialDiscount;
  }

  static double calculateTaxAmount(OrderModel order, double subTotal,
      double discount, double specialDiscount) {
    double taxAmount = 0.0;
    if (order.taxSetting != null) {
      for (var element in order.taxSetting!) {
        taxAmount += Constant.calculateTax(
          amount: (subTotal - discount - specialDiscount).toString(),
          taxModel: element,
        );
      }
    }
    return taxAmount;
  }

  static double calculateTotal(OrderModel order) {
    double subTotal = calculateSubtotal(order);
    double discount = double.tryParse(order.discount.toString()) ?? 0.0;
    double specialDiscount = calculateSpecialDiscount(order);
    double taxAmount =
        calculateTaxAmount(order, subTotal, discount, specialDiscount);

    return subTotal - discount - specialDiscount + taxAmount;
  }

  static double calculateAdminCommission(OrderModel order, double subTotal) {
    double adminCommission = 0.0;
    if (order.adminCommission == null) return adminCommission;

    double commissionValue = double.tryParse(order.adminCommission!) ?? 0.0;

    if (order.adminCommissionType == 'Percent') {
      double basePrice = subTotal / (1 + (commissionValue / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = commissionValue;
    }
    return adminCommission;
  }
}
