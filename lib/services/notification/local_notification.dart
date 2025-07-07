import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../routes/internal_routes.dart';


class LocalNotificationServices {
  // Initialize FlutterLocalNotificationsPlugin
  static FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //Initialize Settings for android and ios
  static var initializationSettingsAndroid = const AndroidInitializationSettings("@mipmap/ic_launcher");
  static var initializationSettingsIOS = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestCriticalPermission: true,
    requestSoundPermission: true,
  );

  //Initialize Settings for android and ios
  static final InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Function to create notification details
  static NotificationDetails getPlatformChannelSpecifics() {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'pushNotificationAppName', // id (MUST match your code)
      'Push Notifications', // name,
      channelDescription: 'This channel is used for important notifications.',
      enableLights: true,
      enableVibration: true,
      priority: Priority.max,
      importance: Importance.max,
      icon: '@mipmap/ic_launcher', // Use app icon as small icon
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  static Future<NotificationDetails> getNotificationDetailsWithImage(String imageUrl) async {
    final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: null, // title will be passed in show()
      summaryText: null,  // body will be passed in show()
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pushNotificationAppName', // id (MUST match your code)
      'Push Notifications', // name,
      channelDescription: 'This channel is used for important notifications.',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Use app icon as small icon
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  static void checkNotificationAppLunch() async {
    NotificationAppLaunchDetails? details = await localNotificationsPlugin.getNotificationAppLaunchDetails();

    if(details != null) {
      if(details.didNotificationLaunchApp){
        var response = details.notificationResponse;
        if(response != null){
          InternalAppRoutes.handleInternalRoute(url: response.payload.toString());
        }
      }
    }
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName.jpg';

      final Uri uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Or return a fallback file path if needed
    }
  }


}
