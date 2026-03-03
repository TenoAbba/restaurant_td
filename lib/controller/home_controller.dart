import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/order_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/service/audio_player_service.dart';
import 'package:restaurant_td/service/order_service.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  final OrderService _orderService = OrderService();

  RxBool isLoading = true.obs;
  Rx<TextEditingController> estimatedTimeController =
      TextEditingController().obs;
  RxInt selectedTabIndex = 0.obs;

  RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendermodel = VendorModel().obs;

  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  Future<void> getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) userModel.value = value;
    });

    if (userModel.value.vendorID != null &&
        userModel.value.vendorID!.isNotEmpty) {
      await FireStoreUtils.getVendorById(userModel.value.vendorID!)
          .then((vender) {
        if (vender?.id != null) vendermodel.value = vender!;
      });
      _listenToOrders();
    }
    isLoading.value = false;
  }

  void _listenToOrders() {
    _orderService
        .getOrdersStream(userModel.value.vendorID!)
        .listen((orders) async {
      allOrderList.value = orders;
      _filterOrders();
      await _handleOrderSound();
      update();
    });
  }

  void _filterOrders() {
    newOrderList.value =
        allOrderList.where((p0) => p0.status == Constant.orderPlaced).toList();
    acceptedOrderList.value = allOrderList
        .where((p0) => [
              Constant.orderAccepted,
              Constant.driverPending,
              Constant.driverRejected,
              Constant.orderShipped,
              Constant.orderInTransit
            ].contains(p0.status))
        .toList();
    completedOrderList.value = allOrderList
        .where((p0) => p0.status == Constant.orderCompleted)
        .toList();
    rejectedOrderList.value = allOrderList
        .where((p0) => p0.status == Constant.orderRejected)
        .toList();
    cancelledOrderList.value = allOrderList
        .where((p0) => p0.status == Constant.orderCancelled)
        .toList();
  }

  Future<void> _handleOrderSound() async {
    if (newOrderList.isNotEmpty) {
      log("PlaySound :::::: 11");
      await AudioPlayerService.playSound(true);
    } else {
      log("PlaySound :::::: 22");
      await AudioPlayerService.playSound(false);
    }
  }

  Future<void> getAllDriverList() async {
    await FireStoreUtils.getAvalibleDrivers().then((value) {
      if (value.isNotEmpty) driverUserList.value = value;
    });
    isLoading.value = false;
  }

  RxList<UserModel> driverUserList = <UserModel>[].obs;
  Rx<UserModel> selectDriverUser = UserModel().obs;
}
