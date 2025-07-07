import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../services/app_review/app_review.dart';
import '../authentication/controllers/Authentication_controller/authentication_controller.dart';

class AppSettings {

  static const String appName             =  'aramarket.in';
  static const String subTitle            =  'Wholesale Market Place';

  static const String appCurrency         =  'INR';
  static const String appCurrencySymbol   =  '₹';
  static const int freeShippingOver       =  999;
  static const double shippingCharge      =  100;

  static const int otpLength              =  4;
  static const int otpResendTimer         =  60;
  static String version = '';

  // Images
  static const String lightAppLogo  = 'assets/logos/aramarket_light.png';
  static const String darkAppLogo   = 'assets/logos/aramarket_dark.png';

  // App Basic Colors
  static const Color primaryColor = Color(0xFFFFC61A);
  static const Color secondaryColor = Color(0xFF2d2d2d); // 0xFF092143
  static const Color accent = Color(0xFFB0C7FF);

  static const Color lightText = Color(0xFF0B1014);    // Text Color
  static const Color lightTextSofter = Color(0xFF8A929D); // Text Color Softer
  static const Color lightBackground = Color(0xFFFFFFFF); // background
  static const Color lightTileBackground = Color(0xFFF4F5F7); // Background for cards, dialogs, etc.

  // FF0B1014 whatsapp // FF0C0F14 Instagram // Chrome Background FF15202F // Tile Background FF313C4C // input field FF1B2636
  static const Color darkText = Color(0xFF0B1014);    // Text Color
  static const Color darkTextSofter = Color(0xFFA3AAB4); // Text Color Softer
  static const Color darkBackground = Color(0xFF0B1014); // background
  static const Color darkTileBackground = Color(0xFF25282D); // Background for cards, dialogs, etc.
  // static const Color darkInputFieldBackground = Color(0xFF25282D);

  // Support
  static const String supportWhatsApp   =  '+919368994493';
  static const String supportMobile     =  '+919368994493';
  static const String supportEmail      =  'support@aramarket.in';

  // Policy Urls
  static const String privacyPrivacy        = 'https://aramarket.in/privacy-policy/';
  static const String shippingPolicy        = 'https://aramarket.in/shipping-policy/';
  static const String termsAndConditions    = 'https://aramarket.in/terms-and-conditions/';
  static const String refundPolicy          = 'https://aramarket.in/refund_returns/';

  // Follow us link
  static const String facebook              = 'https://www.facebook.com/araMarket.in';
  static const String instagram             = 'https://www.instagram.com/aramarket.in/';
  static const String telegram              = 'https://www.instagram.com/aramarket.in/';
  static const String twitter               = 'https://twitter.com/aramarket_India';
  static const String youtube               = 'https://www.youtube.com/@aramarket';
  static const String playStore             = 'https://play.google.com/store/apps/details?id=com.company.aramarketin&hl=en_IN&gl=US';

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    await Get.put(AuthenticationController()).checkIsUserLogin();
  }

  static String get appVersion => version;

}
