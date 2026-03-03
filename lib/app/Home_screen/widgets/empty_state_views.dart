import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/app/verification_screen/verification_screen.dart';
import 'package:restaurant_td/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant_td/controller/home_controller.dart';

class PendingVerificationView extends StatelessWidget {
  final DarkThemeProvider themeChange;
  const PendingVerificationView({super.key, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeChange.getThem();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(context, "assets/icons/ic_document.svg", isDark),
          const SizedBox(height: 24),
          Text(
            "Document Verification Pending".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your documents are being reviewed. We will notify you once the verification is complete."
                .tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.medium,
            ),
          ),
          const SizedBox(height: 32),
          RoundedButtonFill(
            title: "View Status".tr,
            width: 60,
            height: 5.5,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: () => Get.to(const VerificationScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, String svgPath, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(svgPath, width: 48, height: 48),
    );
  }
}

class NoRestaurantView extends StatelessWidget {
  final DarkThemeProvider themeChange;
  final HomeController controller;
  const NoRestaurantView(
      {super.key, required this.themeChange, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeChange.getThem();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(context, "assets/icons/ic_building_two.svg", isDark),
          const SizedBox(height: 24),
          Text(
            "Add Your First Restaurant".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Get started by adding your restaurant details to manage your menu, orders, and reservations."
                .tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.medium,
            ),
          ),
          const SizedBox(height: 32),
          RoundedButtonFill(
            title: "Add Restaurant".tr,
            width: 60,
            height: 5.5,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: () => Get.to(const AddRestaurantScreen())
                ?.then((v) => controller.getUserProfile()),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, String svgPath, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(svgPath, width: 48, height: 48),
    );
  }
}
