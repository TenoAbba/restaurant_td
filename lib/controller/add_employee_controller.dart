import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/employee_role_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class AddEmployeeController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> firstNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;
  RxBool passwordVisible = true.obs;
  Rx<TextEditingController> conformPasswordEditingController = TextEditingController().obs;
  RxBool conformPasswordVisible = true.obs;

  //

  @override
  void onInit() {
    getAllEmployeeRoles();
    super.onInit();
  }

  RxList<EmployeeRoleModel> employeeRolelList = <EmployeeRoleModel>[].obs;
  Rx<EmployeeRoleModel> selectEmployeeRole = EmployeeRoleModel().obs;

  Future<void> getAllEmployeeRoles() async {
    await FireStoreUtils.getAllEmployeeRoles(isActive: true).then(
      (value) {
        employeeRolelList.value = value;
      },
    );
    getArgument();
    isLoading.value = false;
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      employeeModel.value = argumentData['employeemodel'];
      if (employeeModel.value.id != null) {
        firstNameEditingController.value.text = employeeModel.value.firstName ?? '';
        lastNameEditingController.value.text = employeeModel.value.lastName ?? '';
        emailEditingController.value.text = employeeModel.value.email ?? '';
        phoneNUmberEditingController.value.text = employeeModel.value.phoneNumber ?? '';
        countryCodeEditingController.value.text = employeeModel.value.countryCode ?? '';
        selectEmployeeRole.value = employeeRolelList.firstWhere(
          (role) => role.id == employeeModel.value.employeePermissionId,
          orElse: () => EmployeeRoleModel(),
        );
      }
    }
    isLoading.value = false;
  }

  Future<void> signUpWithEmailAndPassword() async {
    signUp();
  }

  Rx<UserModel> employeeModel = UserModel().obs;
  Future<Null> signUp() async {
    ShowToastDialog.showLoader("Please wait".tr);

    try {
      if (employeeModel.value.id != null && employeeModel.value.id != '') {
        employeeModel.value.firstName = firstNameEditingController.value.text.trim();
        employeeModel.value.lastName = lastNameEditingController.value.text.trim();
        employeeModel.value.employeePermissionId = selectEmployeeRole.value.id;
        employeeModel.value.email = emailEditingController.value.text.trim();
        employeeModel.value.phoneNumber = phoneNUmberEditingController.value.text.trim();
        employeeModel.value.countryCode = countryCodeEditingController.value.text.trim();
      } else {
                final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );

        if (authResp.user != null) {
          employeeModel.value.firstName = firstNameEditingController.value.text.trim();
          employeeModel.value.lastName = lastNameEditingController.value.text.trim();
          employeeModel.value.employeePermissionId = selectEmployeeRole.value.id;
          employeeModel.value.email = emailEditingController.value.text.trim().toLowerCase();
          employeeModel.value.phoneNumber = phoneNUmberEditingController.value.text.trim();
          employeeModel.value.role = Constant.userRoleEmployee;
          employeeModel.value.fcmToken = '';
          employeeModel.value.active = true;
          employeeModel.value.isDocumentVerify = true;
          employeeModel.value.countryCode = countryCodeEditingController.value.text.trim();
          employeeModel.value.createdAt = DateTime.now();
          employeeModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
          employeeModel.value.provider = 'email';
          employeeModel.value.vendorID = Constant.userModel?.vendorID;
          employeeModel.value.id = authResp.user?.id;
        } else {
          ShowToastDialog.showToast("Something went to wrong".tr);
          return null;
        }
              }
      await FireStoreUtils.updateUser(employeeModel.value).then(
        (value) async {
          if (value == true) {
            Get.back(result: true);
            ShowToastDialog.showToast("Employee details saved successfully!".tr);
          } else {
            ShowToastDialog.showToast("Something went to wrong".tr);
          }
        },
      );
    } catch (e) {
      } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }

    ShowToastDialog.closeLoader();
  }
}
