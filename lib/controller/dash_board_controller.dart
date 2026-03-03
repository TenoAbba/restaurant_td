import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/Home_screen/home_screen.dart';
import 'package:restaurant_td/app/dine_in_order_screen/dine_in_order_screen.dart';
import 'package:restaurant_td/app/product_screens/product_list_screen.dart';
import 'package:restaurant_td/app/profile_screen/profile_screen.dart';
import 'package:restaurant_td/app/wallet_screen/wallet_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;

  @override
  void onInit() {
    getVendor();
    setNavigationItems();
    super.onInit();
  }

  void setNavigationItems() {
    final baseItems = <NavigationItem>[
      const NavigationItem(
        label: "Home",
        iconPath: "assets/icons/ic_home.svg",
        page: HomeScreen(),
      ),
      if (Constant.isDineInEnable)
        NavigationItem(
          label: "Dine in",
          iconPath: "assets/icons/ic_dinein.svg",
          page: const DineInOrderScreen(),
          permissionModule: "Dine in Requests",
          permissionType: ActionType.isView,
        ),
      NavigationItem(
        label: "Products",
        iconPath: "assets/icons/ic_knife_fork.svg",
        page: const ProductListScreen(),
        permissionModule: "Manage Products",
        permissionType: ActionType.isView,
      ),
      NavigationItem(
        label: "Wallet",
        iconPath: "assets/icons/ic_wallet.svg",
        page: const WalletScreen(),
        permissionModule: "Wallet",
        permissionType: ActionType.isView,
      ),
      const NavigationItem(
        label: "Profile",
        iconPath: "assets/icons/ic_profile.svg",
        page: ProfileScreen(),
      ),
    ];

    // filter by permission
    navigationItems.value = baseItems.where((item) {
      if (item.permissionModule == null) return true;
      return Constant.getEmployeeRolePermission(
            module: item.permissionModule!,
            pType: item.permissionType!,
          ) ==
          true;
    }).toList();
  }

  Rx<VendorModel?> venderModel = VendorModel().obs;
  Future<void> getVendor() async {
    if (Constant.userModel?.vendorID?.isNotEmpty == true) {
      venderModel.value = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID!);
      if (venderModel.value?.id?.isNotEmpty == true) {
        Constant.vendorAdminCommission = venderModel.value?.adminCommission;
      }
    }
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}

class NavigationItem {
  final String label;
  final String iconPath;
  final Widget page;
  final String? permissionModule;
  final ActionType? permissionType;

  const NavigationItem({
    required this.label,
    required this.iconPath,
    required this.page,
    this.permissionModule,
    this.permissionType,
  });
}
