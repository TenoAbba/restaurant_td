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
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminInboxScreen extends StatefulWidget {
  const AdminInboxScreen({super.key});
  @override
  State<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends State<AdminInboxScreen> {
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
            r['chatType'] == 'admin').toList());
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: Text("Admin Chat Inbox".tr,
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
              return InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  ShowToastDialog.showLoader("Please wait".tr);
                  final vendorModel = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString());
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FutureBuilder<AdvertisementModel?>(
                        future: inboxModel.orderId != null
                            ? FireStoreUtils.getAdvertisementById(advertisementId: inboxModel.orderId!)
                            : Future.value(null),
                        builder: (context, snap) {
                          final adv = snap.data;
                          return Row(children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: NetworkImageWidget(
                                imageUrl: adv?.profileImage ?? '',
                                fit: BoxFit.cover,
                                height: Responsive.height(6, context),
                                width: Responsive.width(12, context))),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(adv?.title ?? '',
                                    style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800))),
                                if (inboxModel.createdAt != null)
                                  Text(Constant.timestampToDate(inboxModel.createdAt!),
                                      style: TextStyle(fontFamily: AppThemeData.regular, fontSize: 14,
                                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500)),
                              ]),
                              const SizedBox(height: 5),
                              Text("${inboxModel.lastMessage}",
                                  style: TextStyle(fontFamily: AppThemeData.medium, fontSize: 14,
                                      color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700)),
                            ])),
                          ]);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
