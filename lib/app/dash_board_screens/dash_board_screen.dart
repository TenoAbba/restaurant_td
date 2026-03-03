import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/controller/dash_board_controller.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        final isDark = themeChange.getThem();
        return PopScope(
          canPop: controller.canPopNow.value,
          onPopInvoked: (didPop) {
            final now = DateTime.now();
            if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
              controller.currentBackPressTime = now;
              controller.canPopNow.value = false;
              ShowToastDialog.showToast("Double press to exit".tr);
              return;
            } else {
              controller.canPopNow.value = true;
            }
          },
          child: Scaffold(
            body: controller.navigationItems[controller.selectedIndex.value].page,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
              unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
              currentIndex: controller.selectedIndex.value,
              backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
              selectedItemColor: AppThemeData.secondary300,
              unselectedItemColor: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              onTap: (index) => controller.selectedIndex.value = index,
              items: List.generate(
                controller.navigationItems.length,
                (index) => navigationBarItem(
                  controller.navigationItems[index],
                  index,
                  controller,
                  isDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem navigationBarItem(
    NavigationItem item,
    int index,
    DashBoardController controller,
    bool isDark,
  ) {
    final isSelected = controller.selectedIndex.value == index;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          item.iconPath,
          height: 22,
          width: 22,
          color: isSelected ? AppThemeData.secondary300 : (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
        ),
      ),
      label: item.label.tr,
    );
  }
}
