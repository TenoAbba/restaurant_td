import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_td/app/auth_screen/login_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/app/help_support_screen/help_support_screen.dart';
import 'package:restaurant_td/app/on_boarding_screen.dart';
import 'package:restaurant_td/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/preferences.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  /// True when the vendor must be sent to the subscription screen.
  ///
  /// The subscription feature is currently postponed
  /// (`Constant.isSubscriptionFeatureEnabled == false`), so this always returns
  /// false and vendors go straight to the dashboard.
  ///
  /// When the feature is switched back on, the remaining logic applies: a
  /// missing AdminCommission row is treated as "commission disabled" rather
  /// than "subscription required" (the old code required
  /// `adminCommission != null` to reach the dashboard, so a cold start that
  /// evaluated this before the settings had loaded trapped every vendor on the
  /// subscription screen). `redirectScreen()` also awaits the settings first.
  bool _isSubscriptionRequired() {
    if (!Constant.isSubscriptionFeatureEnabled) return false;
    final bool commissionEnabled = Constant.adminCommission?.isEnabled == true;
    return commissionEnabled || Constant.isSubscriptionModelApplied == true;
  }

  Future<void> redirectScreen() async {
    // Make sure the global settings (AdminCommission / subscription_model) are
    // loaded before any gating decision is made.
    await FireStoreUtils.ensureSettingsLoaded();

    if (Preferences.getBoolean(Preferences.isClickOnNotification) != true) {
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(const OnBoardingScreen());
      } else {
        bool isLogin = await FireStoreUtils.isLogin();
        if (isLogin == true) {
          await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
              .then((value) async {
            if (value != null) {
              Constant.userModel = value;
              if (Constant.userModel?.role == Constant.userRoleVendor) {
                if (Constant.userModel?.active == true) {
                  await FireStoreUtils.updateUser(Constant.userModel!);

                  // Subscriptions are postponed: skip every plan/feature check
                  // and go straight to the dashboard. Without this a vendor
                  // whose plan lacks `restaurantMobileApp` would be dumped on
                  // AppNotAccessScreen, which is just as inescapable as the
                  // subscription screen was.
                  if (!Constant.isSubscriptionFeatureEnabled) {
                    Get.offAll(const DashBoardScreen());
                    return;
                  }

                  bool isPlanExpire = false;

                  if (Constant.userModel?.subscriptionPlan?.id != null) {
                    if (Constant.userModel?.subscriptionExpiryDate == null) {
                      if (Constant.userModel?.subscriptionPlan?.expiryDay ==
                          '-1') {
                        isPlanExpire = false;
                      } else {
                        isPlanExpire = true;
                      }
                    } else {
                      DateTime expiryDate =
                          Constant.userModel!.subscriptionExpiryDate!;
                      isPlanExpire = expiryDate.isBefore(DateTime.now());
                    }
                  } else {
                    isPlanExpire = true;
                  }
                  if (Constant.userModel?.subscriptionPlanId == null ||
                      isPlanExpire == true) {
                    if (_isSubscriptionRequired()) {
                      Get.offAll(const SubscriptionPlanScreen());
                    } else {
                      Get.offAll(const DashBoardScreen());
                    }
                  } else if (Constant.userModel?.subscriptionPlan?.features
                          ?.restaurantMobileApp ==
                      true) {
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const AppNotAccessScreen());
                  }
                } else {
                  await Supabase.instance.client.auth.signOut();
                  Get.offAll(const LoginScreen());
                }
              } else if (Constant.userModel?.role ==
                  Constant.userRoleEmployee) {
                if (Constant.userModel?.active == true) {
                  await FireStoreUtils.updateUser(Constant.userModel!);

                  // Subscriptions are postponed — see the vendor branch above.
                  if (!Constant.isSubscriptionFeatureEnabled) {
                    Get.offAll(const DashBoardScreen());
                    return;
                  }

                  VendorModel? vendor = await FireStoreUtils.getVendorById(
                      Constant.userModel!.vendorID!);
                  bool isPlanExpire = false;

                  if (vendor?.subscriptionPlan?.id != null) {
                    if (vendor?.subscriptionExpiryDate == null) {
                      if (vendor?.subscriptionPlan?.expiryDay == '-1') {
                        isPlanExpire = false;
                      } else {
                        isPlanExpire = true;
                      }
                    } else {
                      DateTime expiryDate = vendor!.subscriptionExpiryDate!;
                      isPlanExpire = expiryDate.isBefore(DateTime.now());
                    }
                  } else {
                    isPlanExpire = true;
                  }
                  if (vendor?.subscriptionPlanId == null ||
                      isPlanExpire == true) {
                    // NOTE: employees cannot purchase a subscription — that is
                    // the restaurant owner's job — so when the vendor's plan is
                    // missing/expired we show AppNotAccessScreen instead of the
                    // subscription screen. Previously this branch had no `else`,
                    // so an employee whose vendor plan had lapsed was left
                    // stranded on the splash screen with no navigation at all.
                    if (!_isSubscriptionRequired()) {
                      Get.offAll(const DashBoardScreen());
                    } else {
                      Get.offAll(const AppNotAccessScreen());
                    }
                  } else if (vendor!
                          .subscriptionPlan?.features?.restaurantMobileApp ==
                      true) {
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const AppNotAccessScreen());
                  }
                } else {
                  await Supabase.instance.client.auth.signOut();
                  Get.offAll(const LoginScreen());
                }
              } else {
                await Supabase.instance.client.auth.signOut();
                Get.offAll(const LoginScreen());
              }
            }
          });
        } else {
          await Supabase.instance.client.auth.signOut();
          Get.offAll(const LoginScreen());
        }
      }
    } else {
      Get.to(HelpSupportScreen(isNavigateViaNotification: true));
    }
  }
}
