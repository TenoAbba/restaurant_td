import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/auth_screen/otp_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;

  sendCode() async {
    ShowToastDialog.showLoader("please wait...".tr);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: countryCodeEditingController.value.text + phoneNUmberEditingController.value.text,
      );
      ShowToastDialog.closeLoader();
      Get.to(const OtpScreen(), arguments: {
        "countryCode": countryCodeEditingController.value.text,
        "phoneNumber": phoneNUmberEditingController.value.text,
        "verificationId": "",
      });
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Failed to send OTP. Please try again.".tr);
    }
  }
}
