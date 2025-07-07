import 'package:aramarket/utils/helpers/navigation_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/general_bindings.dart';
import 'features/settings/app_settings.dart';

import 'firebase_options.dart';
import 'routes/external_routes.dart';
import 'routes/internal_routes.dart';
import 'services/firebase_analytics/firebase_analytics.dart';
import 'services/notification/firebase_notification.dart';
import 'services/notification/local_notification.dart';
import 'utils/cache/cache.dart';
import 'utils/theme/theme.dart';
import 'utils/theme/theme_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  // Ensure initialized BEFORE using any Firebase services
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseNotification.showNotification(message);
  // FirebaseNotification.showNotification(message);
  // print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load env variable
  await dotenv.load(fileName: ".env");

  // GetX Local Storage
  await GetStorage.init();

  await CacheHelper.initializeHive();

  // Initialize Firebase Notifications FIRST
  await FirebaseNotification.initNotification();

  // Then initialize other services
  await AppSettings.init();
  await FBAnalytics.setDefaultEventParameters();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // FBAnalytics.logPageView('main_function_screen');
    final themeController = Get.put(ThemeController());
    return Obx(() => GetMaterialApp(  //add .router when use go_router
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FBAnalytics.observer],
      title: AppSettings.appName,
      themeMode: themeController.themeMode.value, // GetX-controlled theme
      theme: AppAppTheme.lightTheme,
      darkTheme: AppAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      home: NavigationHelper.navigateToBottomNavigationWidget(),
 
      onGenerateRoute: (settings) {
        return ExternalAppRoutes.handleDeepLink(settings: settings)
            ?? MaterialPageRoute(builder: (_) => NavigationHelper.navigateToBottomNavigationWidget());
      },
    ));
  }
}

