import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/payment_model/flutter_wave_model.dart';
import 'package:restaurant_td/models/payment_model/paypal_model.dart';
import 'package:restaurant_td/models/payment_model/razorpay_model.dart';
import 'package:restaurant_td/models/payment_model/stripe_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/wallet_transaction_model.dart';
import 'package:restaurant_td/models/withdraw_method_model.dart';
import 'package:restaurant_td/models/withdrawal_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WalletController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> amountTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> noteTextFieldController = TextEditingController().obs;

  Rx<UserModel> userModel = UserModel().obs;
  RxList<WalletTransactionModel> walletTransactionList = <WalletTransactionModel>[].obs;
  RxList<WithdrawalModel> withdrawalList = <WithdrawalModel>[].obs;

  RxInt selectedTabIndex = 0.obs;
  RxInt selectedValue = 0.obs;

  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getWalletTransaction(false);

    super.onInit();
  }

  Future<void> createAndSavePdf() async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();

    // Add a page to the document
    final PdfPage page = document.pages.add();

    // Create a PDF grid (table)
    final PdfGrid grid = PdfGrid();

    // Add columns to the grid
    grid.columns.add(count: 4);

    // Add headers to the grid
    grid.headers.add(1);
    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Description';
    header.cells[1].value = 'Order Id';
    header.cells[2].value = 'Amount';
    header.cells[3].value = 'Date';

    // Add rows to the grid
    PdfGridRow row = grid.rows.add();
    for (var element in walletTransactionList) {
      row.cells[0].value = element.note.toString();
      row.cells[1].value = Constant.orderId(orderId: element.orderId.toString());
      row.cells[2].value = Constant.amountShow(amount: element.amount.toString());
      row.cells[3].value = Constant.timestampToDateTime(element.date!);
      row = grid.rows.add();
    }

    // Draw the grid on the page
    grid.draw(
      page: page,
      bounds: const Rect.fromLTWH(0, 0, 0, 0),
    );

    // Save the document
    final List<int> bytes = document.saveSync();

    // Dispose of the document
    document.dispose();

    // Get the application directory
    final Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
    if (downloadsDirectory != null) {
      final String path = '${downloadsDirectory.path}/statement.pdf';
      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      ShowToastDialog.showToast("Statement downloaded in download folder".tr);
      print('PDF saved at: $path');
    }
  }

  RxDouble orderAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;

  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 1)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxBool isWithdrawBTnEnabled = true.obs;

  Future<void> getWalletTransaction(bool isFilter) async {
    if (isFilter) {
      await FireStoreUtils.getFilterWalletTransaction(DateTime(startDate.value.year, startDate.value.month, startDate.value.day, 00, 00),
              DateTime(endDate.value.year, endDate.value.month, endDate.value.day, 23, 59))
          .then(
        (value) {
          if (value != null) {
            taxAmount.value = 0;
            orderAmount.value = 0;
            walletTransactionList.value = value;

            walletTransactionList.where((element) => element.paymentMethod == "tax").toList();
            walletTransactionList.forEach(
              (element) {
                if (element.paymentMethod == "tax") {
                  if (element.isTopup == false) {
                    taxAmount.value -= double.parse(element.amount.toString());
                  } else {
                    taxAmount.value += double.parse(element.amount.toString());
                  }
                } else {
                  if (element.isTopup == false) {
                    orderAmount.value -= double.parse(element.amount.toString());
                  } else {
                    orderAmount.value += double.parse(element.amount.toString());
                  }
                }
              },
            );
          }
        },
      );
    } else {
      await FireStoreUtils.getWalletTransaction().then(
        (value) {
          if (value != null) {
            taxAmount.value = 0;
            orderAmount.value = 0;
            walletTransactionList.value = value;

            walletTransactionList.where((element) => element.paymentMethod == "tax").toList();
            walletTransactionList.forEach(
              (element) {
                if (element.paymentMethod == "tax") {
                  if (element.isTopup == false) {
                    taxAmount.value -= double.parse(element.amount.toString());
                  } else {
                    taxAmount.value += double.parse(element.amount.toString());
                  }
                } else {
                  if (element.isTopup == false) {
                    orderAmount.value -= double.parse(element.amount.toString());
                  } else {
                    orderAmount.value += double.parse(element.amount.toString());
                  }
                }
              },
            );
          }
        },
      );
    }

    await FireStoreUtils.getWithdrawHistory().then(
      (value) {
        if (value != null) {
          withdrawalList.value = value;
        }
      },
    );
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getPaymentMethod();
    isLoading.value = false;
  }

  getPaymentMethod() async {
    final _razorRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','razorpaySettings').maybeSingle();
    if (_razorRow != null) razorPayModel.value = RazorPayModel.fromJson(_razorRow['data'] ?? {});

    final _paypalRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','paypalSettings').maybeSingle();
    if (_paypalRow != null) paypalDataModel.value = PayPalModel.fromJson(_paypalRow['data'] ?? {});

    final _stripeRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','stripeSettings').maybeSingle();
    if (_stripeRow != null) stripeSettingData.value = StripeModel.fromJson(_stripeRow['data'] ?? {});

    final _fwRow = await Supabase.instance.client.from(CollectionName.settings).select('data').eq('key','flutterWave').maybeSingle();
    if (_fwRow != null) flutterWaveSettingData.value = FlutterWaveModel.fromJson(_fwRow['data'] ?? {});

    await FireStoreUtils.getWithdrawMethod().then(
      (value) {
        if (value != null) {
          withdrawMethodModel.value = value;
        }
      },
    );
  }
}
