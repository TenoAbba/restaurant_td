import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/zone_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class AddDriverController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> firstNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;
  RxBool passwordVisible = true.obs;
  Rx<TextEditingController> conformPasswordEditingController =
      TextEditingController().obs;
  RxBool conformPasswordVisible = true.obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  //

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        zoneList.value = value;
      }
    });
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      driverModel.value = argumentData['driverModel'];
      if (driverModel.value.id != null) {
        firstNameEditingController.value.text =
            driverModel.value.firstName ?? '';
        lastNameEditingController.value.text = driverModel.value.lastName ?? '';
        emailEditingController.value.text = driverModel.value.email ?? '';
        phoneNUmberEditingController.value.text =
            driverModel.value.phoneNumber ?? '';
        countryCodeEditingController.value.text =
            driverModel.value.countryCode ?? '';

        if (driverModel.value.zoneId != null) {
          selectedZone.value = zoneList.firstWhere(
            (zone) => driverModel.value.zoneId == zone.id,
            orElse: () => ZoneModel(),
          );
        }
      }
    }
    isLoading.value = false;
  }

  signUpWithEmailAndPassword() async {
    signUp();
  }

  Rx<UserModel> driverModel = UserModel().obs;
  signUp() async {
    ShowToastDialog.showLoader("Please wait".tr);

    try {
      if (driverModel.value.id != null && driverModel.value.id != '') {
        log(":::::111:::::::");
        driverModel.value.firstName =
            firstNameEditingController.value.text.trim();
        driverModel.value.lastName =
            lastNameEditingController.value.text.trim();
        driverModel.value.email = emailEditingController.value.text.trim();
        driverModel.value.phoneNumber =
            phoneNUmberEditingController.value.text.trim();
        driverModel.value.countryCode =
            countryCodeEditingController.value.text.trim();
        driverModel.value.zoneId = selectedZone.value.id;
      } else {
        final authResp = await Supabase.instance.client.auth.admin.createUser(
          AdminUserAttributes(
            email: emailEditingController.value.text.trim(),
            password: passwordEditingController.value.text.trim(),
          ),
        );

        if (authResp.user != null) {
          driverModel.value.firstName =
              firstNameEditingController.value.text.trim();
          driverModel.value.lastName =
              lastNameEditingController.value.text.trim();
          driverModel.value.email =
              emailEditingController.value.text.trim().toLowerCase();
          driverModel.value.phoneNumber =
              phoneNUmberEditingController.value.text.trim();
          driverModel.value.role = Constant.userRoleDriver;
          driverModel.value.fcmToken = '';
          driverModel.value.active = true;
          driverModel.value.isDocumentVerify = true;
          driverModel.value.countryCode =
              countryCodeEditingController.value.text.trim();
          driverModel.value.createdAt = DateTime.now();
          driverModel.value.zoneId = selectedZone.value.id;
          driverModel.value.appIdentifier =
              Platform.isAndroid ? 'android' : 'ios';
          driverModel.value.provider = 'email';
          driverModel.value.vendorID = Constant.userModel?.vendorID;
          driverModel.value.id = authResp.user!.id;
        } else {
          ShowToastDialog.showToast("Something went to wrong".tr);
          return null;
        }
      }
      await FireStoreUtils.updateUser(driverModel.value).then(
        (value) async {
          if (value == true) {
            Get.back(result: true);
            ShowToastDialog.showToast(
                "Delivery man details saved successfully!".tr);
          } else {
            ShowToastDialog.showToast("Something went to wrong".tr);
          }
        },
      );
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }

    ShowToastDialog.closeLoader();
  }
}
