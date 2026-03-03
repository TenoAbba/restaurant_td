import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant_td/app/employee_screens/add_employee_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/employee_list_controller.dart';
import 'package:restaurant_td/models/employee_role_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/responsive.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: EmployeeListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Manage Employees".tr,
                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
              actions: [
                (((Constant.isRestaurantVerification == true && Constant.userModel?.isDocumentVerify == false) ||
                            (Constant.userModel?.vendorID == null || Constant.userModel?.vendorID?.isEmpty == true)) &&
                        Constant.getEmployeeRolePermission(module: "All Employee", pType: ActionType.isAdd) == true)
                    ? SizedBox()
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Get.to(const AddEmployeeScreen())?.then((value) {
                            if (value == true) {
                              Get.back();
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppThemeData.grey50,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Add".tr,
                                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                              )
                            ],
                          ),
                        ),
                      )
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : (Constant.userModel?.vendorID?.isEmpty == true || Constant.userModel?.vendorID == null)
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
                              "Get started by adding your restaurant details to manage your employee men.".tr,
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
                    : controller.employeeUserList.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/ic_employee.svg",
                                  colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, BlendMode.srcIn),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "No Employees Available".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "No Employees found! Add your first employee to start managing your team.".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (Constant.getEmployeeRolePermission(module: "All Employee", pType: ActionType.isAdd) == true)
                                  RoundedButtonFill(
                                      title: "Add Employees".tr,
                                      width: 55,
                                      height: 5.5,
                                      color: AppThemeData.secondary300,
                                      textColor: AppThemeData.grey50,
                                      onPress: () async {
                                        Get.to(const AddEmployeeScreen())?.then((value) {
                                          if (value == true) {
                                            Get.back();
                                          }
                                        });
                                      }),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: ListView.builder(
                              itemCount: controller.employeeUserList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if (Constant.getEmployeeRolePermission(module: "All Employee", pType: ActionType.isAdd) == true) {
                                      Get.to(const AddEmployeeScreen(), arguments: {"employeemodel": controller.employeeUserList[index]})?.then((value) {
                                        if (value == true) {
                                          controller.getAllEmployeeList();
                                        }
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            controller.employeeUserList[index].profilePictureURL == null || controller.employeeUserList[index].profilePictureURL == ''
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(60),
                                                    child: Image.asset(
                                                      Constant.userPlaceHolder,
                                                      height: Responsive.width(20, context),
                                                      width: Responsive.width(20, context),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius: const BorderRadius.all(Radius.circular(60)),
                                                    child: NetworkImageWidget(
                                                      imageUrl: controller.employeeUserList[index].profilePictureURL.toString(),
                                                      fit: BoxFit.cover,
                                                      height: Responsive.width(20, context),
                                                      width: Responsive.width(20, context),
                                                    )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: Responsive.width(18, context),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "${controller.employeeUserList[index].firstName ?? ''} ${controller.employeeUserList[index].lastName ?? ''}",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                              fontFamily: AppThemeData.semiBold,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        FutureBuilder<EmployeeRoleModel?>(
                                                          future: FireStoreUtils.getEmployeeRoleById(
                                                            controller.employeeUserList[index].employeePermissionId!,
                                                          ),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError || !snapshot.hasData) {
                                                              return const SizedBox(
                                                                height: 18,
                                                                width: 18,
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                              );
                                                            }

                                                            final role = snapshot.data;
                                                            return Container(
                                                              margin: EdgeInsets.symmetric(horizontal: 4),
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                                                                borderRadius: BorderRadius.circular(4.0),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                                                                    blurRadius: 1,
                                                                    spreadRadius: 0.5,
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Text(
                                                                role?.title ?? "Unknown Role", // use actual field from EmployeeRoleModel
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                  fontFamily: AppThemeData.semiBold,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "${controller.employeeUserList[index].countryCode} ${controller.employeeUserList[index].phoneNumber}",
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                fontFamily: AppThemeData.regular,
                                                              ),
                                                            ),
                                                            Text(
                                                              controller.employeeUserList[index].email.toString(),
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                fontFamily: AppThemeData.regular,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        GetBuilder<EmployeeListController>(builder: (controller) {
                                                          return Transform.scale(
                                                            scale: 0.8,
                                                            child: CupertinoSwitch(
                                                              activeTrackColor: AppThemeData.secondary300,
                                                              value: controller.employeeUserList[index].active ?? false,
                                                              onChanged: (value) {
                                                                if (Constant.getEmployeeRolePermission(module: "All Employee", pType: ActionType.isAdd) == true) {
                                                                  controller.employeeUserList[index].active = value;
                                                                  controller.updateEmployee(controller.employeeUserList[index]);
                                                                  controller.update();
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          );
        });
  }
}
