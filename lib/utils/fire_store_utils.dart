import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:restaurant_td/app/chat_screens/ChatVideoContainer.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/AttributesModel.dart';
import 'package:restaurant_td/models/admin_commission.dart';
import 'package:restaurant_td/models/advertisement_model.dart';
import 'package:restaurant_td/models/conversation_model.dart';
import 'package:restaurant_td/models/dine_in_booking_model.dart';
import 'package:restaurant_td/models/document_model.dart';
import 'package:restaurant_td/models/driver_document_model.dart';
import 'package:restaurant_td/models/email_template_model.dart';
import 'package:restaurant_td/models/coupon_model.dart';
import 'package:restaurant_td/models/employee_role_model.dart';
import 'package:restaurant_td/models/inbox_model.dart';
import 'package:restaurant_td/models/mail_setting.dart';
import 'package:restaurant_td/models/notification_model.dart';
import 'package:restaurant_td/models/on_boarding_model.dart';
import 'package:restaurant_td/models/order_model.dart';
import 'package:restaurant_td/models/payment_model/cod_setting_model.dart';
import 'package:restaurant_td/models/payment_model/flutter_wave_model.dart';
import 'package:restaurant_td/models/payment_model/mercado_pago_model.dart';
import 'package:restaurant_td/models/payment_model/mid_trans.dart';
import 'package:restaurant_td/models/payment_model/orange_money.dart';
import 'package:restaurant_td/models/payment_model/pay_fast_model.dart';
import 'package:restaurant_td/models/payment_model/pay_stack_model.dart';
import 'package:restaurant_td/models/payment_model/paypal_model.dart';
import 'package:restaurant_td/models/payment_model/paytm_model.dart';
import 'package:restaurant_td/models/payment_model/razorpay_model.dart';
import 'package:restaurant_td/models/payment_model/stripe_model.dart';
import 'package:restaurant_td/models/payment_model/wallet_setting_model.dart';
import 'package:restaurant_td/models/payment_model/xendit.dart';
import 'package:restaurant_td/models/product_model.dart';
import 'package:restaurant_td/models/rating_model.dart';
import 'package:restaurant_td/models/referral_model.dart';
import 'package:restaurant_td/models/review_attribute_model.dart';
import 'package:restaurant_td/models/story_model.dart';
import 'package:restaurant_td/models/subscription_history.dart';
import 'package:restaurant_td/models/subscription_plan_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/vendor_category_model.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/models/wallet_transaction_model.dart';
import 'package:restaurant_td/models/withdraw_method_model.dart';
import 'package:restaurant_td/models/withdrawal_model.dart';
import 'package:restaurant_td/models/zone_model.dart';
import 'package:restaurant_td/service/audio_player_service.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) async {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
        Constant.userModel = userModel;
        if (userModel?.employeePermissionId != null) {
          Constant.employeeRoleModel = await FireStoreUtils.getEmployeeRoleById(
              userModel!.employeePermissionId!);
        }
      }
    });
    return userModel;
  }

  static Future<UserModel?> getUserById(String uuid) async {
    UserModel? userModel;
    log("uuid :: $uuid");
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    });
    return userModel;
  }

  static Future<bool?> updateUserWallet(
      {required String amount, required String userId}) async {
    bool isAdded = false;
    await getUserProfile(userId).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            ((userModel.walletAmount ?? 0.0) + double.parse(amount));
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    try {
      if (userModel.id == null || userModel.id!.isEmpty) {
        log("Error: User ID is null or empty in updateUser");
        return false;
      }

      await fireStore
          .collection(CollectionName.users)
          .doc(userModel.id)
          .update(userModel.toJson())
          .whenComplete(() async {
        Constant.userModel = userModel;
        if (userModel.employeePermissionId != null) {
          Constant.employeeRoleModel = await FireStoreUtils.getEmployeeRoleById(
              userModel.employeePermissionId!);
        }
        isUpdate = true;
      }).catchError((error) {
        log("Failed to update user: $error");
        isUpdate = false;
      });
    } catch (e) {
      log("Error updating user: $e");
      isUpdate = false;
    }
    return isUpdate;
  }

  static Future<bool> updateDriverUser(UserModel userModel) async {
    bool isUpdate = false;
    try {
      if (userModel.id == null || userModel.id!.isEmpty) {
        log("Error: User ID is null or empty in updateDriverUser");
        return false;
      }

      await fireStore
          .collection(CollectionName.users)
          .doc(userModel.id)
          .update(userModel.toJson())
          .whenComplete(() {
        isUpdate = true;
      }).catchError((error) {
        log("Failed to update user: $error");
        isUpdate = false;
      });
    } catch (e) {
      log("Error updating driver user: $e");
      isUpdate = false;
    }
    return isUpdate;
  }

  static Future<bool> withdrawWalletAmount(WithdrawalModel userModel) async {
    bool isUpdate = false;
    try {
      if (userModel.id == null || userModel.id!.isEmpty) {
        log("Error: Withdrawal ID is null or empty in withdrawWalletAmount");
        return false;
      }

      await fireStore
          .collection(CollectionName.payouts)
          .doc(userModel.id)
          .update(userModel.toJson())
          .whenComplete(() {
        isUpdate = true;
      }).catchError((error) {
        log("Failed to update payout: $error");
        isUpdate = false;
      });
    } catch (e) {
      log("Error updating wallet amount: $e");
      isUpdate = false;
    }
    return isUpdate;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore
        .collection(CollectionName.onBoarding)
        .where("type", isEqualTo: "restaurantApp")
        .get()
        .then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.wallet)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  Future<void> getSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("globalSettings")
          .get()
          .then((value) async {
        Constant.orderRingtoneUrl = value.data()?['order_ringtone_url'] ?? '';
        Preferences.setString(
            Preferences.orderRingtone, Constant.orderRingtoneUrl);
        AppThemeData.secondary300 = Color(int.parse(
            value.data()!['app_restaurant_color'].replaceFirst("#", "0xff")));
        Constant.isEnableAdsFeature =
            value.data()?['isEnableAdsFeature'] ?? false;
        Constant.isSelfDeliveryFeature =
            value.data()?['isSelfDelivery'] ?? false;
        Constant.apiSecureKey = value.data()?['apiSecureKey'] ?? "";
        Constant.apiBaseUrl = value.data()?['apiBaseUrl'] ?? "";
        if (Constant.orderRingtoneUrl.isNotEmpty) {
          await AudioPlayerService.initAudio();
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("DriverNearBy")
          .get()
          .then((event) {
        if (event.exists) {
          if (event.data()!["selectedMapType"].toString().isNotEmpty) {
            Constant.selectedMapType = event.data()!["selectedMapType"];
          }
          Constant.singleOrderReceive = event.data()!['singleOrderReceive'];
        }
      });

      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("scheduleOrderNotification")
          .get()
          .then((time) {
        if (time.exists) {
          Constant.scheduleOrderTime = time.data()!["notifyTime"];
          Constant.scheduleOrderTimeType = time.data()!["timeUnit"];
        }
      });

      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("DineinForRestaurant")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists) {
          Constant.isDineInEnable = dineinresult.data()!["isEnabled"];
        }
      });

      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc('restaurant')
          .get()
          .then((value) {
        Constant.autoApproveRestaurant =
            value.data()!['auto_approve_restaurant'];
        Constant.isSubscriptionModelApplied =
            value.data()!['subscription_model'];
      });

      await fireStore
          .collection(CollectionName.settings)
          .doc("AdminCommission")
          .get()
          .then((value) {
        if (value.data() != null) {
          Constant.adminCommission = AdminCommission.fromJson(value.data()!);
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("googleMapKey")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          if (event.data()!["key"].toString().isNotEmpty) {
            Constant.mapAPIKey = event.data()!["key"];
          }
          Constant.placeHolderImage = event.data()!["placeHolderImage"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('story')
          .get()
          .then((value) {
        Constant.storyEnable = value.data()!['isEnabled'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('placeHolderImage')
          .get()
          .then((value) {
        Constant.placeholderImage = value.data()!['image'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("Version")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.googlePlayLink = event.data()!["googlePlayLink"] ?? '';
          Constant.appStoreLink = event.data()!["appStoreLink"] ?? '';
          Constant.appVersion = event.data()!["app_version"] ?? '';
          Constant.storeUrl = event.data()!["storeUrl"] ?? '';
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("RestaurantNearBy")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.distanceType = event.data()!["distanceType"];
        }
      });

      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("specialDiscountOffer")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists) {
          Constant.specialDiscountOfferEnable =
              dineinresult.data()!["isEnable"];
        }
      });

      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          Constant.mailSettings = MailSettings.fromJson(value.data()!);
        }
      });

      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("ContactUs")
          .get()
          .then((time) {
        if (time.exists) {
          Constant.adminEmail = time.data()!["Email"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("notification_setting")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.senderId = event.data()?["projectId"];
          Constant.jsonNotificationFileURL = event.data()?["serviceJson"];
        }
      });

      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("document_verification_settings")
          .get()
          .then((value) {
        Constant.isRestaurantVerification =
            value.data()!['isRestaurantVerification'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("privacyPolicy")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.privacyPolicy = event.data()!["privacy_policy"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("termsAndConditions")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.termsAndConditions = event.data()!["termsAndConditions"];
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(
      String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          referralModel = ReferralModel.fromJson(value.docs.first.data());
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    OrderModel? orderModel;
    try {
      await fireStore
          .collection(CollectionName.restaurantOrders)
          .doc(orderId)
          .get()
          .then((value) {
        if (value.exists) {
          orderModel = OrderModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return orderModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(ratingModel.id)
          .set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> airPortList = [];
    await fireStore
        .collection(CollectionName.zone)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static Future<List<OrderModel>?> getAllOrder() async {
    List<OrderModel> orderList = [];
    try {
      await fireStore
          .collection(CollectionName.restaurantOrders)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          orderList.add(orderModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } catch (e) {
      log(e.toString());
    }
    return orderList;
  }

  static Future<bool> deleteCashbackRedeem(OrderModel orderModel) async {
    bool isUpdate = false;
    try {
      final querySnapshot = await fireStore
          .collection(CollectionName.cashbackRedeem)
          .where('orderId', isEqualTo: orderModel.id)
          .where('cashbackId', isEqualTo: orderModel.cashback?.id)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await fireStore
              .collection(CollectionName.cashbackRedeem)
              .doc(doc.id)
              .delete();
        }
        isUpdate = true;
      } else {
        isUpdate = false;
      }
    } catch (e) {
      isUpdate = false;
      rethrow;
    }
    return isUpdate;
  }

  static Future<bool> updateOrder(OrderModel orderModel) async {
    bool isUpdate = false;

    await fireStore
        .collection(CollectionName.restaurantOrders)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future restaurantVendorWalletSet(OrderModel orderModel) async {
    double subTotal = 0.0;
    double specialDiscount = 0.0;
    double taxAmount = 0.0;
    // double adminCommission = 0.0;

    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal = subTotal +
            double.parse(element.price.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      }
    }

    if (orderModel.specialDiscount != null &&
        orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscount = double.parse(
          orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.taxSetting != null) {
      for (var element in orderModel.taxSetting!) {
        taxAmount = taxAmount +
            Constant.calculateTax(
                amount: (subTotal -
                        double.parse(orderModel.discount.toString()) -
                        specialDiscount)
                    .toString(),
                taxModel: element);
      }
    }

    double basePrice = 0;
    // var totalamount = (subTotal + taxAmount) - double.parse(orderModel.discount.toString()) - specialDiscount;
    if (Constant.adminCommission!.isEnabled == true) {
      basePrice =
          (subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100))) -
              double.parse(orderModel.discount.toString()) -
              specialDiscount;
    } else {
      basePrice = subTotal -
          double.parse(orderModel.discount.toString()) -
          specialDiscount;
    }
    // if (Constant.isAdminCommissionModelApplied == true) {
    //   if (orderModel.adminCommissionType == 'Percent') {
    //     adminCommission = (subTotal - double.parse(orderModel.discount.toString()) - specialDiscount) * double.parse(orderModel.adminCommission!) / 100;
    //   } else {
    //     adminCommission = double.parse(orderModel.adminCommission!);
    //   }
    // }

    WalletTransactionModel historyModel = WalletTransactionModel(
        amount: basePrice,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: Timestamp.now(),
        isTopup: true,
        note: "Order Amount credited",
        paymentMethod: "Wallet",
        paymentStatus: "success",
        transactionUser: "vendor");

    await fireStore
        .collection(CollectionName.wallet)
        .doc(historyModel.id)
        .set(historyModel.toJson());

    WalletTransactionModel taxModel = WalletTransactionModel(
        amount: taxAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: Timestamp.now(),
        isTopup: true,
        note: "Order Tax credited",
        paymentMethod: "tax",
        paymentStatus: "success",
        transactionUser: "vendor");

    await fireStore
        .collection(CollectionName.wallet)
        .doc(historyModel.id)
        .set(historyModel.toJson());
    await fireStore
        .collection(CollectionName.wallet)
        .doc(taxModel.id)
        .set(taxModel.toJson());

    await updateUserWallet(
        amount: (basePrice + taxAmount).toString(),
        userId: orderModel.vendor!.author.toString());
  }

  static Future<RatingModel?> getOrderReviewsByID(
      String orderId, String productID) async {
    RatingModel? ratingModel;

    await fireStore
        .collection(CollectionName.foodsReview)
        .where('orderid', isEqualTo: orderId)
        .where('productId', isEqualTo: productID)
        .get()
        .then((value) {
      print("======>");
      print(value.docs.length);
      if (value.docs.isNotEmpty) {
        ratingModel = RatingModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModel;
  }

  static Future<List<ProductModel>?> getProduct() async {
    List<ProductModel> productList = [];
    await fireStore
        .collection(CollectionName.vendorProducts)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .orderBy('createdAt', descending: false)
        .get()
        .then((value) {
      for (var element in value.docs) {
        ProductModel productModel = ProductModel.fromJson(element.data());
        productList.add(productModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return productList;
  }

  static Future<List<AdvertisementModel>?> getAdvertisement() async {
    List<AdvertisementModel> advertisementList = [];
    await fireStore
        .collection(CollectionName.advertisements)
        .where('vendorId', isEqualTo: Constant.userModel!.vendorID)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        AdvertisementModel advertisementModel =
            AdvertisementModel.fromJson(element.data());
        advertisementList.add(advertisementModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementList;
  }

  static Future<AdvertisementModel> getAdvertisementById(
      {required String advertisementId}) async {
    AdvertisementModel advertisementdata = AdvertisementModel();
    await fireStore
        .collection(CollectionName.advertisements)
        .doc(advertisementId)
        .get()
        .then((value) {
      AdvertisementModel advertisementModel =
          AdvertisementModel.fromJson(value.data() as Map<String, dynamic>);
      advertisementdata = advertisementModel;
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementdata;
  }

  static Future<bool> updateProduct(ProductModel productModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(productModel.id)
        .set(productModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool> deleteProduct(ProductModel productModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(productModel.id)
        .delete()
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WalletTransactionModel>?> getFilterWalletTransaction(
      Timestamp startTime, Timestamp endTime) async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('date', isGreaterThanOrEqualTo: startTime)
        .where('date', isLessThanOrEqualTo: endTime)
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WithdrawalModel>?> getWithdrawHistory() async {
    List<WithdrawalModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.payouts)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID.toString())
        .orderBy('paidDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WithdrawalModel walletTransactionModel =
            WithdrawalModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future getPaymentSettingsData() async {
    await fireStore
        .collection(CollectionName.settings)
        .doc("payFastSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayFastModel payFastModel = PayFastModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payFastSettings, jsonEncode(payFastModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("MercadoPago")
        .get()
        .then((value) async {
      if (value.exists) {
        MercadoPagoModel mercadoPagoModel =
            MercadoPagoModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.mercadoPago, jsonEncode(mercadoPagoModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("paypalSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayPalModel payPalModel = PayPalModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paypalSettings, jsonEncode(payPalModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("stripeSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        StripeModel stripeModel = StripeModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.stripeSettings, jsonEncode(stripeModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("flutterWave")
        .get()
        .then((value) async {
      if (value.exists) {
        FlutterWaveModel flutterWaveModel =
            FlutterWaveModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.flutterWave, jsonEncode(flutterWaveModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("payStack")
        .get()
        .then((value) async {
      if (value.exists) {
        PayStackModel payStackModel = PayStackModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payStack, jsonEncode(payStackModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("PaytmSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PaytmModel paytmModel = PaytmModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paytmSettings, jsonEncode(paytmModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("walletSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        WalletSettingModel walletSettingModel =
            WalletSettingModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.walletSettings,
            jsonEncode(walletSettingModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("razorpaySettings")
        .get()
        .then((value) async {
      if (value.exists) {
        RazorPayModel razorPayModel = RazorPayModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.razorpaySettings, jsonEncode(razorPayModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("CODSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        CodSettingModel codSettingModel =
            CodSettingModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.codSettings, jsonEncode(codSettingModel.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("midtrans_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        MidTrans midTrans = MidTrans.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.midTransSettings, jsonEncode(midTrans.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("orange_money_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        OrangeMoney orangeMoney = OrangeMoney.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.orangeMoneySettings, jsonEncode(orangeMoney.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("xendit_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        Xendit xendit = Xendit.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.xenditSettings, jsonEncode(xendit.toJson()));
      }
    });
  }

  static Future<VendorModel?> getVendorById(String vendorId) async {
    VendorModel? vendorModel;
    try {
      if (vendorId.isNotEmpty) {
        await fireStore
            .collection(CollectionName.vendors)
            .doc(vendorId)
            .get()
            .then((value) {
          if (value.exists) {
            vendorModel = VendorModel.fromJson(value.data()!);
          }
        });
      }
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorModel;
  }

  static Future<List<VendorCategoryModel>?> getVendorCategoryById() async {
    List<VendorCategoryModel> attributeList = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          VendorCategoryModel favouriteModel =
              VendorCategoryModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<ProductModel?> getProductById(String productId) async {
    ProductModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .doc(productId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ProductModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.reviewAttributes)
          .doc(attributeId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorAttributes).get().then(
      (value) {
        for (var element in value.docs) {
          AttributesModel favouriteModel =
              AttributesModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    DeliveryCharge? deliveryCharge;
    try {
      await fireStore
          .collection(CollectionName.settings)
          .doc("DeliveryCharge")
          .get()
          .then((value) {
        if (value.exists) {
          deliveryCharge = DeliveryCharge.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return deliveryCharge;
  }

  static Future<List<DineInBookingModel>> getDineInBooking(
      bool isUpcoming) async {
    List<DineInBookingModel> list = [];

    if (isUpcoming) {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
  }

  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.restaurantOrders)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setCoupon(CouponModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.coupons)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> deleteCoupon(CouponModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.coupons)
        .doc(orderModel.id)
        .delete()
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<CouponModel>> getOffer(String vendorId) async {
    List<CouponModel> list = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        list.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<DocumentModel>> getDocumentList() async {
    List<DocumentModel> documentList = [];
    await fireStore
        .collection(CollectionName.documents)
        .where('type', isEqualTo: "restaurant")
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        DocumentModel documentModel = DocumentModel.fromJson(element.data());
        documentList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return documentList;
  }

  static Future<DriverDocumentModel?> getDocumentOfDriver() async {
    DriverDocumentModel? driverDocumentModel;
    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(getCurrentUid())
        .get()
        .then((value) async {
      if (value.exists) {
        driverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future<bool> uploadDriverDocument(Documents documents) async {
    bool isAdded = false;
    DriverDocumentModel driverDocumentModel = DriverDocumentModel();
    List<Documents> documentsList = [];
    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(getCurrentUid())
        .get()
        .then((value) async {
      if (value.exists) {
        DriverDocumentModel newDriverDocumentModel =
            DriverDocumentModel.fromJson(value.data()!);
        documentsList = newDriverDocumentModel.documents!;
        var contain = newDriverDocumentModel.documents!
            .where((element) => element.documentId == documents.documentId);
        if (contain.isEmpty) {
          documentsList.add(documents);

          driverDocumentModel.id = getCurrentUid();
          driverDocumentModel.type = "restaurant";
          driverDocumentModel.documents = documentsList;
        } else {
          var index = newDriverDocumentModel.documents!.indexWhere(
              (element) => element.documentId == documents.documentId);

          driverDocumentModel.id = getCurrentUid();
          driverDocumentModel.type = "restaurant";
          documentsList.removeAt(index);
          documentsList.insert(index, documents);
          driverDocumentModel.documents = documentsList;
          isAdded = false;
        }
      } else {
        documentsList.add(documents);
        driverDocumentModel.id = getCurrentUid();
        driverDocumentModel.type = "restaurant";
        driverDocumentModel.documents = documentsList;
      }
    });

    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(getCurrentUid())
        .set(driverDocumentModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      isAdded = false;
      log(error.toString());
    });

    return isAdded;
  }

  static Future<DeliveryCharge?> getDelivery() async {
    DeliveryCharge? driverDocumentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("DeliveryCharge")
        .get()
        .then((value) async {
      if (value.exists) {
        driverDocumentModel = DeliveryCharge.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future<VendorModel> firebaseCreateNewVendor(VendorModel vendor) async {
    DocumentReference documentReference =
        fireStore.collection(CollectionName.vendors).doc();
    vendor.id = documentReference.id;
    await documentReference.set(vendor.toJson());
    Constant.userModel?.vendorID = documentReference.id;
    vendor.fcmToken = Constant.userModel!.fcmToken;
    Constant.vendorAdminCommission = vendor.adminCommission;
    await FireStoreUtils.updateUser(Constant.userModel!);
    return vendor;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    try {
      if (vendor.id == null || vendor.id!.isEmpty) {
        log("Error: Vendor ID is null or empty in updateVendor");
        return null;
      }

      await fireStore
          .collection(CollectionName.vendors)
          .doc(vendor.id)
          .update(vendor.toJson())
          .then((document) {
        Constant.vendorAdminCommission = vendor.adminCommission;
        log("Vendor updated successfully: ${vendor.id}");
        return vendor;
      });
      return vendor;
    } catch (e) {
      log("Error updating vendor: $e");
      rethrow;
    }
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      if (Constant.userModel?.vendorID != null &&
          Constant.userModel?.vendorID?.isNotEmpty == true) {
        await fireStore
            .collection(CollectionName.coupons)
            .where('resturant_id', isEqualTo: Constant.userModel!.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.coupons)
                .doc(doc.reference.id)
                .delete();
          }
        });
        await fireStore
            .collection(CollectionName.foodsReview)
            .where('VendorId', isEqualTo: Constant.userModel!.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.foodsReview)
                .doc(doc.reference.id)
                .delete();
          }
        });

        await fireStore
            .collection(CollectionName.vendorProducts)
            .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.favoriteItem)
                .where('product_id', isEqualTo: doc.reference.id)
                .get()
                .then((value0) async {
              for (var element0 in value0.docs) {
                await fireStore
                    .collection(CollectionName.favoriteItem)
                    .doc(element0.reference.path)
                    .delete();
              }
            });
            await fireStore
                .collection(CollectionName.vendorProducts)
                .doc(doc.reference.id)
                .delete();
          }
        });

        await fireStore
            .collection(CollectionName.vendors)
            .doc(Constant.userModel?.vendorID)
            .delete();
      }

      await fireStore
          .collection(CollectionName.users)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser?.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait");
    try {
      var uniqueID = const Uuid().v4();
      Reference upload =
          FirebaseStorage.instance.ref().child('images/$uniqueID.png');
      UploadTask uploadTask = upload.putFile(image);

      // Wait for upload to complete
      await uploadTask;

      // Check if upload was successful
      if (uploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Upload failed with state: ${uploadTask.snapshot.state}');
      }

      var downloadUrl = await upload.getDownloadURL();
      var metaData = await upload.getMetadata();
      ShowToastDialog.closeLoader();
      return Url(
          mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading image: ${e.toString()}");
      rethrow;
    }
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef =
          FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );

      // Wait for video upload to complete
      await uploadTask;

      // Check if video upload was successful
      if (uploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Video upload failed with state: ${uploadTask.snapshot.state}');
      }

      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      File thumbnail = await VideoCompress.getFileThumbnail(
        video.path,
        quality: 75, // 0 - 100
        position: -1, // Get the first frame
      );

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef =
          FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnail.readAsBytesSync(),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for thumbnail upload to complete
      await thumbnailUploadTask;

      // Check if thumbnail upload was successful
      if (thumbnailUploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Thumbnail upload failed with state: ${thumbnailUploadTask.snapshot.state}');
      }

      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(
          videoUrl: Url(
              url: videoUrl.toString(), mime: metaData.contentType ?? 'video'),
          thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadImageOfStory(
      File image, BuildContext context, String extansion) async {
    try {
      final data = await image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: data);

      Reference upload = FirebaseStorage.instance.ref().child(
            'Story/images/${image.path.split('/').last}',
          );
      UploadTask uploadTask =
          upload.putFile(image, SettableMetadata(contentType: mime));

      // Wait for upload to complete
      await uploadTask;

      // Check if upload was successful
      if (uploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Upload failed with state: ${uploadTask.snapshot.state}');
      }

      var downloadUrl = await upload.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      ShowToastDialog.showToast("Error uploading story image: ${e.toString()}");
      rethrow;
    }
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<String?> uploadVideoStory(
      File video, BuildContext context) async {
    try {
      var uniqueID = const Uuid().v4();
      Reference upload =
          FirebaseStorage.instance.ref().child('Story/$uniqueID.mp4');
      File compressedVideo = await _compressVideo(video);
      SettableMetadata metadata = SettableMetadata(contentType: 'video');
      UploadTask uploadTask = upload.putFile(compressedVideo, metadata);

      // Wait for upload to complete
      await uploadTask;

      // Check if upload was successful
      if (uploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Upload failed with state: ${uploadTask.snapshot.state}');
      }

      var downloadUrl = await upload.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      ShowToastDialog.showToast("Error uploading story video: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    try {
      var uniqueID = const Uuid().v4();
      Reference upload =
          FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
      UploadTask uploadTask = upload.putFile(file);

      // Wait for upload to complete
      await uploadTask;

      // Check if upload was successful
      if (uploadTask.snapshot.state != TaskState.success) {
        throw Exception(
            'Upload failed with state: ${uploadTask.snapshot.state}');
      }

      var downloadUrl = await upload.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      ShowToastDialog.showToast("Error uploading thumbnail: ${e.toString()}");
      rethrow;
    }
  }

  static Future<StoryModel?> getStory(String vendorId) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await fireStore.collection(CollectionName.story).doc(vendorId).get();
    if (userDocument.data() != null && userDocument.exists) {
      return StoryModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future addOrUpdateStory(StoryModel storyModel) async {
    await fireStore
        .collection(CollectionName.story)
        .doc(storyModel.vendorID)
        .set(storyModel.toJson());
  }

  static Future removeStory(String vendorId) async {
    await fireStore.collection(CollectionName.story).doc(vendorId).delete();
  }

  static Future<WithdrawMethodModel?> getWithdrawMethod() async {
    WithdrawMethodModel? withdrawMethodModel;
    await fireStore
        .collection(CollectionName.withdrawMethod)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        withdrawMethodModel =
            WithdrawMethodModel.fromJson(value.docs.first.data());
      }
    });
    return withdrawMethodModel;
  }

  static Future<WithdrawMethodModel?> setWithdrawMethod(
      WithdrawMethodModel withdrawMethodModel) async {
    if (withdrawMethodModel.id == null) {
      withdrawMethodModel.id = const Uuid().v4();
      withdrawMethodModel.userId = getCurrentUid();
    }
    await fireStore
        .collection(CollectionName.withdrawMethod)
        .doc(withdrawMethodModel.id)
        .set(withdrawMethodModel.toJson())
        .then((value) async {});
    return withdrawMethodModel;
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await fireStore
        .collection(CollectionName.emailTemplates)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        emailTemplateModel =
            EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static sendPayoutMail(
      {required String amount, required String payoutrequestid}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(Constant.payoutRequest);

    String body = emailTemplateModel!.subject.toString();
    body = body.replaceAll("{userid}", Constant.userModel!.id.toString());

    String newString = emailTemplateModel.message.toString();
    newString =
        newString.replaceAll("{username}", Constant.userModel!.fullName());
    newString =
        newString.replaceAll("{userid}", Constant.userModel!.id.toString());
    newString =
        newString.replaceAll("{amount}", Constant.amountShow(amount: amount));
    newString =
        newString.replaceAll("{payoutrequestid}", payoutrequestid.toString());
    newString = newString.replaceAll("{usercontactinfo}",
        "${Constant.userModel!.email}\n${Constant.userModel!.phoneNumber}");
    await Constant.sendMail(
        subject: body,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [Constant.userModel!.email]);
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await fireStore
        .collection(CollectionName.dynamicNotification)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(
            id: "",
            message: "Notification setup is pending",
            subject: "setup notification",
            type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedTable)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setProduct(ProductModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$userID.png');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> subscriptionPlanModels = [];
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .where('isEnable', isEqualTo: true)
        .orderBy('place', descending: false)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionPlanModel subscriptionPlanModel =
              SubscriptionPlanModel.fromJson(element.data());
          if (subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
            subscriptionPlanModels.add(subscriptionPlanModel);
          }
        }
      }
    });
    return subscriptionPlanModels;
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById(
      {required String planId}) async {
    SubscriptionPlanModel? subscriptionPlanModel = SubscriptionPlanModel();
    if (planId.isNotEmpty) {
      await fireStore
          .collection(CollectionName.subscriptionPlans)
          .doc(planId)
          .get()
          .then((value) async {
        if (value.exists) {
          subscriptionPlanModel = SubscriptionPlanModel.fromJson(
              value.data() as Map<String, dynamic>);
        }
      });
    }
    return subscriptionPlanModel;
  }

  static Future<SubscriptionPlanModel> setSubscriptionPlan(
      SubscriptionPlanModel subscriptionPlanModel) async {
    if (subscriptionPlanModel.id?.isEmpty == true) {
      subscriptionPlanModel.id = const Uuid().v4();
    }
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .doc(subscriptionPlanModel.id)
        .set(subscriptionPlanModel.toJson())
        .then((value) async {});
    return subscriptionPlanModel;
  }

  static Future<bool?> setSubscriptionTransaction(
      SubscriptionHistoryModel subscriptionPlan) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.subscriptionHistory)
        .doc(subscriptionPlan.id)
        .set(subscriptionPlan.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    await fireStore
        .collection(CollectionName.subscriptionHistory)
        .where('user_id', isEqualTo: getCurrentUid())
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionHistoryModel subscriptionHistoryModel =
              SubscriptionHistoryModel.fromJson(element.data());
          subscriptionHistoryList.add(subscriptionHistoryModel);
        }
      }
    });
    return subscriptionHistoryList;
  }

  static Future<AdvertisementModel> firebaseCreateAdvertisement(
      AdvertisementModel model) async {
    await fireStore
        .collection(CollectionName.advertisements)
        .doc(model.id)
        .set(model.toJson());
    return model;
  }

  static Future<AdvertisementModel> removeAdvertisement(
      AdvertisementModel model) async {
    await fireStore
        .collection(CollectionName.advertisements)
        .doc(model.id)
        .delete();
    return model;
  }

  static Future<AdvertisementModel> pauseAndResumeAdvertisement(
      AdvertisementModel model) async {
    await fireStore
        .collection(CollectionName.advertisements)
        .doc(model.id)
        .update(model.toJson());
    return model;
  }

  static Future<List<RatingModel>> getOrderReviewsByVenderId(
      {required String venderId}) async {
    List<RatingModel> ratingModelList = [];
    await fireStore
        .collection(CollectionName.foodsReview)
        .where('VendorId', isEqualTo: venderId)
        .get()
        .then((value) {
      print("======>");
      print(value.docs.length);
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          ratingModelList.add(RatingModel.fromJson(value.docs[i].data()));
        }
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModelList;
  }

  static Future<List<UserModel>> getAvalibleDrivers() async {
    List<UserModel> driverList = [];
    try {
      log("getAvalibleDrivers :: 22");
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .where('active', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }

    return driverList;
  }

  static Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> driverList = [];
    try {
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }

  static late StreamSubscription<QuerySnapshot> adminChatSeenSubscription;
  static void setSeen() {
    final currentUserId = FireStoreUtils.getCurrentUid();

    adminChatSeenSubscription = FirebaseFirestore.instance
        .collection(CollectionName.chat)
        .doc(currentUserId)
        .collection("thread")
        .where('senderId', isEqualTo: Constant.adminType)
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static void stopSeenListener() {
    adminChatSeenSubscription.cancel();
  }

  static Future<ConversationModel> addChat(
      ConversationModel conversationModel) async {
    final chatCollection = fireStore.collection(CollectionName.chat);
    final docId = (conversationModel.receiverId?.contains('admin') == false)
        ? conversationModel.orderId
        : (conversationModel.orderId != null)
            ? conversationModel.orderId
            : conversationModel.senderId;
    await chatCollection
        .doc(docId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson());
    return conversationModel;
  }

  static Future<InboxModel> addInbox(InboxModel inboxModel) async {
    final collection = fireStore.collection(CollectionName.chat);
    final docId = (inboxModel.senderReceiverId?.contains('admin') == false)
        ? inboxModel.orderId
        : (inboxModel.orderId != null)
            ? inboxModel.orderId
            : inboxModel.senderId;
    await collection.doc(docId).set(inboxModel.toJson());
    return inboxModel;
  }

  static Future<bool?> setEmployeeRole(
      EmployeeRoleModel employeeRoleModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.vendorEmployeeRoles)
        .doc(employeeRoleModel.id)
        .set(employeeRoleModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<EmployeeRoleModel>> getAllEmployeeRoles(
      {bool isActive = false}) async {
    try {
      var query = fireStore
          .collection(CollectionName.vendorEmployeeRoles)
          .where('vendorId', isEqualTo: Constant.userModel?.vendorID);
      if (isActive) {
        query = query.where('isEnable', isEqualTo: true);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return EmployeeRoleModel.fromJson(doc.data());
      }).toList();
    } catch (error) {
      log("Failed to get employee roles: $error");
      return [];
    }
  }

  static Future<EmployeeRoleModel?> getEmployeeRoleById(String id) async {
    try {
      final docSnapshot = await fireStore
          .collection(CollectionName.vendorEmployeeRoles)
          .doc(id)
          .get();
      log("docSnapshot.data() :: ${docSnapshot.data()}");
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return EmployeeRoleModel.fromJson(docSnapshot.data()!);
      }
      return null; // Not found
    } catch (error) {
      log("Failed to get employee role by ID: $error");
      return null;
    }
  }

  static Future<bool> deleteEmployeeRole(String id) async {
    bool isDeleted = false;
    await fireStore
        .collection(CollectionName.vendorEmployeeRoles)
        .doc(id)
        .delete()
        .then((value) {
      isDeleted = true;
    }).catchError((error) {
      log("Failed to delete employee role: $error");
      isDeleted = false;
    });
    return isDeleted;
  }

  static Future<List<UserModel>> getAllEmployee() async {
    List<UserModel> employeeList = [];
    try {
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleEmployee)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        log("value.docs.isNotEmpty :: ${value.docs.length}");
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            employeeList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return employeeList;
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    UserModel? userModel;
    try {
      QuerySnapshot snapshot = await fireStore
          .collection(CollectionName.users)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        userModel = UserModel.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        userModel = null; // No user found
      }
    } catch (error) {
      log("Failed to get user by email: $error");
      userModel = null;
    }

    return userModel;
  }

  static late StreamSubscription<QuerySnapshot> orderChatSeenSubscription;
  static void setSeenChatForOrder({required String orderId}) {
    orderChatSeenSubscription = FirebaseFirestore.instance
        .collection(CollectionName.chat)
        .doc(orderId)
        .collection("thread")
        .where('senderId', isNotEqualTo: FireStoreUtils.getCurrentUid())
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static void stopSeenForOrderListener() {
    orderChatSeenSubscription.cancel();
  }
}
