import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/service/supabase_auth_service.dart';

class SignupController extends GetxController {
  Rx<TextEditingController> firstNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController(text: '+235').obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> conformPasswordEditingController =
      TextEditingController().obs;

  RxBool passwordVisible = true.obs;
  RxBool conformPasswordVisible = true.obs;
  RxString type = ''.obs;
  RxString userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      type.value = args['type'] ?? '';
      userId.value = args['userId'] ?? '';
      // Pre-fill fields if coming from Google/Apple/Phone
      emailEditingController.value.text = args['email'] ?? '';
      phoneNUmberEditingController.value.text = args['phoneNumber'] ?? '';
      countryCodeEditingController.value.text = args['countryCode'] ?? '+235';
    }
  }

  // ─── Sign Up ───────────────────────────────────────────────

  Future<void> signUpWithEmailAndPassword() async {
    try {
      ShowToastDialog.showLoader('Creating account...'.tr);

      String uid = userId.value;

      // If not coming from phone/google/apple — create new auth user
      if (type.value != 'mobileNumber' &&
          type.value != 'google' &&
          type.value != 'apple') {
        final response = await SupabaseAuthService.signUpWithEmail(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );
        if (response.user == null) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast('Signup failed. Try again.'.tr);
          return;
        }
        uid = response.user!.id;
      }

      // Save user profile to database
      await SupabaseAuthService.saveUserProfile(
        id: uid,
        firstName: firstNameEditingController.value.text.trim(),
        lastName: lastNameEditingController.value.text.trim(),
        email: emailEditingController.value.text.trim(),
        phoneNumber: phoneNUmberEditingController.value.text.trim(),
        countryCode: countryCodeEditingController.value.text.trim(),
        role: 'vendor',
      );

      ShowToastDialog.closeLoader();
      Get.offAll(const DashBoardScreen());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Signup failed: ${e.toString()}'.tr);
    }
  }
}
