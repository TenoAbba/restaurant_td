import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restaurant_td/app/chat_screens/restaurant_inbox_screen.dart';
import 'package:restaurant_td/controller/dash_board_controller.dart';
import 'package:restaurant_td/controller/home_controller.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';
import 'package:restaurant_td/constant/constant.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppThemeData.secondary300,
      centerTitle: false,
      elevation: 0,
      title: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          _buildWelcomeText(),
        ],
      ),
      actions: [
        _buildChatAction(),
      ],
      bottom: _buildTabBar(),
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        DashBoardController dashBoardController =
            Get.find<DashBoardController>();
        if (Constant.isDineInEnable &&
            controller.vendermodel.value.subscriptionPlan?.features?.dineIn !=
                false) {
          dashBoardController.selectedIndex.value = 4;
        } else {
          dashBoardController.selectedIndex.value = 3;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: ClipOval(
          child: NetworkImageWidget(
            imageUrl: controller.userModel.value.profilePictureURL.toString(),
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to Foodie Restaurant".tr,
          style: TextStyle(
              color: AppThemeData.grey50.withOpacity(0.8),
              fontSize: 11,
              fontFamily: AppThemeData.regular),
        ),
        Text(
          controller.userModel.value.fullName() ?? "",
          style: const TextStyle(
              color: AppThemeData.grey50,
              fontSize: 16,
              fontFamily: AppThemeData.semiBold),
        ),
      ],
    );
  }

  Widget _buildChatAction() {
    return Visibility(
      visible:
          controller.userModel.value.subscriptionPlan?.features?.chat != false,
      child: IconButton(
        onPressed: () => Get.to(const RestaurantInboxScreen()),
        icon: SvgPicture.asset(
          "assets/icons/ic_chat.svg",
          colorFilter:
              const ColorFilter.mode(AppThemeData.grey50, BlendMode.srcIn),
          width: 24,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      onTap: (value) => controller.selectedTabIndex.value = value,
      tabAlignment: TabAlignment.start,
      labelStyle:
          const TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14),
      labelColor: AppThemeData.grey50,
      unselectedLabelStyle:
          const TextStyle(fontFamily: AppThemeData.medium, fontSize: 14),
      unselectedLabelColor: AppThemeData.secondary100,
      indicatorColor: AppThemeData.grey50,
      indicatorWeight: 3,
      isScrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: "New".tr),
        Tab(text: "Accepted".tr),
        Tab(text: "Completed".tr),
        Tab(text: "Rejected".tr),
        Tab(text: "Cancelled".tr),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}
