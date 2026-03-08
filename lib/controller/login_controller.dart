import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/auth_screen/signup_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/main.dart';
import 'package:restaurant_td/service/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  // Tab selection
  RxInt selectedTabbar = 0.obs;

  // Owner login fields
  Rx<TextEditingController> emailEditingControllerOwner =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingControllerOwner =
      TextEditingController().obs;

  // Employee login fields
  RxString email = ''.obs;
  RxString password = ''.obs;
  RxBool passwordVisible = true.obs;

  Rx<TextEditingController> emailEditingControllerEmployee =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingControllerEmployee =
      TextEditingController().obs;

  // ─── Employee Login ────────────────────────────────────────

  Future<void> employeeloginWithEmailAndPassword() async {
    try {
      ShowToastDialog.showLoader('Logging in...'.tr);

      final response = await SupabaseAuthService.loginWithEmail(
        email: emailEditingControllerEmployee.value.text.trim(),
        password: passwordEditingControllerEmployee.value.text.trim(),
      );

      ShowToastDialog.closeLoader();

      if (response.user != null) {
        final profile =
            await SupabaseAuthService.getUserProfile(response.user!.id);

        if (profile == null) {
          ShowToastDialog.showToast('User profile not found.'.tr);
          return;
        }

        if (profile['active'] == false) {
          ShowToastDialog.showToast(
              'This user is disabled. Please contact administrator.'.tr);
          await SupabaseAuthService.signOut();
          return;
        }

        Get.offAll(const DashBoardScreen());
      } else {
        ShowToastDialog.showToast('Login failed. Please try again.'.tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Invalid email or password.'.tr);
    }
  }

  // ─── Google Login ──────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    try {
      ShowToastDialog.showLoader('Connecting to Google...'.tr);
      await SupabaseAuthService.loginWithGoogle();
      ShowToastDialog.closeLoader();

      final user = SupabaseAuthService.getCurrentUser();
      if (user != null) {
        final profile = await SupabaseAuthService.getUserProfile(user.id);
        if (profile == null) {
          // New user — go to signup
          Get.to(const SignupScreen(), arguments: {
            'type': 'google',
            'email': user.email,
          });
        } else {
          Get.offAll(const DashBoardScreen());
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Google login failed. Try again.'.tr);
    }
  }

  // ─── Owner Login ───────────────────────────────────────────

  Future<void> onwerloginWithEmailAndPassword() async {
    try {
      ShowToastDialog.showLoader('Logging in...'.tr);

      final response = await SupabaseAuthService.loginWithEmail(
        email: emailEditingControllerOwner.value.text.trim(),
        password: passwordEditingControllerOwner.value.text.trim(),
      );

      ShowToastDialog.closeLoader();

      if (response.user != null) {
        final profile =
            await SupabaseAuthService.getUserProfile(response.user!.id);

        if (profile == null) {
          ShowToastDialog.showToast('User profile not found.'.tr);
          return;
        }

        if (profile['role'] != 'vendor') {
          ShowToastDialog.showToast('This user is not an owner.'.tr);
          await SupabaseAuthService.signOut();
          return;
        }

        if (profile['active'] == false) {
          ShowToastDialog.showToast(
              'This user is disabled. Please contact administrator.'.tr);
          await SupabaseAuthService.signOut();
          return;
        }

        Get.offAll(const DashBoardScreen());
      } else {
        ShowToastDialog.showToast('Login failed. Please try again.'.tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Invalid email or password.'.tr);
    }
  }

  // ─── Apple Login ───────────────────────────────────────────

  Future<void> loginWithApple() async {
    try {
      ShowToastDialog.showLoader('Connecting to Apple...'.tr);
      // Supabase Apple OAuth
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.restauranttd://login-callback/',
      );
      ShowToastDialog.closeLoader();
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Apple login failed. Try again.'.tr);
    }
  }
}
