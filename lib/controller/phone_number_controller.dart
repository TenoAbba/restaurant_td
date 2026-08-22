import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/auth_screen/otp_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/utils/auth_error_handler.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;

  /// Prevents repeated taps, which would send several SMS codes and hit
  /// Supabase's SMS rate limit (HTTP 429).
  RxBool isSending = false.obs;

  Future<void> sendCode() async {
    if (isSending.value) return;

    isSending.value = true;
    ShowToastDialog.showLoader("please wait...".tr);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: countryCodeEditingController.value.text +
            phoneNUmberEditingController.value.text,
      );
      ShowToastDialog.closeLoader();
      Get.to(const OtpScreen(), arguments: {
        "countryCode": countryCodeEditingController.value.text,
        "phoneNumber": phoneNUmberEditingController.value.text,
        "verificationId": "",
      });
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
