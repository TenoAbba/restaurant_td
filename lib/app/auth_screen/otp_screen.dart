import 'package:restaurant_td/app/auth_screen/signup_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/controller/otp_controller.dart';
import 'package:restaurant_td/service/supabase_auth_service.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verify Your Number 📱".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 22,
                                fontFamily: AppThemeData.semiBold),
                          ),
                          Text(
                            "${'Enter the OTP sent to your mobile number.'.tr} ${controller.countryCode.value} ${Constant.maskingString(controller.phoneNumber.value, 3)}"
                                .tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey200
                                  : AppThemeData.grey700,
                              fontSize: 16,
                              fontFamily: AppThemeData.regular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: PinCodeTextField(
                              length: 6,
                              appContext: context,
                              keyboardType: TextInputType.phone,
                              enablePinAutofill: true,
                              hintCharacter: "-",
                              hintStyle: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey500
                                      : AppThemeData.grey400,
                                  fontFamily: AppThemeData.regular),
                              textStyle: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontFamily: AppThemeData.regular),
                              pinTheme: PinTheme(
                                  fieldHeight: 50,
                                  fieldWidth: 50,
                                  inactiveFillColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  selectedFillColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  activeFillColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  selectedColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  activeColor: themeChange.getThem()
                                      ? AppThemeData.secondary300
                                      : AppThemeData.secondary300,
                                  inactiveColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  disabledColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: PinCodeFieldShape.box,
                                  errorBorderColor: themeChange.getThem()
                                      ? AppThemeData.grey600
                                      : AppThemeData.grey300,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              cursorColor: AppThemeData.secondary300,
                              enableActiveFill: true,
                              controller: controller.otpController.value,
                              onCompleted: (v) async {},
                              onChanged: (value) {},
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          RoundedButtonFill(
                            title: "Verify & Next".tr,
                            color: AppThemeData.secondary300,
                            textColor: AppThemeData.grey50,
                            onPress: () async {
                              if (controller.otpController.value.text.length ==
                                  6) {
                                ShowToastDialog.showLoader(
                                    "Verifying OTP...".tr);

                                try {
                                  final response =
                                      await SupabaseAuthService.verifyOTP(
                                    phoneNumber: controller.phoneNumber.value,
                                    countryCode: controller.countryCode.value,
                                    otp: controller.otpController.value.text
                                        .trim(),
                                  );

                                  ShowToastDialog.closeLoader();

                                  if (response.user != null) {
                                    // Check if user profile exists
                                    final profile = await SupabaseAuthService
                                        .getUserProfile(response.user!.id);

                                    if (profile == null) {
                                      // New user — go to signup
                                      Get.off(const SignupScreen(), arguments: {
                                        'type': 'mobileNumber',
                                        'phoneNumber':
                                            controller.phoneNumber.value,
                                        'countryCode':
                                            controller.countryCode.value,
                                        'userId': response.user!.id,
                                      });
                                    } else {
                                      // Existing user — check role and active status
                                      if (profile['role'] != 'vendor') {
                                        ShowToastDialog.showToast(
                                            'This user is not an owner.'.tr);
                                        await SupabaseAuthService.signOut();
                                        return;
                                      }

                                      if (profile['active'] == false) {
                                        ShowToastDialog.showToast(
                                            'This user is disabled. Please contact administrator.'
                                                .tr);
                                        await SupabaseAuthService.signOut();
                                        return;
                                      }

                                      // The subscription feature is postponed,
                                      // so skip the plan checks and send the
                                      // vendor straight to the dashboard. The
                                      // gated branch below is kept intact so
                                      // flipping the flag restores the flow.
                                      if (!Constant
                                          .isSubscriptionFeatureEnabled) {
                                        Get.offAll(const DashBoardScreen());
                                        return;
                                      }

                                      // Determine whether the vendor's plan has
                                      // lapsed. `expiry_day == '-1'` means a
                                      // lifetime plan, so it never expires.
                                      bool isPlanExpire;
                                      if (profile['subscription_plan_id'] ==
                                          null) {
                                        isPlanExpire = true;
                                      } else {
                                        final rawExpiry =
                                            profile['subscription_expiry_date'];
                                        if (rawExpiry == null) {
                                          isPlanExpire =
                                              profile['subscription_expiry_day']
                                                      ?.toString() !=
                                                  '-1';
                                        } else {
                                          // Supabase returns timestamps as ISO
                                          // strings, so parse defensively
                                          // rather than casting to DateTime.
                                          final expiryDate =
                                              rawExpiry is DateTime
                                                  ? rawExpiry
                                                  : DateTime.tryParse(
                                                      rawExpiry.toString());
                                          isPlanExpire = expiryDate == null ||
                                              expiryDate
                                                  .isBefore(DateTime.now());
                                        }
                                      }

                                      if (isPlanExpire) {
                                        final bool subscriptionRequired = Constant
                                                    .adminCommission
                                                    ?.isEnabled ==
                                                true ||
                                            Constant.isSubscriptionModelApplied ==
                                                true;
                                        if (subscriptionRequired) {
                                          Get.offAll(
                                              const SubscriptionPlanScreen());
                                        } else {
                                          Get.offAll(const DashBoardScreen());
                                        }
                                      } else if (profile[
                                              'restaurant_mobile_app'] ==
                                          true) {
                                        Get.offAll(const DashBoardScreen());
                                      } else {
                                        Get.offAll(const AppNotAccessScreen());
                                      }
                                    }
                                  } else {
                                    ShowToastDialog.showToast(
                                        'Invalid OTP. Try again.'.tr);
                                  }
                                } catch (e) {
                                  ShowToastDialog.closeLoader();
                                  ShowToastDialog.showToast(
                                      'Invalid OTP. Try again.'.tr);
                                }
                              } else {
                                ShowToastDialog.showToast("Enter Valid OTP".tr);
                              }
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text.rich(
                            textAlign: TextAlign.start,
                            TextSpan(
                              text: "${'Did’t receive any code? '.tr} ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                fontFamily: AppThemeData.medium,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.otpController.value.clear();
                                      controller.sendOTP();
                                    },
                                  text: 'Send Again'.tr,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.secondary300
                                          : AppThemeData.secondary300,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.medium,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          AppThemeData.secondary300),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
