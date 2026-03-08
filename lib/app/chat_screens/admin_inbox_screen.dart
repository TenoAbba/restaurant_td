import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/app/chat_screens/chat_screen.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/advertisement_model.dart';
import 'package:restaurant_td/models/inbox_model.dart';
import 'package:restaurant_td/models/vendor_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/responsive.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';
import 'package:restaurant_td/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:restaurant_td/widget/firebase_pagination/src/models/view_type.dart';

class AdminInboxScreen extends StatelessWidget {
  const AdminInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "Admin Chat Inbox".tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
      ),
      body: FirestorePagination(
        query: FirebaseFirestore.instance
            .collection(CollectionName.chat)
            .where("sender_receiver_id", arrayContains: FireStoreUtils.getCurrentUid())
            .where("chatType", isEqualTo: 'admin')
            .orderBy('createdAt', descending: true),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);
          return InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              ShowToastDialog.showLoader("Please wait".tr);
              VendorModel? vendorModel = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString());
              ShowToastDialog.closeLoader();

              Get.to(const ChatScreen(), arguments: {
                "senderName": vendorModel!.title,
                "senderId": Constant.userModel?.id,
                "senderProfileUrl": vendorModel.photo,
                "orderId": inboxModel.orderId,
                "receivedName": 'Admin',
                "receivedId": 'admin',
                "receivedProfileUrl": '',
                "token": null,
                "chatType": 'admin',
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Container(
                decoration: ShapeDecoration(
                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                      future: FireStoreUtils.getAdvertisementById(advertisementId: inboxModel.orderId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          AdvertisementModel advertisementModel = snapshot.data!;
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: NetworkImageWidget(
                                  imageUrl: advertisementModel.profileImage.toString(),
                                  fit: BoxFit.cover,
                                  height: Responsive.height(6, context),
                                  width: Responsive.width(12, context),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${advertisementModel.title}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.timestampToDate(inboxModel.createdAt!),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${inboxModel.lastMessage}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.medium,
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text(
                            "",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 14,
                              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                            ),
                          );
                        }
                      }),
                ),
              ),
            ),
          );
        },
        shrinkWrap: true,
        onEmpty: Constant.showEmptyView(message: "No Conversion found".tr),

        //Change types customerId
        initialLoader: Constant.loader(),
        // to fetch real-time data
        isLive: true,
        viewType: ViewType.list,
      ),
    );
  }
}
