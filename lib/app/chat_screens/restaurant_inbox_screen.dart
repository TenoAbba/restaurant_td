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
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantInboxScreen extends StatefulWidget {
  const RestaurantInboxScreen({super.key});
  @override
  State<RestaurantInboxScreen> createState() => _RestaurantInboxScreenState();
}

class _RestaurantInboxScreenState extends State<RestaurantInboxScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    final uid = FireStoreUtils.getCurrentUid();
    _stream = Supabase.instance.client
        .from(CollectionName.chat)
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: false)
        .map((rows) => rows.where((r) =>
            (r['sender_receiver_id'] as List?)?.contains(uid) == true &&
            r['chatType'] == Constant.userRoleVendor &&
            r['type'] == 'orderChat').toList());
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: Text("Restaurant Inbox".tr,
            style: TextStyle(fontFamily: AppThemeData.medium, fontSize: 16,
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Constant.loader();
          final items = snapshot.data ?? [];
          if (items.isEmpty) return Constant.showEmptyView(message: "No Conversation found".tr);
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final inboxModel = InboxModel.fromJson(items[index]);
              final otherId = inboxModel.receiverId == FireStoreUtils.getCurrentUid()
                  ? inboxModel.senderId! : inboxModel.receiverId!;
              return FutureBuilder<UserModel?>(
                future: FireStoreUtils.getUserProfile(otherId),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final customer = snap.data;
                  return InkWell(
                    onTap: () async {
                      ShowToastDialog.showLoader("Please wait".tr);
                      final restaurant = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
                      ShowToastDialog.closeLoader();
                      Get.to(const ChatScreen(), arguments: {
                        "senderName": restaurant!.fullName(),
                        "senderId": restaurant.id,
                        "senderProfileUrl": restaurant.profilePictureURL,
                        "receivedName": customer?.fullName(),
                        "receivedId": customer?.id,
                        "receivedProfileUrl": customer?.profilePictureURL,
                        "orderId": inboxModel.orderId,
                        "token": restaurant.fcmToken,
                        "chatType": Constant.userRoleVendor,
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: NetworkImageWidget(
                                imageUrl: customer?.profilePictureURL ?? '',
                                fit: BoxFit.cover,
                                height: Responsive.height(6, context),
                                width: Responsive.width(12, context))),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text("${customer?.fullName()}",
                                    style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800))),
                                if (inboxModel.createdAt != null)
                                  Text(Constant.timestampToDate(inboxModel.createdAt!),
                                      style: TextStyle(fontFamily: AppThemeData.regular, fontSize: 14,
                                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500)),
                              ]),
                              const SizedBox(height: 5),
                              Text("Order".tr + " " + Constant.orderId(orderId: inboxModel.orderId.toString()),
                                  style: TextStyle(fontFamily: AppThemeData.medium, fontSize: 14,
                                      color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700)),
                            ])),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
