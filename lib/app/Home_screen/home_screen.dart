import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/app/Home_screen/widgets/empty_state_views.dart';
import 'package:restaurant_td/app/Home_screen/widgets/home_app_bar.dart';
import 'package:restaurant_td/app/Home_screen/widgets/order_card.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/home_controller.dart';
import 'package:restaurant_td/models/order_model.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<HomeController>(
      init: HomeController(),
      builder: (controller) {
        if (controller.isLoading.value) return Constant.loader();

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: HomeAppBar(controller: controller),
            body: _buildBody(context, themeChange, controller),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DarkThemeProvider themeChange,
      HomeController controller) {
    // 1. Check Document Verification
    if (Constant.isRestaurantVerification &&
        !controller.userModel.value.isDocumentVerify!) {
      return PendingVerificationView(themeChange: themeChange);
    }

    // 2. Check if Restaurant is Added
    if (controller.userModel.value.vendorID == null ||
        controller.userModel.value.vendorID!.isEmpty) {
      return NoRestaurantView(themeChange: themeChange, controller: controller);
    }

    // 3. Main Order Views
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBarView(
        children: [
          _buildOrderList(controller.newOrderList, "New Orders Not found".tr,
              themeChange, controller),
          _buildOrderList(controller.acceptedOrderList,
              "Accepted Orders Not found".tr, themeChange, controller),
          _buildOrderList(controller.completedOrderList,
              "Completed Orders Not found".tr, themeChange, controller),
          _buildOrderList(controller.rejectedOrderList,
              "Rejected Orders Not found".tr, themeChange, controller),
          _buildOrderList(controller.cancelledOrderList,
              "Cancelled Orders Not found".tr, themeChange, controller),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMessage,
      DarkThemeProvider themeChange, HomeController controller) {
    if (orders.isEmpty) return Constant.showEmptyView(message: emptyMessage);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: orders[index],
          themeChange: themeChange,
          controller: controller,
          onAction: () {
            // Logic for updates remains in controller or passes through
            controller.getUserProfile();
          },
        );
      },
    );
  }
}
