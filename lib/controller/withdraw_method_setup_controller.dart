import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/payment_model/flutter_wave_model.dart';
import 'package:restaurant_td/models/payment_model/paypal_model.dart';
import 'package:restaurant_td/models/payment_model/razorpay_model.dart';
import 'package:restaurant_td/models/payment_model/stripe_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/withdraw_method_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class WithdrawMethodSetupController extends GetxController {
  Rx<TextEditingController> accountNumberFlutterWave =
      TextEditingController().obs;
  Rx<TextEditingController> bankCodeFlutterWave = TextEditingController().obs;
  Rx<TextEditingController> emailPaypal = TextEditingController().obs;
  Rx<TextEditingController> accountIdRazorPay = TextEditingController().obs;
  Rx<TextEditingController> accountIdStripe = TextEditingController().obs;

  Rx<UserBankDetails> userBankDetails = UserBankDetails().obs;
  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  RxBool isBankDetailsAdded = false.obs;

  RxBool isLoading = true.obs;
  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentMethod();
    getPaymentSettings();
    super.onInit();
  }

  getPaymentMethod() async {
    isLoading.value = true;
    accountNumberFlutterWave.value.clear();
    bankCodeFlutterWave.value.clear();
    emailPaypal.value.clear();
    accountIdRazorPay.value.clear();
    accountIdStripe.value.clear();

    await FireStoreUtils.getWithdrawMethod().then(
      (value) {
        if (value != null) {
          withdrawMethodModel.value = value;

          if (withdrawMethodModel.value.flutterWave != null) {
            accountNumberFlutterWave.value.text =
                withdrawMethodModel.value.flutterWave!.accountNumber.toString();
            bankCodeFlutterWave.value.text =
                withdrawMethodModel.value.flutterWave!.bankCode.toString();
          }

          if (withdrawMethodModel.value.paypal != null) {
            emailPaypal.value.text =
                withdrawMethodModel.value.paypal!.email.toString();
          }

          if (withdrawMethodModel.value.razorpay != null) {
            accountIdRazorPay.value.text =
                withdrawMethodModel.value.razorpay!.accountId.toString();
          }
          if (withdrawMethodModel.value.stripe != null) {
            accountIdStripe.value.text =
                withdrawMethodModel.value.stripe!.accountId.toString();
          }
        }
      },
    );
    isLoading.value = false;
  }

  getPaymentSettings() async {
    userBankDetails.value = Constant.userModel!.userBankDetails!;
    isBankDetailsAdded.value = userBankDetails.value.accountNumber.isNotEmpty;

    final _razorRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','razorpaySettings').maybeSingle();
    if (_razorRow != null) razorPayModel.value = RazorPayModel.fromJson(_razorRow['data'] ?? {});

    final _paypalRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','paypalSettings').maybeSingle();
    if (_paypalRow != null) paypalDataModel.value = PayPalModel.fromJson(_paypalRow['data'] ?? {});

    final _stripeRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','stripeSettings').maybeSingle();
    if (_stripeRow != null) stripeSettingData.value = StripeModel.fromJson(_stripeRow['data'] ?? {});

    final _fwRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','flutterWave').maybeSingle();
    if (_fwRow != null) flutterWaveSettingData.value = FlutterWaveModel.fromJson(_fwRow['data'] ?? {});
    isLoading.value = false;
  }
}
