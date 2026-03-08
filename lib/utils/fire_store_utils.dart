import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class FireStoreUtils {
  static final SupabaseClient _db = Supabase.instance.client;

  // ─── Storage bucket name (create this in Supabase Dashboard → Storage) ───
  static const String _bucket = 'restaurant-td';

  static String getCurrentUid() {
    return _db.auth.currentUser!.id;
  }

  static Future<bool> isLogin() async {
    if (_db.auth.currentUser != null) {
      return await userExistOrNot(_db.auth.currentUser!.id);
    }
    return false;
  }

  static Future<bool> userExistOrNot(String uid) async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select('id')
          .eq('id', uid)
          .maybeSingle();
      return data != null;
    } catch (e) {
      log('userExistOrNot error: $e');
      return false;
    }
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('id', uuid)
          .maybeSingle();
      if (data != null) {
        final userModel = UserModel.fromJson(data);
        Constant.userModel = userModel;
        if (userModel.employeePermissionId != null) {
          Constant.employeeRoleModel =
              await getEmployeeRoleById(userModel.employeePermissionId!);
        }
        return userModel;
      }
    } catch (e) {
      log('getUserProfile error: $e');
    }
    return null;
  }

  static Future<UserModel?> getUserById(String uuid) async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('id', uuid)
          .maybeSingle();
      if (data != null) return UserModel.fromJson(data);
    } catch (e) {
      log('getUserById error: $e');
    }
    return null;
  }

  static Future<bool?> updateUserWallet(
      {required String amount, required String userId}) async {
    final user = await getUserProfile(userId);
    if (user != null) {
      user.walletAmount = (user.walletAmount ?? 0.0) + double.parse(amount);
      return await updateUser(user);
    }
    return false;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      if (userModel.id == null || userModel.id!.isEmpty) return false;
      await _db.from(CollectionName.users).upsert(userModel.toJson());
      Constant.userModel = userModel;
      if (userModel.employeePermissionId != null) {
        Constant.employeeRoleModel =
            await getEmployeeRoleById(userModel.employeePermissionId!);
      }
      return true;
    } catch (e) {
      log('updateUser error: $e');
      return false;
    }
  }

  static Future<bool> updateDriverUser(UserModel userModel) async {
    try {
      if (userModel.id == null || userModel.id!.isEmpty) return false;
      await _db.from(CollectionName.users).upsert(userModel.toJson());
      return true;
    } catch (e) {
      log('updateDriverUser error: $e');
      return false;
    }
  }

  static Future<bool> withdrawWalletAmount(WithdrawalModel model) async {
    try {
      if (model.id == null || model.id!.isEmpty) return false;
      await _db.from(CollectionName.payouts).upsert(model.toJson());
      return true;
    } catch (e) {
      log('withdrawWalletAmount error: $e');
      return false;
    }
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    try {
      final data = await _db
          .from(CollectionName.onBoarding)
          .select()
          .eq('type', 'restaurantApp');
      return data
          .map<OnBoardingModel>((e) => OnBoardingModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getOnBoardingList error: $e');
      return [];
    }
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel model) async {
    try {
      await _db.from(CollectionName.wallet).upsert(model.toJson());
      return true;
    } catch (e) {
      log('setWalletTransaction error: $e');
      return false;
    }
  }

  Future<void> getSettings() async {
    try {
      // globalSettings
      final global = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'globalSettings')
          .maybeSingle();
      if (global != null) {
        final d = global['data'] as Map<String, dynamic>;
        Constant.orderRingtoneUrl = d['order_ringtone_url'] ?? '';
        Preferences.setString(
            Preferences.orderRingtone, Constant.orderRingtoneUrl);
        AppThemeData.secondary300 = Color(
            int.parse(d['app_restaurant_color'].replaceFirst('#', '0xff')));
        Constant.isEnableAdsFeature = d['isEnableAdsFeature'] ?? false;
        Constant.isSelfDeliveryFeature = d['isSelfDelivery'] ?? false;
        Constant.apiSecureKey = d['apiSecureKey'] ?? '';
        Constant.apiBaseUrl = d['apiBaseUrl'] ?? '';
        if (Constant.orderRingtoneUrl.isNotEmpty) {
          await AudioPlayerService.initAudio();
        }
      }

      // DriverNearBy
      final driverNearBy = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'DriverNearBy')
          .maybeSingle();
      if (driverNearBy != null) {
        final d = driverNearBy['data'] as Map<String, dynamic>;
        if ((d['selectedMapType'] ?? '').toString().isNotEmpty) {
          Constant.selectedMapType = d['selectedMapType'];
        }
        Constant.singleOrderReceive = d['singleOrderReceive'] ?? false;
      }

      // scheduleOrderNotification
      final schedule = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'scheduleOrderNotification')
          .maybeSingle();
      if (schedule != null) {
        final d = schedule['data'] as Map<String, dynamic>;
        Constant.scheduleOrderTime = d['notifyTime'];
        Constant.scheduleOrderTimeType = d['timeUnit'];
      }

      // DineinForRestaurant
      final dinein = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'DineinForRestaurant')
          .maybeSingle();
      if (dinein != null) {
        Constant.isDineInEnable = (dinein['data'] as Map)['isEnabled'] ?? false;
      }

      // restaurant
      final restaurant = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'restaurant')
          .maybeSingle();
      if (restaurant != null) {
        final d = restaurant['data'] as Map<String, dynamic>;
        Constant.autoApproveRestaurant = d['auto_approve_restaurant'];
        Constant.isSubscriptionModelApplied = d['subscription_model'];
      }

      // AdminCommission
      final commission = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'AdminCommission')
          .maybeSingle();
      if (commission != null) {
        Constant.adminCommission = AdminCommission.fromJson(
            commission['data'] as Map<String, dynamic>);
      }

      // googleMapKey
      final mapKey = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'googleMapKey')
          .maybeSingle();
      if (mapKey != null) {
        final d = mapKey['data'] as Map<String, dynamic>;
        if ((d['key'] ?? '').toString().isNotEmpty)
          Constant.mapAPIKey = d['key'];
        Constant.placeHolderImage = d['placeHolderImage'] ?? '';
      }

      // story
      final story = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'story')
          .maybeSingle();
      if (story != null)
        Constant.storyEnable = (story['data'] as Map)['isEnabled'];

      // placeHolderImage
      final placeholder = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'placeHolderImage')
          .maybeSingle();
      if (placeholder != null)
        Constant.placeholderImage = (placeholder['data'] as Map)['image'] ?? '';

      // Version
      final version = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'Version')
          .maybeSingle();
      if (version != null) {
        final d = version['data'] as Map<String, dynamic>;
        Constant.googlePlayLink = d['googlePlayLink'] ?? '';
        Constant.appStoreLink = d['appStoreLink'] ?? '';
        Constant.appVersion = d['app_version'] ?? '';
        Constant.storeUrl = d['storeUrl'] ?? '';
      }

      // RestaurantNearBy
      final nearBy = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'RestaurantNearBy')
          .maybeSingle();
      if (nearBy != null)
        Constant.distanceType = (nearBy['data'] as Map)['distanceType'] ?? 'km';

      // specialDiscountOffer
      final specialDiscount = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'specialDiscountOffer')
          .maybeSingle();
      if (specialDiscount != null)
        Constant.specialDiscountOfferEnable =
            (specialDiscount['data'] as Map)['isEnable'] ?? false;

      // emailSetting
      final emailSetting = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'emailSetting')
          .maybeSingle();
      if (emailSetting != null)
        Constant.mailSettings =
            MailSettings.fromJson(emailSetting['data'] as Map<String, dynamic>);

      // ContactUs
      final contact = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'ContactUs')
          .maybeSingle();
      if (contact != null)
        Constant.adminEmail = (contact['data'] as Map)['Email'] ?? '';

      // notification_setting
      final notifSetting = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'notification_setting')
          .maybeSingle();
      if (notifSetting != null) {
        final d = notifSetting['data'] as Map<String, dynamic>;
        Constant.senderId = d['projectId'] ?? '';
        Constant.jsonNotificationFileURL = d['serviceJson'] ?? '';
      }

      // document_verification_settings
      final docVerify = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'document_verification_settings')
          .maybeSingle();
      if (docVerify != null)
        Constant.isRestaurantVerification =
            (docVerify['data'] as Map)['isRestaurantVerification'] ?? false;

      // privacyPolicy
      final privacy = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'privacyPolicy')
          .maybeSingle();
      if (privacy != null)
        Constant.privacyPolicy =
            (privacy['data'] as Map)['privacy_policy'] ?? '';

      // termsAndConditions
      final terms = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'termsAndConditions')
          .maybeSingle();
      if (terms != null)
        Constant.termsAndConditions =
            (terms['data'] as Map)['termsAndConditions'] ?? '';
    } catch (e) {
      log('getSettings error: $e');
    }
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    try {
      final data = await _db
          .from(CollectionName.referral)
          .select('id')
          .eq('referral_code', referralCode);
      return data.isNotEmpty;
    } catch (e) {
      log('checkReferralCode error: $e');
      return false;
    }
  }

  static Future<ReferralModel?> getReferralUserByCode(
      String referralCode) async {
    try {
      final data = await _db
          .from(CollectionName.referral)
          .select()
          .eq('referral_code', referralCode)
          .maybeSingle();
      if (data != null) return ReferralModel.fromJson(data);
    } catch (e) {
      log('getReferralUserByCode error: $e');
    }
    return null;
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    try {
      final data = await _db
          .from(CollectionName.restaurantOrders)
          .select()
          .eq('id', orderId)
          .maybeSingle();
      if (data != null) return OrderModel.fromJson(data);
    } catch (e) {
      log('getOrderByOrderId error: $e');
    }
    return null;
  }

  static Future<String?> referralAdd(ReferralModel model) async {
    try {
      await _db.from(CollectionName.referral).upsert(model.toJson());
    } catch (e) {
      log('referralAdd error: $e');
    }
    return null;
  }

  static Future<List<ZoneModel>?> getZone() async {
    try {
      final data =
          await _db.from(CollectionName.zone).select().eq('publish', true);
      return data.map<ZoneModel>((e) => ZoneModel.fromJson(e)).toList();
    } catch (e) {
      log('getZone error: $e');
      return [];
    }
  }

  static Future<List<OrderModel>?> getAllOrder() async {
    try {
      final data = await _db
          .from(CollectionName.restaurantOrders)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .order('created_at', ascending: false);
      return data.map<OrderModel>((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      log('getAllOrder error: $e');
      return [];
    }
  }

  static Future<bool> deleteCashbackRedeem(OrderModel orderModel) async {
    try {
      await _db
          .from(CollectionName.cashbackRedeem)
          .delete()
          .eq('order_id', orderModel.id!)
          .eq('cashback_id', orderModel.cashback!.id!);
      return true;
    } catch (e) {
      log('deleteCashbackRedeem error: $e');
      return false;
    }
  }

  static Future<bool> updateOrder(OrderModel orderModel) async {
    try {
      await _db
          .from(CollectionName.restaurantOrders)
          .upsert(orderModel.toJson());
      return true;
    } catch (e) {
      log('updateOrder error: $e');
      return false;
    }
  }

  static Future restaurantVendorWalletSet(OrderModel orderModel) async {
    double subTotal = 0.0;
    double specialDiscount = 0.0;
    double taxAmount = 0.0;

    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal += double.parse(element.price.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      } else {
        subTotal += double.parse(element.discountPrice.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      }
    }

    if (orderModel.specialDiscount?['special_discount'] != null) {
      specialDiscount = double.parse(
          orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.taxSetting != null) {
      for (var element in orderModel.taxSetting!) {
        taxAmount += Constant.calculateTax(
            amount: (subTotal -
                    double.parse(orderModel.discount.toString()) -
                    specialDiscount)
                .toString(),
            taxModel: element);
      }
    }

    double basePrice;
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

    final historyModel = WalletTransactionModel(
        amount: basePrice,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: DateTime.now(),
        isTopup: true,
        note: 'Order Amount credited',
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        transactionUser: 'vendor');

    final taxModel = WalletTransactionModel(
        amount: taxAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: DateTime.now(),
        isTopup: true,
        note: 'Order Tax credited',
        paymentMethod: 'tax',
        paymentStatus: 'success',
        transactionUser: 'vendor');

    await _db.from(CollectionName.wallet).upsert(historyModel.toJson());
    await _db.from(CollectionName.wallet).upsert(taxModel.toJson());
    await updateUserWallet(
        amount: (basePrice + taxAmount).toString(),
        userId: orderModel.vendor!.author.toString());
  }

  static Future<RatingModel?> getOrderReviewsByID(
      String orderId, String productID) async {
    try {
      final data = await _db
          .from(CollectionName.foodsReview)
          .select()
          .eq('orderid', orderId)
          .eq('product_id', productID)
          .maybeSingle();
      if (data != null) return RatingModel.fromJson(data);
    } catch (e) {
      log('getOrderReviewsByID error: $e');
    }
    return null;
  }

  static Future<List<ProductModel>?> getProduct() async {
    try {
      final data = await _db
          .from(CollectionName.vendorProducts)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .order('created_at', ascending: true);
      return data.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      log('getProduct error: $e');
      return [];
    }
  }

  static Future<List<AdvertisementModel>?> getAdvertisement() async {
    try {
      final data = await _db
          .from(CollectionName.advertisements)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .order('created_at', ascending: false);
      return data
          .map<AdvertisementModel>((e) => AdvertisementModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getAdvertisement error: $e');
      return [];
    }
  }

  static Future<AdvertisementModel> getAdvertisementById(
      {required String advertisementId}) async {
    try {
      final data = await _db
          .from(CollectionName.advertisements)
          .select()
          .eq('id', advertisementId)
          .maybeSingle();
      if (data != null) return AdvertisementModel.fromJson(data);
    } catch (e) {
      log('getAdvertisementById error: $e');
    }
    return AdvertisementModel();
  }

  static Future<bool> updateProduct(ProductModel productModel) async {
    try {
      await _db
          .from(CollectionName.vendorProducts)
          .upsert(productModel.toJson());
      return true;
    } catch (e) {
      log('updateProduct error: $e');
      return false;
    }
  }

  static Future<bool> deleteProduct(ProductModel productModel) async {
    try {
      await _db
          .from(CollectionName.vendorProducts)
          .delete()
          .eq('id', productModel.id!);
      return true;
    } catch (e) {
      log('deleteProduct error: $e');
      return false;
    }
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    try {
      final data = await _db
          .from(CollectionName.wallet)
          .select()
          .eq('user_id', getCurrentUid())
          .order('date', ascending: false);
      return data
          .map<WalletTransactionModel>(
              (e) => WalletTransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getWalletTransaction error: $e');
      return [];
    }
  }

  static Future<List<WalletTransactionModel>?> getFilterWalletTransaction(
      DateTime startTime, DateTime endTime) async {
    try {
      final data = await _db
          .from(CollectionName.wallet)
          .select()
          .eq('user_id', getCurrentUid())
          .gte('date', startTime.toIso8601String())
          .lte('date', endTime.toIso8601String())
          .order('date', ascending: false);
      return data
          .map<WalletTransactionModel>(
              (e) => WalletTransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getFilterWalletTransaction error: $e');
      return [];
    }
  }

  static Future<List<WithdrawalModel>?> getWithdrawHistory() async {
    try {
      final data = await _db
          .from(CollectionName.payouts)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!.toString())
          .order('paid_date', ascending: false);
      return data
          .map<WithdrawalModel>((e) => WithdrawalModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getWithdrawHistory error: $e');
      return [];
    }
  }

  static Future getPaymentSettingsData() async {
    final keys = {
      'payFastSettings': (data) async => await Preferences.setString(
          Preferences.payFastSettings,
          jsonEncode(PayFastModel.fromJson(data).toJson())),
      'MercadoPago': (data) async => await Preferences.setString(
          Preferences.mercadoPago,
          jsonEncode(MercadoPagoModel.fromJson(data).toJson())),
      'paypalSettings': (data) async => await Preferences.setString(
          Preferences.paypalSettings,
          jsonEncode(PayPalModel.fromJson(data).toJson())),
      'stripeSettings': (data) async => await Preferences.setString(
          Preferences.stripeSettings,
          jsonEncode(StripeModel.fromJson(data).toJson())),
      'flutterWave': (data) async => await Preferences.setString(
          Preferences.flutterWave,
          jsonEncode(FlutterWaveModel.fromJson(data).toJson())),
      'payStack': (data) async => await Preferences.setString(
          Preferences.payStack,
          jsonEncode(PayStackModel.fromJson(data).toJson())),
      'PaytmSettings': (data) async => await Preferences.setString(
          Preferences.paytmSettings,
          jsonEncode(PaytmModel.fromJson(data).toJson())),
      'walletSettings': (data) async => await Preferences.setString(
          Preferences.walletSettings,
          jsonEncode(WalletSettingModel.fromJson(data).toJson())),
      'razorpaySettings': (data) async => await Preferences.setString(
          Preferences.razorpaySettings,
          jsonEncode(RazorPayModel.fromJson(data).toJson())),
      'CODSettings': (data) async => await Preferences.setString(
          Preferences.codSettings,
          jsonEncode(CodSettingModel.fromJson(data).toJson())),
      'midtrans_settings': (data) async => await Preferences.setString(
          Preferences.midTransSettings,
          jsonEncode(MidTrans.fromJson(data).toJson())),
      'orange_money_settings': (data) async => await Preferences.setString(
          Preferences.orangeMoneySettings,
          jsonEncode(OrangeMoney.fromJson(data).toJson())),
      'xendit_settings': (data) async => await Preferences.setString(
          Preferences.xenditSettings,
          jsonEncode(Xendit.fromJson(data).toJson())),
    };

    for (final entry in keys.entries) {
      try {
        final row = await _db
            .from(CollectionName.settings)
            .select('data')
            .eq('key', entry.key)
            .maybeSingle();
        if (row != null) await entry.value(row['data']);
      } catch (e) {
        log('getPaymentSettingsData [${entry.key}] error: $e');
      }
    }
  }

  static Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      if (vendorId.isEmpty) return null;
      final data = await _db
          .from(CollectionName.vendors)
          .select()
          .eq('id', vendorId)
          .maybeSingle();
      if (data != null) return VendorModel.fromJson(data);
    } catch (e) {
      log('getVendorById error: $e');
    }
    return null;
  }

  static Future<List<VendorCategoryModel>?> getVendorCategoryById() async {
    try {
      final data = await _db
          .from(CollectionName.vendorCategories)
          .select()
          .eq('publish', true);
      return data
          .map<VendorCategoryModel>((e) => VendorCategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getVendorCategoryById error: $e');
      return [];
    }
  }

  static Future<ProductModel?> getProductById(String productId) async {
    try {
      final data = await _db
          .from(CollectionName.vendorProducts)
          .select()
          .eq('id', productId)
          .maybeSingle();
      if (data != null) return ProductModel.fromJson(data);
    } catch (e) {
      log('getProductById error: $e');
    }
    return null;
  }

  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String categoryId) async {
    try {
      final data = await _db
          .from(CollectionName.vendorCategories)
          .select()
          .eq('id', categoryId)
          .maybeSingle();
      if (data != null) return VendorCategoryModel.fromJson(data);
    } catch (e) {
      log('getVendorCategoryByCategoryId error: $e');
    }
    return null;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attributeId) async {
    try {
      final data = await _db
          .from(CollectionName.reviewAttributes)
          .select()
          .eq('id', attributeId)
          .maybeSingle();
      if (data != null) return ReviewAttributeModel.fromJson(data);
    } catch (e) {
      log('getVendorReviewAttribute error: $e');
    }
    return null;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    try {
      final data = await _db.from(CollectionName.vendorAttributes).select();
      return data
          .map<AttributesModel>((e) => AttributesModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getAttributes error: $e');
      return [];
    }
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    try {
      final row = await _db
          .from(CollectionName.settings)
          .select('data')
          .eq('key', 'DeliveryCharge')
          .maybeSingle();
      if (row != null) return DeliveryCharge.fromJson(row['data']);
    } catch (e) {
      log('getDeliveryCharge error: $e');
    }
    return null;
  }

  static Future<List<DineInBookingModel>> getDineInBooking(
      bool isUpcoming) async {
    try {
      final now = DateTime.now().toIso8601String();
      final query = _db
          .from(CollectionName.bookedTable)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!);

      final data = isUpcoming
          ? await query.gt('date', now).order('date', ascending: false)
          : await query.lt('date', now).order('date', ascending: false);

      return data
          .map<DineInBookingModel>((e) => DineInBookingModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getDineInBooking error: $e');
      return [];
    }
  }

  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    try {
      final data = await _db
          .from(CollectionName.coupons)
          .select()
          .eq('resturant_id', vendorId)
          .eq('is_enabled', true)
          .eq('is_public', true)
          .gt('expires_at', DateTime.now().toIso8601String());
      return data.map<CouponModel>((e) => CouponModel.fromJson(e)).toList();
    } catch (e) {
      log('getAllVendorCoupons error: $e');
      return [];
    }
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    try {
      await _db
          .from(CollectionName.restaurantOrders)
          .upsert(orderModel.toJson());
      return true;
    } catch (e) {
      log('setOrder error: $e');
      return false;
    }
  }

  static Future<bool?> setCoupon(CouponModel model) async {
    try {
      await _db.from(CollectionName.coupons).upsert(model.toJson());
      return true;
    } catch (e) {
      log('setCoupon error: $e');
      return false;
    }
  }

  static Future<bool?> deleteCoupon(CouponModel model) async {
    try {
      await _db.from(CollectionName.coupons).delete().eq('id', model.id!);
      return true;
    } catch (e) {
      log('deleteCoupon error: $e');
      return false;
    }
  }

  static Future<List<CouponModel>> getOffer(String vendorId) async {
    try {
      final data = await _db
          .from(CollectionName.coupons)
          .select()
          .eq('resturant_id', vendorId);
      return data.map<CouponModel>((e) => CouponModel.fromJson(e)).toList();
    } catch (e) {
      log('getOffer error: $e');
      return [];
    }
  }

  static Future<List<DocumentModel>> getDocumentList() async {
    try {
      final data = await _db
          .from(CollectionName.documents)
          .select()
          .eq('type', 'restaurant')
          .eq('enable', true);
      return data.map<DocumentModel>((e) => DocumentModel.fromJson(e)).toList();
    } catch (e) {
      log('getDocumentList error: $e');
      return [];
    }
  }

  static Future<DriverDocumentModel?> getDocumentOfDriver() async {
    try {
      final data = await _db
          .from(CollectionName.documentsVerify)
          .select()
          .eq('id', getCurrentUid())
          .maybeSingle();
      if (data != null) return DriverDocumentModel.fromJson(data);
    } catch (e) {
      log('getDocumentOfDriver error: $e');
    }
    return null;
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    try {
      await _db.from('chat_restaurant').upsert(inboxModel.toJson());
    } catch (e) {
      log('addRestaurantInbox error: $e');
    }
    return inboxModel;
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    try {
      await _db.from('chat_restaurant').upsert(conversationModel.toJson());
    } catch (e) {
      log('addRestaurantChat error: $e');
    }
    return conversationModel;
  }

  static Future<bool> uploadDriverDocument(Documents documents) async {
    try {
      final existing = await _db
          .from(CollectionName.documentsVerify)
          .select()
          .eq('id', getCurrentUid())
          .maybeSingle();

      List<Documents> documentsList = [];
      if (existing != null) {
        final model = DriverDocumentModel.fromJson(existing);
        documentsList = model.documents ?? [];
        final idx = documentsList
            .indexWhere((e) => e.documentId == documents.documentId);
        if (idx >= 0) {
          documentsList.removeAt(idx);
          documentsList.insert(idx, documents);
        } else {
          documentsList.add(documents);
        }
      } else {
        documentsList.add(documents);
      }

      final model = DriverDocumentModel(
          id: getCurrentUid(), type: 'restaurant', documents: documentsList);
      await _db.from(CollectionName.documentsVerify).upsert(model.toJson());
      return true;
    } catch (e) {
      log('uploadDriverDocument error: $e');
      return false;
    }
  }

  static Future<DeliveryCharge?> getDelivery() async {
    return getDeliveryCharge();
  }

  static Future<VendorModel> firebaseCreateNewVendor(VendorModel vendor) async {
    vendor.id = const Uuid().v4();
    await _db.from(CollectionName.vendors).upsert(vendor.toJson());
    Constant.userModel?.vendorID = vendor.id;
    vendor.fcmToken = Constant.userModel!.fcmToken;
    Constant.vendorAdminCommission = vendor.adminCommission;
    await updateUser(Constant.userModel!);
    return vendor;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    try {
      if (vendor.id == null || vendor.id!.isEmpty) return null;
      await _db.from(CollectionName.vendors).upsert(vendor.toJson());
      Constant.vendorAdminCommission = vendor.adminCommission;
      return vendor;
    } catch (e) {
      log('updateVendor error: $e');
      rethrow;
    }
  }

  static Future<bool?> deleteUser() async {
    try {
      if (Constant.userModel?.vendorID?.isNotEmpty == true) {
        final vendorId = Constant.userModel!.vendorID!;

        // Delete coupons
        await _db
            .from(CollectionName.coupons)
            .delete()
            .eq('resturant_id', vendorId);

        // Delete reviews
        await _db
            .from(CollectionName.foodsReview)
            .delete()
            .eq('vendor_id', vendorId);

        // Get products then delete favorites and products
        final products = await _db
            .from(CollectionName.vendorProducts)
            .select('id')
            .eq('vendor_id', vendorId);
        for (final p in products) {
          await _db
              .from(CollectionName.favoriteItem)
              .delete()
              .eq('product_id', p['id']);
          await _db
              .from(CollectionName.vendorProducts)
              .delete()
              .eq('id', p['id']);
        }

        await _db.from(CollectionName.vendors).delete().eq('id', vendorId);
      }

      await _db.from(CollectionName.users).delete().eq('id', getCurrentUid());

      await _db.auth.admin.deleteUser(getCurrentUid());
      return true;
    } catch (e) {
      log('deleteUser error: $e');
      return false;
    }
  }

  // ─── STORAGE UPLOAD HELPERS ───────────────────────────────────────────────

  static Future<String> _uploadFile({
    required File file,
    required String path,
    String? contentType,
  }) async {
    final mimeType =
        contentType ?? lookupMimeType(file.path) ?? 'application/octet-stream';
    final bytes = await file.readAsBytes();
    await _db.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    return _db.storage.from(_bucket).getPublicUrl(path);
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader('Please wait');
    try {
      final uniqueID = const Uuid().v4();
      final url = await _uploadFile(
          file: image, path: 'images/$uniqueID.png', contentType: 'image/png');
      ShowToastDialog.closeLoader();
      final mime = lookupMimeType(image.path) ?? 'image';
      return Url(mime: mime, url: url);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Error uploading image: $e');
      rethrow;
    }
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader('Uploading video...');
      final uniqueID = const Uuid().v4();
      final videoUrl = await _uploadFile(
          file: video, path: 'videos/$uniqueID.mp4', contentType: 'video/mp4');

      ShowToastDialog.showLoader('Generating thumbnail...');
      final thumbnail = await VideoCompress.getFileThumbnail(video.path,
          quality: 75, position: -1);

      final thumbID = const Uuid().v4();
      final thumbUrl = await _uploadFile(
          file: thumbnail,
          path: 'thumbnails/$thumbID.jpg',
          contentType: 'image/jpeg');

      ShowToastDialog.closeLoader();
      return ChatVideoContainer(
          videoUrl: Url(url: videoUrl, mime: 'video/mp4'),
          thumbnailUrl: thumbUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Error: $e');
      return null;
    }
  }

  static Future<String> uploadImageOfStory(
      File image, BuildContext context, String extension) async {
    try {
      final data = await image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: data);
      final fileName = image.path.split('/').last;
      return await _uploadFile(
          file: image, path: 'Story/images/$fileName', contentType: mime);
    } catch (e) {
      ShowToastDialog.showToast('Error uploading story image: $e');
      rethrow;
    }
  }

  static Future<File> _compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    return info != null ? File(info.path!) : file;
  }

  static Future<String?> uploadVideoStory(
      File video, BuildContext context) async {
    try {
      final uniqueID = const Uuid().v4();
      final compressed = await _compressVideo(video);
      return await _uploadFile(
          file: compressed,
          path: 'Story/$uniqueID.mp4',
          contentType: 'video/mp4');
    } catch (e) {
      ShowToastDialog.showToast('Error uploading story video: $e');
      return null;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    try {
      final uniqueID = const Uuid().v4();
      return await _uploadFile(
          file: file,
          path: 'thumbnails/$uniqueID.png',
          contentType: 'image/png');
    } catch (e) {
      ShowToastDialog.showToast('Error uploading thumbnail: $e');
      rethrow;
    }
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    return await _uploadFile(
        file: image, path: 'images/$userID.png', contentType: 'image/png');
  }

  // ─── STORY ────────────────────────────────────────────────────────────────

  static Future<StoryModel?> getStory(String vendorId) async {
    try {
      final data = await _db
          .from(CollectionName.story)
          .select()
          .eq('vendor_id', vendorId)
          .maybeSingle();
      if (data != null) return StoryModel.fromJson(data);
    } catch (e) {
      log('getStory error: $e');
    }
    return null;
  }

  static Future addOrUpdateStory(StoryModel storyModel) async {
    await _db.from(CollectionName.story).upsert(storyModel.toJson());
  }

  static Future removeStory(String vendorId) async {
    await _db.from(CollectionName.story).delete().eq('vendor_id', vendorId);
  }

  // ─── WITHDRAW METHOD ──────────────────────────────────────────────────────

  static Future<WithdrawMethodModel?> getWithdrawMethod() async {
    try {
      final data = await _db
          .from(CollectionName.withdrawMethod)
          .select()
          .eq('user_id', getCurrentUid())
          .maybeSingle();
      if (data != null) return WithdrawMethodModel.fromJson(data);
    } catch (e) {
      log('getWithdrawMethod error: $e');
    }
    return null;
  }

  static Future<WithdrawMethodModel?> setWithdrawMethod(
      WithdrawMethodModel model) async {
    model.id ??= const Uuid().v4();
    model.userId = getCurrentUid();
    await _db.from(CollectionName.withdrawMethod).upsert(model.toJson());
    return model;
  }

  // ─── EMAIL TEMPLATES ──────────────────────────────────────────────────────

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    try {
      final data = await _db
          .from(CollectionName.emailTemplates)
          .select()
          .eq('type', type)
          .maybeSingle();
      if (data != null) return EmailTemplateModel.fromJson(data);
    } catch (e) {
      log('getEmailTemplates error: $e');
    }
    return null;
  }

  static sendPayoutMail(
      {required String amount, required String payoutrequestid}) async {
    final template = await getEmailTemplates(Constant.payoutRequest);
    if (template == null) return;

    String body = template.subject
        .toString()
        .replaceAll('{userid}', Constant.userModel!.id.toString());

    String msg = template.message
        .toString()
        .replaceAll('{username}', Constant.userModel!.fullName())
        .replaceAll('{userid}', Constant.userModel!.id.toString())
        .replaceAll('{amount}', Constant.amountShow(amount: amount))
        .replaceAll('{payoutrequestid}', payoutrequestid)
        .replaceAll('{usercontactinfo}',
            '${Constant.userModel!.email}\n${Constant.userModel!.phoneNumber}');

    await Constant.sendMail(
        subject: body,
        isAdmin: template.isSendToAdmin,
        body: msg,
        recipients: [Constant.userModel!.email]);
  }

  // ─── NOTIFICATIONS ────────────────────────────────────────────────────────

  static Future<NotificationModel?> getNotificationContent(String type) async {
    try {
      final data = await _db
          .from(CollectionName.dynamicNotification)
          .select()
          .eq('type', type)
          .maybeSingle();
      if (data != null) return NotificationModel.fromJson(data);
    } catch (e) {
      log('getNotificationContent error: $e');
    }
    return NotificationModel(
        id: '',
        message: 'Notification setup is pending',
        subject: 'setup notification',
        type: '');
  }

  // ─── DINE IN ──────────────────────────────────────────────────────────────

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    try {
      await _db.from(CollectionName.bookedTable).upsert(orderModel.toJson());
      return true;
    } catch (e) {
      log('setBookedOrder error: $e');
      return false;
    }
  }

  // ─── PRODUCTS ─────────────────────────────────────────────────────────────

  static Future<bool?> setProduct(ProductModel model) async {
    try {
      await _db.from(CollectionName.vendorProducts).upsert(model.toJson());
      return true;
    } catch (e) {
      log('setProduct error: $e');
      return false;
    }
  }

  // ─── SUBSCRIPTION ─────────────────────────────────────────────────────────

  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    try {
      final data = await _db
          .from(CollectionName.subscriptionPlans)
          .select()
          .eq('is_enable', true)
          .order('place', ascending: true);
      return data
          .map<SubscriptionPlanModel>((e) => SubscriptionPlanModel.fromJson(e))
          .where((e) => e.id != Constant.commissionSubscriptionID)
          .toList();
    } catch (e) {
      log('getAllSubscriptionPlans error: $e');
      return [];
    }
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById(
      {required String planId}) async {
    try {
      if (planId.isEmpty) return null;
      final data = await _db
          .from(CollectionName.subscriptionPlans)
          .select()
          .eq('id', planId)
          .maybeSingle();
      if (data != null) return SubscriptionPlanModel.fromJson(data);
    } catch (e) {
      log('getSubscriptionPlanById error: $e');
    }
    return null;
  }

  static Future<SubscriptionPlanModel> setSubscriptionPlan(
      SubscriptionPlanModel model) async {
    if (model.id?.isEmpty == true) model.id = const Uuid().v4();
    await _db.from(CollectionName.subscriptionPlans).upsert(model.toJson());
    return model;
  }

  static Future<bool?> setSubscriptionTransaction(
      SubscriptionHistoryModel model) async {
    try {
      await _db.from(CollectionName.subscriptionHistory).upsert(model.toJson());
      return true;
    } catch (e) {
      log('setSubscriptionTransaction error: $e');
      return false;
    }
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    try {
      final data = await _db
          .from(CollectionName.subscriptionHistory)
          .select()
          .eq('user_id', getCurrentUid())
          .order('created_at', ascending: false);
      return data
          .map<SubscriptionHistoryModel>(
              (e) => SubscriptionHistoryModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getSubscriptionHistory error: $e');
      return [];
    }
  }

  // ─── ADVERTISEMENTS ───────────────────────────────────────────────────────

  static Future<AdvertisementModel> firebaseCreateAdvertisement(
      AdvertisementModel model) async {
    await _db.from(CollectionName.advertisements).upsert(model.toJson());
    return model;
  }

  static Future<AdvertisementModel> removeAdvertisement(
      AdvertisementModel model) async {
    await _db.from(CollectionName.advertisements).delete().eq('id', model.id!);
    return model;
  }

  static Future<AdvertisementModel> pauseAndResumeAdvertisement(
      AdvertisementModel model) async {
    await _db.from(CollectionName.advertisements).upsert(model.toJson());
    return model;
  }

  // ─── REVIEWS ──────────────────────────────────────────────────────────────

  static Future<List<RatingModel>> getOrderReviewsByVenderId(
      {required String venderId}) async {
    try {
      final data = await _db
          .from(CollectionName.foodsReview)
          .select()
          .eq('vendor_id', venderId);
      return data.map<RatingModel>((e) => RatingModel.fromJson(e)).toList();
    } catch (e) {
      log('getOrderReviewsByVenderId error: $e');
      return [];
    }
  }

  // ─── DRIVERS ──────────────────────────────────────────────────────────────

  static Future<List<UserModel>> getAvalibleDrivers() async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .eq('role', Constant.userRoleDriver)
          .eq('active', true)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return data.map<UserModel>((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      log('getAvalibleDrivers error: $e');
      return [];
    }
  }

  static Future<List<UserModel>> getAllDrivers() async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .eq('role', Constant.userRoleDriver)
          .order('created_at', ascending: false);
      return data.map<UserModel>((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      log('getAllDrivers error: $e');
      return [];
    }
  }

  // ─── CHAT ─────────────────────────────────────────────────────────────────

  static StreamSubscription<List<Map<String, dynamic>>>?
      _adminChatSeenSubscription;

  static void setSeen() {
    final currentUserId = getCurrentUid();
    _adminChatSeenSubscription = _db
        .from(CollectionName.chat)
        .stream(primaryKey: ['id'])
        .eq('sender_id', 'admin')
        .listen((rows) async {
          for (final row in rows) {
            if (row['seen'] == false && row['receiver_id'] == currentUserId) {
              try {
                await _db
                    .from(CollectionName.chat)
                    .update({'seen': true}).eq('id', row['id']);
              } catch (e) {
                log('setSeen update error: $e');
              }
            }
          }
        });
  }

  static void stopSeenListener() {
    _adminChatSeenSubscription?.cancel();
  }

  static Future<ConversationModel> addChat(
      ConversationModel conversationModel) async {
    await _db.from(CollectionName.chat).upsert(conversationModel.toJson());
    return conversationModel;
  }

  static Future<InboxModel> addInbox(InboxModel inboxModel) async {
    await _db.from(CollectionName.chat).upsert(inboxModel.toJson());
    return inboxModel;
  }

  static StreamSubscription<List<Map<String, dynamic>>>?
      _orderChatSeenSubscription;

  static void setSeenChatForOrder({required String orderId}) {
    final currentUserId = getCurrentUid();
    _orderChatSeenSubscription = _db
        .from(CollectionName.chat)
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .listen((rows) async {
          for (final row in rows) {
            if (row['seen'] == false && row['sender_id'] != currentUserId) {
              try {
                await _db
                    .from(CollectionName.chat)
                    .update({'seen': true}).eq('id', row['id']);
              } catch (e) {
                log('setSeenChatForOrder update error: $e');
              }
            }
          }
        });
  }

  static void stopSeenForOrderListener() {
    _orderChatSeenSubscription?.cancel();
  }

  // ─── EMPLOYEE ROLES ───────────────────────────────────────────────────────

  static Future<bool?> setEmployeeRole(EmployeeRoleModel model) async {
    try {
      await _db.from(CollectionName.vendorEmployeeRoles).upsert(model.toJson());
      return true;
    } catch (e) {
      log('setEmployeeRole error: $e');
      return false;
    }
  }

  static Future<List<EmployeeRoleModel>> getAllEmployeeRoles(
      {bool isActive = false}) async {
    try {
      var query = _db
          .from(CollectionName.vendorEmployeeRoles)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!);
      final data = isActive ? await query.eq('is_enable', true) : await query;
      return data
          .map<EmployeeRoleModel>((e) => EmployeeRoleModel.fromJson(e))
          .toList();
    } catch (e) {
      log('getAllEmployeeRoles error: $e');
      return [];
    }
  }

  static Future<EmployeeRoleModel?> getEmployeeRoleById(String id) async {
    try {
      final data = await _db
          .from(CollectionName.vendorEmployeeRoles)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data != null) return EmployeeRoleModel.fromJson(data);
    } catch (e) {
      log('getEmployeeRoleById error: $e');
    }
    return null;
  }

  static Future<bool> deleteEmployeeRole(String id) async {
    try {
      await _db.from(CollectionName.vendorEmployeeRoles).delete().eq('id', id);
      return true;
    } catch (e) {
      log('deleteEmployeeRole error: $e');
      return false;
    }
  }

  static Future<List<UserModel>> getAllEmployee() async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('vendor_id', Constant.userModel!.vendorID!)
          .eq('role', Constant.userRoleEmployee)
          .order('created_at', ascending: false);
      return data.map<UserModel>((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      log('getAllEmployee error: $e');
      return [];
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final data = await _db
          .from(CollectionName.users)
          .select()
          .eq('email', email)
          .limit(1)
          .maybeSingle();
      if (data != null) return UserModel.fromJson(data);
    } catch (e) {
      log('getUserByEmail error: $e');
    }
    return null;
  }
}
