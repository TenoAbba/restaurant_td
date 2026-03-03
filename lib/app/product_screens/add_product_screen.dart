import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/controller/add_product_controller.dart';
import 'package:restaurant_td/models/product_model.dart';
import 'package:restaurant_td/models/vendor_category_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/responsive.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/themes/text_field_widget.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddProductController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppThemeData.secondary300,
                    centerTitle: false,
                    iconTheme: IconThemeData(
                      color: themeChange.getThem()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                    ),
                    title: Text(
                      controller.productModel.value.id == null
                          ? "Add Product".tr
                          : "Edit product".tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey900
                              : AppThemeData.grey50,
                          fontSize: 18,
                          fontFamily: AppThemeData.medium),
                    ),
                    actions: const [],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.danger600
                                  : AppThemeData.danger50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Product prices include a 15% admin commission. For instance, a 1000XAF product will cost 1150XAF for the customer.\n 15% will be applied automatically."
                                    .tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.danger200
                                        : AppThemeData.danger400,
                                    fontSize: 14,
                                    fontFamily: AppThemeData.medium),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DottedBorder(
                            options: RectDottedBorderOptions(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey50,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: SizedBox(
                                  height: Responsive.height(20, context),
                                  width: Responsive.width(90, context),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/ic_folder.svg',
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Choose a image and upload here".tr,
                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey100
                                                : AppThemeData.grey800,
                                            fontFamily: AppThemeData.medium,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "JPEG, PNG".tr,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey700,
                                            fontFamily: AppThemeData.regular),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Brows Image".tr,
                                        color: AppThemeData.secondary50,
                                        width: 30,
                                        height: 5,
                                        textColor: AppThemeData.secondary300,
                                        onPress: () async {
                                          buildBottomSheet(context, controller);
                                        },
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          controller.images.isEmpty
                              ? const SizedBox()
                              : SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    itemCount: controller.images.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              child: controller.images[index]
                                                          .runtimeType ==
                                                      XFile
                                                  ? Image.file(
                                                      File(controller
                                                          .images[index].path),
                                                      fit: BoxFit.cover,
                                                      width: 80,
                                                      height: 80,
                                                    )
                                                  : NetworkImageWidget(
                                                      imageUrl: controller
                                                          .images[index],
                                                      fit: BoxFit.cover,
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  controller.images
                                                      .removeAt(index);
                                                },
                                                child: const Icon(
                                                  Icons.remove_circle,
                                                  size: 28,
                                                  color: AppThemeData.danger300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              TextFieldWidget(
                                title: 'Product Title'.tr,
                                controller:
                                    controller.productTitleController.value,
                                hintText: 'Enter product title'.tr,
                              ),
                              TextFieldWidget(
                                title: 'Product Description'.tr,
                                controller: controller
                                    .productDescriptionController.value,
                                hintText: 'Enter short description here....'.tr,
                                maxLine: 5,
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Product Categories".tr,
                                      style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 14,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey100
                                              : AppThemeData.grey800)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  DropdownButtonFormField<VendorCategoryModel>(
                                      hint: Text(
                                        'Select Product Categories'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey700,
                                          fontFamily: AppThemeData.regular,
                                        ),
                                      ),
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      decoration: InputDecoration(
                                        errorStyle:
                                            const TextStyle(color: Colors.red),
                                        isDense: true,
                                        filled: true,
                                        fillColor: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        disabledBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900
                                                  : AppThemeData.grey50,
                                              width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.secondary300
                                                  : AppThemeData.secondary300,
                                              width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900
                                                  : AppThemeData.grey50,
                                              width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900
                                                  : AppThemeData.grey50,
                                              width: 1),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900
                                                  : AppThemeData.grey50,
                                              width: 1),
                                        ),
                                      ),
                                      value: controller.selectedProductCategory
                                                  .value.id ==
                                              null
                                          ? null
                                          : controller
                                              .selectedProductCategory.value,
                                      onChanged: (value) {
                                        controller.selectedProductCategory
                                            .value = value!;
                                        controller.update();
                                      },
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.medium),
                                      items: controller.vendorCategoryList
                                          .map((item) {
                                        return DropdownMenuItem<
                                            VendorCategoryModel>(
                                          value: item,
                                          child: Text(item.title.toString()),
                                        );
                                      }).toList()),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              Text(
                                "Prices".tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 18),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          const Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Regular Price'.tr,
                                  controller:
                                      controller.regularPriceController.value,
                                  hintText: 'Enter Regular Price'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]')),
                                  ],
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Text(
                                      "${Constant.currencyModel!.symbol}".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Discounted Price'.tr,
                                  controller: controller
                                      .discountedPriceController.value,
                                  hintText: 'Enter Discounted Price'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]')),
                                  ],
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Text(
                                      "${Constant.currencyModel!.symbol}".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "Your item Price will be display like this. "
                                      .tr,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey100
                                          : AppThemeData.grey800,
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 12),
                                ),
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (controller.discountPrice.value == 0.0
                                              ? Constant.amountShow(
                                                  amount: "0.0")
                                              : Constant.amountShow(
                                                  amount: controller
                                                      .discountPrice.value
                                                      .toString()))
                                          .tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary300
                                              : AppThemeData.secondary300,
                                          fontFamily: AppThemeData.medium,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      Constant.amountShow(
                                          amount: controller.regularPrice.value
                                              .toString()),
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey500
                                              : AppThemeData.grey400,
                                          fontFamily: AppThemeData.medium,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldWidget(
                            title: 'Quantity'.tr,
                            controller:
                                controller.productQuantityController.value,
                            hintText: 'Enter Quantity'.tr,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9-.]')),
                            ],
                            textInputType: TextInputType.text,
                          ),
                          Text(
                            "-1 to your product quantity is unlimited".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.danger300
                                    : AppThemeData.danger300,
                                fontFamily: AppThemeData.medium,
                                fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Product Type and Takeaway options".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontFamily: AppThemeData.medium,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Pure veg.".tr,
                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                            fontFamily: AppThemeData.medium,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        activeTrackColor:
                                            AppThemeData.secondary300,
                                        value: controller.isPureVeg.value,
                                        onChanged: (value) {
                                          if (controller.isNonVeg.value ==
                                              true) {
                                            controller.isPureVeg.value = value;
                                          }
                                          if (controller.isPureVeg.value ==
                                              true) {
                                            controller.isNonVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Non veg.".tr,
                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                            fontFamily: AppThemeData.medium,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        activeTrackColor:
                                            AppThemeData.secondary300,
                                        value: controller.isNonVeg.value,
                                        onChanged: (value) {
                                          if (controller.isPureVeg.value ==
                                              true) {
                                            controller.isNonVeg.value = value;
                                          }

                                          if (controller.isNonVeg.value ==
                                              true) {
                                            controller.isPureVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Enable Takeaway option".tr,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey900,
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 18),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  activeTrackColor: AppThemeData.secondary300,
                                  value: controller.takeAway.value,
                                  onChanged: (value) {
                                    controller.takeAway.value = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          Text(
                            "Specifications and Addons".tr,
                            style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontFamily: AppThemeData.medium,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Specifications".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.medium,
                                          fontSize: 16),
                                    ),
                                  ),
                                  InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        controller.specificationList.add(
                                            ProductSpecificationModel(
                                                lable: '', value: ''));
                                      },
                                      child: SvgPicture.asset(
                                          "assets/icons/ic_add_one.svg"))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: controller.specificationList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item =
                                      controller.specificationList[index];
                                  return Padding(
                                    key: ValueKey(
                                        item), // ensures correct rebuild
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFieldWidget(
                                            key: ValueKey('label_$index'),
                                            initialValue: item.lable,
                                            title: 'Title'.tr,
                                            hintText: 'Enter Title'.tr,
                                            onchange: (value) {
                                              controller
                                                  .specificationList[index]
                                                  .lable = value;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFieldWidget(
                                            key: ValueKey('value_$index'),
                                            initialValue: item.value,
                                            title: 'Value'.tr,
                                            hintText: 'Enter Value'.tr,
                                            onchange: (value) {
                                              controller
                                                  .specificationList[index]
                                                  .value = value;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              controller.specificationList
                                                  .removeAt(index);
                                            },
                                            child: Icon(Icons.remove_circle,
                                                color: AppThemeData.danger300)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Addons".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.medium,
                                          fontSize: 16),
                                    ),
                                  ),
                                  InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        controller.addonsList.add(
                                            ProductSpecificationModel(
                                                lable: '', value: ''));
                                      },
                                      child: SvgPicture.asset(
                                          "assets/icons/ic_add_one.svg"))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.addonsList.length,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final addon = controller.addonsList[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFieldWidget(
                                            key: ValueKey('addon_label_$index'),
                                            title: 'Title'.tr,
                                            hintText: 'Enter Title'.tr,
                                            initialValue: addon.lable,
                                            onchange: (value) {
                                              controller.addonsList[index]
                                                  .lable = value;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextFieldWidget(
                                            key: ValueKey('addon_value_$index'),
                                            title: 'Price'.tr,
                                            hintText: 'Enter Price'.tr,
                                            initialValue: addon.value,
                                            prefix: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              child: Text(
                                                "${Constant.currencyModel!.symbol}"
                                                    .tr,
                                                style: TextStyle(
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('[0-9]')),
                                            ],
                                            textInputType: const TextInputType
                                                .numberWithOptions(
                                                signed: true, decimal: true),
                                            onchange: (value) {
                                              controller.addonsList[index]
                                                  .value = value;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              controller.addonsList
                                                  .removeAt(index);
                                            },
                                            child: Icon(Icons.remove_circle,
                                                color: AppThemeData.danger300)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: Container(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedButtonFill(
                        title: "Save Details".tr,
                        height: 5.5,
                        color: themeChange.getThem()
                            ? AppThemeData.secondary300
                            : AppThemeData.secondary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          controller.saveDetails();
                        },
                      ),
                    ),
                  ),
                );
        });
  }

  Future buildBottomSheet(
      BuildContext context, AddProductController controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontFamily: AppThemeData.bold,
                          fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(
                                    source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(
                                    source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Gallery".tr),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
