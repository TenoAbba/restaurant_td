import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/app/chat_screens/chat_screen.dart';
import 'package:restaurant_td/constant/collection_name.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:restaurant_td/models/inbox_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/responsive.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/network_image_widget.dart';
import 'package:restaurant_td/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:restaurant_td/widget/firebase_pagination/src/models/view_type.dart';

class RestaurantInboxScreen extends StatelessWidget {
  const RestaurantInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem()
            ? AppThemeData.surfaceDark
            : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "Restaurant Inbox".tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
          ),
        ),
      ),
      body: FirestorePagination(
        query: FirebaseFirestore.instance
            .collection(CollectionName.chat)
            .where("sender_receiver_id",
                arrayContains: FireStoreUtils.getCurrentUid())
            .where('chatType', isEqualTo: Constant.userRoleVendor)
            .where('type', isEqualTo: 'orderChat')
            .orderBy('createdAt', descending: true),
        //item builder type is compulsory.
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);

          return FutureBuilder<UserModel?>(
              future: FireStoreUtils.getUserProfile(
                  inboxModel.receiverId == FireStoreUtils.getCurrentUid()
                      ? inboxModel.senderId!
                      : inboxModel.receiverId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                } else {
                  UserModel? customer = snapshot.data;
                  return InkWell(
                    onTap: () async {
                      ShowToastDialog.showLoader("Please wait".tr);
                      UserModel? restaurant =
                          await FireStoreUtils.getUserProfile(
                              FireStoreUtils.getCurrentUid());

                      ShowToastDialog.closeLoader();

                      Get.to(const ChatScreen(), arguments: {
                        "senderName": '${restaurant!.fullName()}',
                        "senderId": restaurant.id,
                        "senderProfileUrl": restaurant.profilePictureURL,
                        "receivedName": customer?.fullName(),
                        "restaurantId": customer?.id,
                        "receivedProfileUrl": customer?.profilePictureURL,
                        "orderId": inboxModel.orderId,
                        "token": restaurant.fcmToken,
                        "chatType": Constant.userRoleVendor,
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: themeChange.getThem()
                              ? AppThemeData.grey900
                              : AppThemeData.grey50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: NetworkImageWidget(
                                  imageUrl: customer?.profilePictureURL ?? '',
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
                                            "${customer?.fullName()}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              fontSize: 16,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey100
                                                  : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.timestampToDate(
                                              inboxModel.createdAt!),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            fontSize: 16,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${"Order".tr} ${Constant.orderId(orderId: inboxModel.orderId.toString())}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.medium,
                                        fontSize: 14,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey200
                                            : AppThemeData.grey700,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              });
        },

        shrinkWrap: true,
        onEmpty: Constant.showEmptyView(message: "No Conversion found".tr),
        // orderBy is compulsory to enable pagination
        //Change types customerId
        viewType: ViewType.list,
        initialLoader: Constant.loader(),
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
