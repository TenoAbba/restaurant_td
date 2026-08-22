import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/app/help_support_screen/help_support_screen.dart';
import 'package:restaurant_td/utils/preferences.dart';

/// Local notification service.
///
/// This app uses Supabase as its backend, so there is no Firebase Cloud
/// Messaging integration. Notifications are rendered locally through
/// `flutter_local_notifications` (triggered by in-app events / Supabase
/// realtime streams).
///
/// If a remote push provider is added later, feed its payload into
/// [showNotification] and keep using [handleMessageClick] for tap routing.
class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static bool _isInitialized = false;

  /// Initializes the local notification plugin, creates the Android channel
  /// and asks the user for notification permission.
  Future<void> initInfo() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handlePayload(response.payload, isBgApp: false);
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    _isInitialized = true;

    await _handleAppLaunchNotification();
  }

  /// Handles the case where the app was launched by tapping a notification.
  Future<void> _handleAppLaunchNotification() async {
    try {
      final NotificationAppLaunchDetails? details =
          await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        _handlePayload(details?.notificationResponse?.payload, isBgApp: true);
      }
    } catch (e) {
      log('getNotificationAppLaunchDetails error: $e');
    }
  }

  void _handlePayload(String? payload, {required bool isBgApp}) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        final String type = data['type']?.toString() ?? '';
        handleMessageClick(type: type, isBgApp: isBgApp);
      }
    } catch (e) {
      log('notification payload decode error: $e');
    }
  }

  /// Routes the user to the correct screen after a notification tap.
  Future<void> handleMessageClick({
    required String type,
    required bool isBgApp,
  }) async {
    if (type == 'admin_chat') {
      await Preferences.setBoolean(Preferences.isClickOnNotification, true);
      if (isBgApp == false) {
        Get.offAll(HelpSupportScreen(isNavigateViaNotification: true));
      }
    }
  }

  /// Displays a local notification.
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    int? id,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload == null ? null : jsonEncode(payload),
      );
    } catch (e) {
      log('showNotification error: $e');
    }
  }
}
