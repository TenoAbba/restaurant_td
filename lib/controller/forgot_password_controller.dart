import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;

  forgotPassword() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      await Supabase.instance.client.auth
          .resetPasswordForEmail(emailEditingController.value.text);
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          '${'Reset Password link sent your'.tr} ${emailEditingController.value.text} ${'email'.tr}');
      Get.back();
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }
}
