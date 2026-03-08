import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_td/constant/send_notification.dart';
import 'package:restaurant_td/models/conversation_model.dart';
import 'package:restaurant_td/models/inbox_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  Rx<TextEditingController> messageController = TextEditingController().obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    if (scrollController.hasClients) {
      Timer(const Duration(milliseconds: 500), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
    }
    getArgument();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxString orderId = "".obs;
  RxString receivedId = "".obs;
  RxString receivedName = "".obs;
  RxString receivedProfileUrl = "".obs;
  RxString senderId = "".obs;
  RxString senderName = "".obs;
  RxString senderProfileUrl = "".obs;
  RxString token = "".obs;
  RxString chatType = "".obs;
  Rx<UserModel?> receiverUser = UserModel().obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderId.value = argumentData['orderId'];
      receivedId.value = argumentData['receivedId'];
      receivedName.value = argumentData['receivedName'];
      receivedProfileUrl.value = argumentData['receivedProfileUrl'] ?? "";
      senderId.value = argumentData['senderId'];
      senderName.value = argumentData['senderName'];
      senderProfileUrl.value = argumentData['senderProfileUrl'] ?? "";
      token.value = argumentData['token'];
      chatType.value = argumentData['chatType'];
      receiverUser.value = await FireStoreUtils.getUserProfile(receivedId.value);
    }
    setSeen();
    isLoading.value = false;
  }

  Future<void> setSeen() async {
    FireStoreUtils.setSeenChatForOrder(orderId: orderId.value);
  }

  Future<void> sendMessage(String message, Url? url, String videoThumbnail, String messageType) async {
    List<String> senderReceiverId = [receivedId.value, senderId.value];
    InboxModel inboxModel = InboxModel(
        chatType: chatType.value,
        senderReceiverId: senderReceiverId,
        lastSenderId: senderId.value,
        senderId: senderId.value,
        receiverId: receivedId.value,
        createdAt: DateTime.now(),
        orderId: orderId.value,
        lastMessage: messageController.value.text,
        lastMessageType: messageType,
        type: chatType.value == 'admin' ? 'admin' : 'orderChat');

    FireStoreUtils.addInbox(inboxModel);

    ConversationModel conversationModel = ConversationModel(
        id: const Uuid().v4(),
        message: message,
        senderId: FireStoreUtils.getCurrentUid(),
        receiverId: receivedId.value,
        createdAt: DateTime.now(),
        url: url,
        orderId: orderId.value,
        messageType: messageType,
        videoThumbnail: videoThumbnail,
        seen: false);

    if (url != null) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent a message".tr;
      } else if (url.mime.contains('video')) {
        conversationModel.message = "Sent a video".tr;
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "Sent a audio".tr;
      }
    }

    FireStoreUtils.addChat(conversationModel);
    if (receiverUser.value?.fcmToken != null) {
      SendNotification.sendChatFcmMessage(receivedName.value, conversationModel.message.toString(), receiverUser.value?.fcmToken ?? '', {});
    }
  }

  final ImagePicker imagePicker = ImagePicker();

// Future pickFile({required ImageSource source}) async {
//   try {
//     XFile? image = await imagePicker.pickImage(source: source);
//     if (image == null) return;
//     Url url = await FireStoreUtils.uploadChatImageToFireStorage(File(image.path), Get.context!);
//     sendMessage('', url, '', 'image');
//     Get.back();
//   } on PlatformException catch (e) {
//     ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
//   }
// }
}
