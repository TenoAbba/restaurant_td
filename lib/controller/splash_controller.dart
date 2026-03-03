import 'dart:async';
import 'package:restaurant_td/app/auth_screen/login_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant_td/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant_td/app/help_support_screen/help_support_screen.dart';
import 'package:restaurant_td/app/on_boarding_screen.dart';
import 'package:restaurant_td/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/notification_service.dart';
import 'package:restaurant_td/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
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
                  Constant.userModel?.fcmToken =
                      await NotificationService.getToken();
                  await FireStoreUtils.updateUser(Constant.userModel!);
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
                          Constant.userModel!.subscriptionExpiryDate!.toDate();
                      isPlanExpire = expiryDate.isBefore(DateTime.now());
                    }
                  } else {
                    isPlanExpire = true;
                  }
                  if (Constant.userModel?.subscriptionPlanId == null ||
                      isPlanExpire == true) {
                    if (Constant.adminCommission != null &&
                        Constant.adminCommission?.isEnabled == false &&
                        Constant.isSubscriptionModelApplied == false) {
                      Get.offAll(const DashBoardScreen());
                    } else {
                      Get.offAll(const SubscriptionPlanScreen());
                    }
                  } else if (Constant.userModel?.subscriptionPlan?.features
                          ?.restaurantMobileApp ==
                      true) {
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const AppNotAccessScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(const LoginScreen());
                }
              } else if (Constant.userModel?.role ==
                  Constant.userRoleEmployee) {
                if (Constant.userModel?.active == true) {
                  Constant.userModel?.fcmToken =
                      await NotificationService.getToken();
                  await FireStoreUtils.updateUser(Constant.userModel!);
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
                      DateTime expiryDate =
                          vendor!.subscriptionExpiryDate!.toDate();
                      isPlanExpire = expiryDate.isBefore(DateTime.now());
                    }
                  } else {
                    isPlanExpire = true;
                  }
                  if (vendor?.subscriptionPlanId == null ||
                      isPlanExpire == true) {
                    if (Constant.adminCommission?.isEnabled == false &&
                        Constant.isSubscriptionModelApplied == false) {
                      Get.offAll(const DashBoardScreen());
                    }
                  } else if (vendor!
                          .subscriptionPlan?.features?.restaurantMobileApp ==
                      true) {
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const AppNotAccessScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(const LoginScreen());
                }
              } else {
                await FirebaseAuth.instance.signOut();
                Get.offAll(const LoginScreen());
              }
            }
          });
        } else {
          await FirebaseAuth.instance.signOut();
          Get.offAll(const LoginScreen());
        }
      }
    } else {
      Get.to(HelpSupportScreen(isNavigateViaNotification: true));
    }
  }
}
