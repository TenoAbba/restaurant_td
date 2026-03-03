import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant_td/app/employee_role_screens/add_edit_role_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/role_controller.dart';
import 'package:restaurant_td/models/employee_role_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RoleController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Employee Role".tr,
                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : Constant.userModel?.vendorID == null || Constant.userModel?.vendorID?.isEmpty == true
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: SvgPicture.asset("assets/icons/ic_building_two.svg"),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Add Your First Restaurant".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Get started by adding your restaurant details to manage your menu, orders, and reservations.".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              RoundedButtonFill(
                                title: "Add Restaurant".tr,
                                width: 55,
                                height: 5.5,
                                color: AppThemeData.secondary300,
                                textColor: AppThemeData.grey50,
                                onPress: () async {
                                  Get.to(const AddRestaurantScreen())?.then((value) {
                                    controller.update();
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : controller.employeeRolelList.isEmpty
                          ? Constant.showEmptyView(message: "No employee role found".tr)
                          : ListView.builder(
                              itemCount: controller.employeeRolelList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                EmployeeRoleModel model = controller.employeeRolelList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      if (Constant.getEmployeeRolePermission(module: "Employee Role", pType: ActionType.isAdd) == true) {
                                        Get.to(const AddEditRoleScreen(), arguments: {"employeeRoleModel": model})!.then(
                                          (value) {
                                            if (value == true) {
                                              controller.getAllEmployeeRoles();
                                            }
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08), // subtle shadow
                                            blurRadius: 12, // soft edges
                                            offset: const Offset(0, 4), // shadow position
                                            spreadRadius: 1, // light spread
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            model.title ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (Constant.getEmployeeRolePermission(module: "Employee Role", pType: ActionType.isAdd) == true)
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/ic_edit_coupon.svg",
                                                    width: 22,
                                                    height: 22,
                                                  ),
                                                ),
                                              if (Constant.getEmployeeRolePermission(module: "Employee Role", pType: ActionType.isDelete) == true)
                                                IconButton(
                                                  onPressed: () {
                                                    FireStoreUtils.deleteEmployeeRole(model.id!);
                                                    controller.employeeRolelList.remove(model);
                                                  },
                                                  icon: SvgPicture.asset(
                                                    "assets/icons/ic_delete.svg",
                                                    width: 22,
                                                    height: 22,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            floatingActionButton: Constant.getEmployeeRolePermission(module: "Employee Role", pType: ActionType.isAdd) == false
                ? null
                : FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: AppThemeData.secondary300,
                    onPressed: () {
                      Get.to(const AddEditRoleScreen())!.then((value) {
                        if (value == true) {
                          controller.getAllEmployeeRoles();
                        }
                      });
                    },
                    child: const Icon(
                      Icons.add,
                      color: AppThemeData.grey50,
                    ),
                  ),
          );
        });
  }
}
