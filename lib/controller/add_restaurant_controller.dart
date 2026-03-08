import 'dart:io';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/models/vendor_category_model.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/models/zone_model.dart';
import 'package:restaurant_td/service/supabase_service.dart';
import 'package:restaurant_td/service/supabase_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRestaurantController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isAddressEnable = false.obs;
  RxBool isEnableDeliverySettings = true.obs;
  final myKey1 = GlobalKey<DropdownSearchState<VendorCategoryModel>>();

  Rx<TextEditingController> restaurantNameController =
      TextEditingController().obs;
  Rx<TextEditingController> restaurantDescriptionController =
      TextEditingController().obs;
  Rx<TextEditingController> mobileNumberController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;

  Rx<TextEditingController> chargePerKmController = TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesController =
      TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesWithinKMController =
      TextEditingController().obs;

  LatLng? selectedLocation;

  RxList images = <dynamic>[].obs;

  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  RxList<String> quartierList = <String>[].obs;
  RxString selectedQuartier = "".obs;

  // Rx<VendorCategoryModel> selectedCategory = VendorCategoryModel().obs;
  RxList selectedService = [].obs;

  RxList<VendorCategoryModel> selectedCategories = <VendorCategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getRestaurant();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  RxBool isSelfDelivery = false.obs;

  Future<void> getRestaurant() async {
    try {
      await SupabaseService.getUserProfile(SupabaseService.getCurrentUid())
          .then((model) {
        if (model != null) {
          userModel.value = UserModel.fromJson(model);
        }
      });

      await SupabaseService.getVendorCategoryById().then((value) {
        if (value != null) {
          vendorCategoryList.value = (value as List)
              .map((item) => VendorCategoryModel.fromJson(item))
              .toList();
        }
      });

      await SupabaseService.getZone().then((value) {
        if (value != null) {
          zoneList.value =
              (value as List).map((item) => ZoneModel.fromJson(item)).toList();
        }
      });
      if (Constant.userModel?.vendorID != null &&
          Constant.userModel?.vendorID?.isNotEmpty == true) {
        await SupabaseService.getVendorById(
                Constant.userModel!.vendorID.toString())
            .then(
          (value) {
            if (value != null) {
              vendorModel.value = VendorModel.fromJson(value);

              restaurantNameController.value.text =
                  vendorModel.value.title.toString();
              restaurantDescriptionController.value.text =
                  vendorModel.value.description.toString();
              mobileNumberController.value.text =
                  vendorModel.value.phonenumber.toString();

              if (vendorModel.value.quartier != null &&
                  vendorModel.value.quartier!.isNotEmpty) {
                selectedQuartier.value = vendorModel.value.quartier!;
              }
              addressController.value.text =
                  vendorModel.value.location.toString();
              isSelfDelivery.value = vendorModel.value.isSelfDelivery ?? false;
              if (addressController.value.text.isNotEmpty) {
                isAddressEnable.value = true;
              }
              selectedLocation = LatLng(
                  vendorModel.value.latitude!, vendorModel.value.longitude!);
              for (var element in vendorModel.value.photos!) {
                images.add(element);
              }

              for (var element in zoneList) {
                if (element.id == vendorModel.value.zoneId) {
                  selectedZone.value = element;
                }
              }

              if (vendorModel.value.categoryID!.isNotEmpty) {
                selectedCategories.value = vendorCategoryList
                    .where((category) =>
                        vendorModel.value.categoryID!.contains(category.id))
                    .toList();
              }

              vendorModel.value.filters!.toJson().forEach((key, value) {
                if (value.contains("Yes")) {
                  selectedService.add(key);
                }
              });
            }
          },
        );
      }

      await SupabaseService.getDelivery().then((value) {
        if (value != null) {
          deliveryChargeModel.value = DeliveryCharge.fromJson(value);
          isEnableDeliverySettings.value =
              deliveryChargeModel.value.vendorCanModify ?? false;
          if (value['vendorCanModify'] == true) {
            if (vendorModel.value.deliveryCharge != null) {
              chargePerKmController.value.text = vendorModel
                  .value.deliveryCharge!.deliveryChargesPerKm
                  .toString();
              minDeliveryChargesController.value.text = vendorModel
                  .value.deliveryCharge!.minimumDeliveryCharges
                  .toString();
              minDeliveryChargesWithinKMController.value.text = vendorModel
                  .value.deliveryCharge!.minimumDeliveryChargesWithinKm
                  .toString();
            }
          } else {
            chargePerKmController.value.text =
                deliveryChargeModel.value.deliveryChargesPerKm.toString();
            minDeliveryChargesController.value.text =
                deliveryChargeModel.value.minimumDeliveryCharges.toString();
            minDeliveryChargesWithinKMController.value.text =
                deliveryChargeModel.value.minimumDeliveryChargesWithinKm
                    .toString();
          }
        }
      });
    } catch (e) {
      print(e);
    }

    isLoading.value = false;
  }

  /// guard to avoid multiple submissions
  RxBool isSubmitting = false.obs;

  saveDetails() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      log('[SAVE] start');
      ShowToastDialog.showLoader("Validating details...".tr);

      // Enhanced validation with specific error messages
      if (restaurantNameController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter restaurant name".tr);
        return;
      }

      if (restaurantDescriptionController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter description".tr);
        return;
      }

      if (mobileNumberController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter phone number".tr);
        return;
      }

      if (addressController.value.text.trim().isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please enter address".tr);
        return;
      }

      if (selectedZone.value.id == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select zone".tr);
        return;
      }

      if ((selectedZone.value.quartiers ?? []).isNotEmpty &&
          selectedQuartier.value.isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select quartier".tr);
        return;
      }

      if (selectedCategories.isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select category".tr);
        return;
      }

      if (selectedLocation == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Please select location on map".tr);
        return;
      }

      if (!Constant.isWithinChad(selectedLocation!)) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "Restaurants must be located within the Republic of Chad.".tr);
        return;
      }

      if (!Constant.isPointInPolygon(
          selectedLocation!, selectedZone.value.area!)) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "The chosen area is outside the selected zone.".tr);
        return;
      }

      // Validate numeric fields
      double deliveryChargesPerKm;
      double minimumDeliveryCharges;
      double minimumDeliveryChargesWithinKm;

      try {
        deliveryChargesPerKm =
            double.parse(chargePerKmController.value.text.trim());
        minimumDeliveryCharges =
            double.parse(minDeliveryChargesController.value.text.trim());
        minimumDeliveryChargesWithinKm = double.parse(
            minDeliveryChargesWithinKMController.value.text.trim());
      } catch (e) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "Please enter valid numeric values for delivery charges".tr);
        return;
      }

      ShowToastDialog.closeLoader();
      ShowToastDialog.showLoader("Saving restaurant details...".tr);

      // Process images (timeouts added so we can't hang forever)
      await _processImages().timeout(const Duration(seconds: 30),
          onTimeout: () {
        throw Exception('Image upload timed out');
      });

      // Build delivery charge model
      DeliveryCharge deliveryChargeModel = DeliveryCharge(
        vendorCanModify: true,
        deliveryChargesPerKm: deliveryChargesPerKm,
        minimumDeliveryCharges: minimumDeliveryCharges,
        minimumDeliveryChargesWithinKm: minimumDeliveryChargesWithinKm,
      );

      // Build vendor model
      await _buildVendorModel(deliveryChargeModel);

      // Save to database (timeout as well)
      bool success = await _saveVendorToDatabase()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Vendor save timed out');
      });

      if (success) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Restaurant details saved successfully!".tr);
        log('[SAVE] success');
        // optional: navigate back or refresh screen here
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "Failed to save restaurant details. Please try again.".tr);
        log('[SAVE] returned false');
      }
    } catch (error, stackTrace) {
      ShowToastDialog.closeLoader();
      log("Error in saveDetails: $error");
      log("Stack trace: $stackTrace");
      ShowToastDialog.showToast(
          "An error occurred while saving. Please check your internet connection and try again."
              .tr);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _processImages() async {
    // copy list to avoid modifying while iterating
    final currentImages = List.from(images);
    for (int i = 0; i < currentImages.length; i++) {
      final element = currentImages[i];
      if (element is XFile) {
        try {
          String url = await SupabaseStorageService.uploadRestaurantImage(
            File(element.path),
            "restaurants/${SupabaseService.getCurrentUid()}/${DateTime.now().millisecondsSinceEpoch}",
            File(element.path).path.split('/').last,
          ).timeout(const Duration(seconds: 30));
          // replace only after successful upload
          int index = images.indexWhere((e) => e == element);
          if (index != -1) {
            images[index] = url;
          }
        } catch (error) {
          // bubble up so outer try/catch handles it
          throw Exception("Failed to upload image: ${error.toString()}");
        }
      }
    }
  }

  Future<void> _buildVendorModel(DeliveryCharge deliveryChargeModel) async {
    filter();

    if (vendorModel.value.id == null) {
      vendorModel.value = VendorModel();
    }

    vendorModel.value.id = Constant.userModel?.vendorID;
    vendorModel.value.author = Constant.userModel!.id;
    vendorModel.value.authorName = Constant.userModel!.firstName;
    vendorModel.value.authorProfilePic = Constant.userModel!.profilePictureURL;

    vendorModel.value.categoryID =
        selectedCategories.map((e) => e.id ?? '').toList();
    vendorModel.value.categoryTitle =
        selectedCategories.map((e) => e.title ?? '').toList();
    vendorModel.value.description =
        restaurantDescriptionController.value.text.trim();
    vendorModel.value.phonenumber = mobileNumberController.value.text.trim();
    vendorModel.value.filters = Filters.fromJson(filters);
    vendorModel.value.location = addressController.value.text.trim();
    vendorModel.value.latitude = selectedLocation!.latitude;
    vendorModel.value.longitude = selectedLocation!.longitude;
    vendorModel.value.photos = images;
    vendorModel.value.photo = images.isNotEmpty ? images.first : null;
    vendorModel.value.deliveryCharge = deliveryChargeModel;
    vendorModel.value.title = restaurantNameController.value.text.trim();
    vendorModel.value.zoneId = selectedZone.value.id;
    vendorModel.value.quartier = selectedQuartier.value;
    vendorModel.value.isSelfDelivery = isSelfDelivery.value;

    if ((Constant.adminCommission?.isEnabled == true ||
            Constant.isSubscriptionModelApplied == true) &&
        Constant.userModel?.role != Constant.userRoleEmployee) {
      vendorModel.value.subscriptionPlanId = userModel.value.subscriptionPlanId;
      vendorModel.value.subscriptionPlan = userModel.value.subscriptionPlan;
      vendorModel.value.subscriptionExpiryDate =
          userModel.value.subscriptionExpiryDate;
      vendorModel.value.subscriptionTotalOrders =
          userModel.value.subscriptionPlan?.orderLimit;
    }

    if (Constant.userModel?.vendorID?.isEmpty == true) {
      vendorModel.value.adminCommission = Constant.adminCommission;
      vendorModel.value.workingHours = [
        WorkingHours(
            day: 'Monday'.tr, timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Tuesday'.tr,
            timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Wednesday'.tr,
            timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Thursday'.tr,
            timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Friday'.tr, timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Saturday'.tr,
            timeslot: [Timeslot(from: '00:00', to: '23:59')]),
        WorkingHours(
            day: 'Sunday'.tr, timeslot: [Timeslot(from: '00:00', to: '23:59')])
      ];
    }
  }

  Future<bool> _saveVendorToDatabase() async {
    try {
      if (Constant.userModel?.vendorID?.isNotEmpty == true) {
        // Update existing vendor
        await SupabaseService.updateVendor(vendorModel.value.toJson());
        return true;
      } else {
        // Create new vendor
        Map<String, dynamic>? result =
            await SupabaseService.createVendor(vendorModel.value.toJson());
        return result != null;
      }
    } catch (error) {
      log("Database save error: $error");
      rethrow;
    }
  }

  Map<String, dynamic> filters = {};

  void filter() {
    if (selectedService.contains('Good for Breakfast')) {
      filters['Good for Breakfast'] = 'Yes';
    } else {
      filters['Good for Breakfast'] = 'No';
    }
    if (selectedService.contains('Good for Lunch')) {
      filters['Good for Lunch'] = 'Yes';
    } else {
      filters['Good for Lunch'] = 'No';
    }

    if (selectedService.contains('Good for Dinner')) {
      filters['Good for Dinner'] = 'Yes';
    } else {
      filters['Good for Dinner'] = 'No';
    }

    if (selectedService.contains('Takes Reservations')) {
      filters['Takes Reservations'] = 'Yes';
    } else {
      filters['Takes Reservations'] = 'No';
    }

    if (selectedService.contains('Live Music')) {
      filters['Live Music'] = 'Yes';
    } else {
      filters['Live Music'] = 'No';
    }

    if (selectedService.contains('Outdoor Seating')) {
      filters['Outdoor Seating'] = 'Yes';
    } else {
      filters['Outdoor Seating'] = 'No';
    }

    if (selectedService.contains('Free Wi-Fi')) {
      filters['Free Wi-Fi'] = 'Yes';
    } else {
      filters['Free Wi-Fi'] = 'No';
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick :".tr} \n $e");
    }
  }
}
