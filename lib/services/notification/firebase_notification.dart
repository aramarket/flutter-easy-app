import 'package:aramarket/common/dialog_box_massages/snack_bar_massages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/default_route.dart';

import '../../features/shop/screens/brands/all_brands.dart';
import '../../routes/deeplink_get_router.dart';
import '../../routes/internal_routes.dart';
import 'local_notification.dart';

// Doc - https://firebase.google.com/docs/cloud-messaging/flutter/first-message?hl=en&authuser=0
class FirebaseNotification {
  //create a instance of firebase Messaging
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Static variable to hold the FCM token
  static String? fCMToken;

  //function to initialize notification
  static Future<void> initNotification() async {
    //Request permission form user
    await _firebaseMessaging.requestPermission();

    //Fetch the FCM token for this device
    fCMToken = await _firebaseMessaging.getToken();

    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    //   print("New token: $newToken");
    //   // Send the new token to your server.
    // });

    //Print Token
    if (kDebugMode) {
      print('Token ======= "$fCMToken"');
    }

    // Request permission (for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // ✅ Subscribe to topic
      await _firebaseMessaging.subscribeToTopic('all_users');
      // await FirebaseMessaging.instance.unsubscribeFromTopic('all_users'); for unsubscribe
    }

    //initPushNotification
    initPushNotification();
  }

  // Handel Msg
  static void handleMassage(RemoteMessage? message) {
    if (message == null) return;

    // Check for URL in both data and notification
    final url = message.data['url'] ?? message.data['click_action'];
    if (url != null) {
      // Use Get.key.currentState to push route if app is already running
      if (Get.key.currentState != null) {
        InternalAppRoutes.handleInternalRoute(url: url);
      } else {
        // For terminated state, we need to handle it differently
        // This will be processed once the app is fully initialized
        Future.microtask(() {
          InternalAppRoutes.handleInternalRoute(url: url);
        });
      }
    }
  }


  static Future<void> showNotification(RemoteMessage? message) async {

    if (message == null) return;
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String? imageUrl = message.notification?.android?.imageUrl ?? message.data['image'];

    NotificationDetails notificationDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      notificationDetails = await LocalNotificationServices.getNotificationDetailsWithImage(imageUrl);
    } else {
      notificationDetails = LocalNotificationServices.getPlatformChannelSpecifics();
    }

    LocalNotificationServices.localNotificationsPlugin.show(
      notificationId,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data['url'],
    );
  }


  // function initiate background massage
  static Future initPushNotification() async {

    // To handle messages while your application is in the foreground, listen to the onMessage stream.
    // Message received in foreground
    FirebaseMessaging.onMessage.listen(showNotification);

    // To handle messages while your application is running in the background, listen to the onMessageOpenedApp stream.
    // Message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMassage);

    // Used to handle the initial message payload when the app is opened from a terminated state due to a notification click.
    // Message opened from terminated state
    _firebaseMessaging.getInitialMessage().then(handleMassage);
  }

}