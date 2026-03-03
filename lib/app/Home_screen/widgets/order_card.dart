import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/Home_screen/order_details_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/home_controller.dart';
import 'package:restaurant_td/models/cart_product_model.dart';
import 'package:restaurant_td/models/order_model.dart';
import 'package:restaurant_td/models/order_model_extension.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';
import 'package:restaurant_td/widget/my_separator.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final DarkThemeProvider themeChange;
  final HomeController controller;
  final VoidCallback onAction;

  const OrderCard({
    super.key,
    required this.order,
    required this.themeChange,
    required this.controller,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = themeChange.getThem();

    return InkWell(
      splashColor: Colors.transparent,
      onTap: () =>
          Get.to(const OrderDetailsScreen(), arguments: {"orderModel": order}),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: ShapeDecoration(
            color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerHeader(isDark),
                _buildSeparator(isDark),
                _buildProductList(isDark),
                _buildSeparator(isDark),
                _buildOrderSummary(isDark),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(bool isDark) {
    return Row(
      children: [
        ClipOval(
          child: NetworkImageWidget(
            imageUrl: order.author?.profilePictureURL ?? "",
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (order.author?.fullName() ?? "Unknown Customer").tr,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
              Text(
                order.takeAway == true
                    ? "Take Away".tr
                    : (order.address?.getFullAddress() ?? "").tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                  fontSize: 13,
                  fontFamily: AppThemeData.medium,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right,
            color: isDark ? AppThemeData.grey600 : AppThemeData.grey300)
      ],
    );
  }

  Widget _buildProductList(bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: order.products?.length ?? 0,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = order.products![index];
        return _buildProductItem(product, isDark);
      },
    );
  }

  Widget _buildProductItem(CartProductModel product, bool isDark) {
    double price = double.tryParse(product.discountPrice ?? "0.0") ?? 0.0;
    if (price <= 0) price = double.tryParse(product.price ?? "0.0") ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "${product.quantity}x ${product.name}".tr,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                  fontSize: 15,
                  fontFamily: AppThemeData.medium,
                ),
              ),
            ),
            Text(
              Constant.amountShow(
                      amount: (price * (product.quantity ?? 1)).toString())
                  .tr,
              style: TextStyle(
                color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                fontSize: 15,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
          ],
        ),
        if (product.extras?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Addons: ${product.extras!.join(', ')}".tr,
              style: TextStyle(
                color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                fontSize: 12,
                fontFamily: AppThemeData.regular,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Column(
      children: [
        _buildSummaryRow(
            "Total Amount".tr,
            Constant.amountShow(amount: order.totalAmount.toString()).tr,
            isDark,
            isBold: true),
        if (order.scheduleTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildSummaryRow(
              "Schedule Time".tr,
              Constant.timestampToDateTime(order.scheduleTime!).tr,
              isDark,
              valueColor: AppThemeData.secondary300,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
            fontSize: 14,
            fontFamily: AppThemeData.regular,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                (isDark ? AppThemeData.grey100 : AppThemeData.grey800),
            fontSize: isBold ? 16 : 14,
            fontFamily: isBold ? AppThemeData.semiBold : AppThemeData.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: MySeparator(
          color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (order.status == Constant.orderPlaced) {
      return Row(
        children: [
          Expanded(
            child: RoundedButtonFill(
              title: "Reject".tr,
              color: AppThemeData.danger300,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: onAction, // simplified for now
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RoundedButtonFill(
              title: "Accept".tr,
              color: AppThemeData.success400,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: onAction,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
