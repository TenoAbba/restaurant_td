import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/utils/auth_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;

  /// Prevents repeated taps, which would send several reset e-mails and hit
  /// Supabase's e-mail rate limit (HTTP 429).
  RxBool isSending = false.obs;

  Future<void> forgotPassword() async {
    if (isSending.value) return;

    final email = emailEditingController.value.text.trim();
    if (!GetUtils.isEmail(email)) {
      ShowToastDialog.showToast('Please enter a valid e-mail address.'.tr);
      return;
    }

    isSending.value = true;
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          '${'Reset Password link sent your'.tr} $email ${'email'.tr}');
      Get.back();
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToastDuration(
        AuthErrorHandler.getMessage(e),
        duration: Duration(seconds: AuthErrorHandler.isRateLimit(e) ? 5 : 3),
      );
    } finally {
      isSending.value = false;
    }
  }
}
