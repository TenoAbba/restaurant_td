import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/add_edit_role_controller.dart';
import 'package:restaurant_td/models/permission_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/themes/text_field_widget.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';

class AddEditRoleScreen extends StatelessWidget {
  const AddEditRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: AddEditRoleController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
            title: Text(
              Get.arguments == null ? "Create Role" : "Edit Role".tr,
              style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Active".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 16),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                activeTrackColor: AppThemeData.secondary300,
                                value: controller.isActive.value,
                                onChanged: (value) {
                                  controller.isActive.value = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFieldWidget(
                          fontFamilyTitle: AppThemeData.semiBold,
                          fontSizeTitle: 16,
                          title: 'Role Name'.tr,
                          controller: controller.nameController.value,
                          hintText: 'Role Name'.tr,
                        ),
                        Text(
                          "Permissions".tr,
                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          padding: EdgeInsets.all(0),
                          primary: false,
                          itemCount: controller.permissionList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            bool selectAll = false;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08), // subtle shadow
                                      blurRadius: 12, // soft edges
                                      offset: const Offset(0, 4), // shadow position
                                      spreadRadius: 1, // light spread
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller.permissionList[index].title ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.semiBold,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Select All',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                    fontFamily: AppThemeData.semiBold,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: isAllPermissionsSelected(controller.permissionList[index]),
                                                  activeColor: AppThemeData.secondary300, // Color when checked
                                                  checkColor: Colors.white, // Tick color
                                                  onChanged: (bool? value) {
                                                    selectAll = value ?? false;
                                                    if (controller.permissionList[index].isAdd != null) controller.permissionList[index].isAdd = selectAll;
                                                    if (controller.permissionList[index].isView != null) controller.permissionList[index].isView = selectAll;
                                                    if (controller.permissionList[index].isDelete != null) controller.permissionList[index].isDelete = selectAll;
                                                    controller.permissionList.refresh();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (controller.permissionList[index].isView != null)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'View',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                                                      fontFamily: AppThemeData.medium,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: controller.permissionList[index].isView,
                                                    activeColor: AppThemeData.secondary300, // Color when checked
                                                    checkColor: Colors.white, // Tick color
                                                    onChanged: (bool? value) {
                                                      controller.permissionList[index].isView = value ?? false;
                                                      controller.permissionList.refresh();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            if (controller.permissionList[index].isAdd != null)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                                                      fontFamily: AppThemeData.medium,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: controller.permissionList[index].isAdd,
                                                    activeColor: AppThemeData.secondary300, // Color when checked
                                                    checkColor: Colors.white, // Tick color
                                                    onChanged: (bool? value) {
                                                      controller.permissionList[index].isView = true;
                                                      controller.permissionList[index].isAdd = value ?? false;
                                                      controller.permissionList.refresh();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            // if (controller.permissionList[index].isAdd != null)
                                            //   Row(
                                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //     children: [
                                            //       Text(
                                            //         'Edit',
                                            //         style: TextStyle(
                                            //           fontSize: 16,
                                            //           color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                                            //           fontFamily: AppThemeData.medium,
                                            //           fontWeight: FontWeight.w600,
                                            //         ),
                                            //       ),
                                            //       Checkbox(
                                            //         value: controller.permissionList[index].isAdd,
                                            //         activeColor: AppThemeData.secondary300, // Color when checked
                                            //         checkColor: Colors.white, // Tick color
                                            //         onChanged: (bool? value) {
                                            //           controller.permissionList[index].isView = true;
                                            //           controller.permissionList[index].isAdd = value ?? false;
                                            //           controller.permissionList.refresh();
                                            //         },
                                            //       ),
                                            //     ],
                                            //   ),
                                            if (controller.permissionList[index].isDelete != null)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                                                      fontFamily: AppThemeData.medium,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Checkbox(
                                                    value: controller.permissionList[index].isDelete,
                                                    activeColor: AppThemeData.secondary300, // Color when checked
                                                    checkColor: Colors.white, // Tick color
                                                    onChanged: (bool? value) {
                                                      controller.permissionList[index].isView = true;
                                                      controller.permissionList[index].isDelete = value ?? false;
                                                      controller.permissionList.refresh();
                                                    },
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RoundedButtonFill(
                  title: "Save Role".tr,
                  height: 5.5,
                  color: AppThemeData.secondary300,
                  textColor: AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: () async {
                    controller.saveEmployeeRole();
                  },
                )),
          ),
        );
      },
    );
  }

  bool isAllPermissionsSelected(PermissionModel p) {
    return [p.isAdd, p.isView, p.isDelete]
        .where((e) => e != null) // ignore nulls
        .every((e) => e == true);
  }
}
