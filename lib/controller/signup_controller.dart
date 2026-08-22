import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/auth_screen/login_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/service/supabase_auth_service.dart';
import 'package:restaurant_td/utils/auth_error_handler.dart';

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

  /// Guards against double taps on the Signup button. Each extra tap fires
  /// another confirmation e-mail and is what triggers Supabase's
  /// "email rate limit exceeded" (HTTP 429) response.
  RxBool isSigningUp = false.obs;

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
    // Ignore taps while a signup request is already in flight.
    if (isSigningUp.value) return;

    final email = emailEditingController.value.text.trim();
    final password = passwordEditingController.value.text.trim();
    final isSocialOrPhone = type.value == 'mobileNumber' ||
        type.value == 'google' ||
        type.value == 'apple';

    if (!GetUtils.isEmail(email)) {
      ShowToastDialog.showToast('Please enter a valid e-mail address.'.tr);
      return;
    }

    if (!isSocialOrPhone && password.length < 6) {
      ShowToastDialog.showToast(
          'Password must be at least 6 characters long.'.tr);
      return;
    }

    isSigningUp.value = true;

    try {
      ShowToastDialog.showLoader('Creating account...'.tr);

      String uid = userId.value;
      bool needsEmailConfirmation = false;

      // If not coming from phone/google/apple — create new auth user
      if (!isSocialOrPhone) {
        final response = await SupabaseAuthService.signUpWithEmail(
          email: email,
          password: password,
        );

        if (response.user == null) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast('Signup failed. Please try again.'.tr);
          return;
        }

        uid = response.user!.id;
        needsEmailConfirmation =
            AuthErrorHandler.needsEmailConfirmation(response);
      }

      // Save user profile to database
      await SupabaseAuthService.saveUserProfile(
        id: uid,
        firstName: firstNameEditingController.value.text.trim(),
        lastName: lastNameEditingController.value.text.trim(),
        email: email,
        phoneNumber: phoneNUmberEditingController.value.text.trim(),
        countryCode: countryCodeEditingController.value.text.trim(),
        role: 'vendor',
      );

      ShowToastDialog.closeLoader();

      if (needsEmailConfirmation) {
        // Supabase created the account but no session was returned because
        // "Confirm email" is enabled in the project's auth settings.
        ShowToastDialog.showToastDuration(
          'Account created. Please confirm your e-mail address, then sign in.'
              .tr,
          duration: const Duration(seconds: 4),
        );
        Get.offAll(const LoginScreen());
        return;
      }

      Get.offAll(const DashBoardScreen());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToastDuration(
        AuthErrorHandler.getMessage(e),
        duration: Duration(seconds: AuthErrorHandler.isRateLimit(e) ? 5 : 3),
      );
    } finally {
      isSigningUp.value = false;
    }
  }
}
