import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/employee_role_model.dart';
import 'package:restaurant_td/models/permission_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class AddEditRoleController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> nameController = TextEditingController().obs;
  RxList<PermissionModel> permissionList = <PermissionModel>[].obs;
  RxBool isActive = true.obs;
  Rx<EmployeeRoleModel> employeeRoleModel = EmployeeRoleModel().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  RxList images = <dynamic>[].obs;

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      employeeRoleModel.value = argumentData['employeeRoleModel'];
      isActive.value = employeeRoleModel.value.isEnable ?? false;
      permissionList.value = employeeRoleModel.value.permissions ?? [];
      nameController.value.text = employeeRoleModel.value.title ?? '';
    } else {
      permissionList.value = Constant.permissionList;
    }
    isLoading.value = false;
  }

  Future<void> saveEmployeeRole() async {
    if (nameController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter role name".tr);
    } else {
      ShowToastDialog.showLoader("Please wait".tr);
      if (employeeRoleModel.value.id == null) {
        employeeRoleModel.value.id = Constant.getUuid();
      }
      employeeRoleModel.value.title = nameController.value.text.trim().toUpperCase();
      employeeRoleModel.value.isEnable = isActive.value;
      employeeRoleModel.value.permissions = permissionList;
      employeeRoleModel.value.vendorId = Constant.userModel?.vendorID;
      await FireStoreUtils.setEmployeeRole(employeeRoleModel.value).then(
        (value) {
          ShowToastDialog.closeLoader();
          Get.back(result: true);
        },
      );
    }
  }
}
