import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/auth_screen/signup_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/service/supabase_auth_service.dart';

class OtpController extends GetxController {
  RxString phoneNumber = ''.obs;
  RxString countryCode = ''.obs;
  RxBool isLoading = false.obs;
  Rx<TextEditingController> otpController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    // Get phone number passed from PhoneNumberScreen
    final args = Get.arguments;
    if (args != null) {
      phoneNumber.value = args['phoneNumber'] ?? '';
      countryCode.value = args['countryCode'] ?? '+235';
    }
    sendOTP();
  }

  // ─── Send OTP ──────────────────────────────────────────────

  Future<void> sendOTP() async {
    try {
      isLoading.value = true;
      await SupabaseAuthService.sendOTP(
        phoneNumber: phoneNumber.value,
        countryCode: countryCode.value,
      );
      isLoading.value = false;
      ShowToastDialog.showToast('OTP sent successfully!'.tr);
    } catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast('Failed to send OTP. Try again.'.tr);
    }
  }

  // ─── Verify OTP ────────────────────────────────────────────

  Future<void> verifyOTP() async {
    if (otpController.value.text.length != 6) {
      ShowToastDialog.showToast('Enter valid OTP'.tr);
      return;
    }

    try {
      ShowToastDialog.showLoader('Verifying OTP...'.tr);

      final response = await SupabaseAuthService.verifyOTP(
        phoneNumber: phoneNumber.value,
        countryCode: countryCode.value,
        otp: otpController.value.text.trim(),
      );

      ShowToastDialog.closeLoader();

      if (response.user != null) {
        // Check if user profile exists
        final profile =
            await SupabaseAuthService.getUserProfile(response.user!.id);

        if (profile == null) {
          // New user — go to signup
          Get.off(const SignupScreen(), arguments: {
            'type': 'mobileNumber',
            'phoneNumber': phoneNumber.value,
            'countryCode': countryCode.value,
            'userId': response.user!.id,
          });
        } else {
          // Existing user — go to dashboard
          if (profile['active'] == false) {
            ShowToastDialog.showToast(
                'This user is disabled. Contact administrator.'.tr);
            await SupabaseAuthService.signOut();
            return;
          }
          Get.offAll(const DashBoardScreen());
        }
      } else {
        ShowToastDialog.showToast('Invalid OTP. Try again.'.tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Invalid OTP. Try again.'.tr);
    }
  }
}
