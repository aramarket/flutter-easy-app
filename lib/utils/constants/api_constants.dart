
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConstant {

  // WooCommerce API Constant
  static final String wooBaseDomain         =  dotenv.get('WOO_API_URL', fallback: '');
  static final String authorization         = 'Basic ${base64Encode(utf8.encode('${dotenv.env['WOO_CONSUMER_KEY']}:${dotenv.env['WOO_CONSUMER_SECRET']}'))}';

  static const String itemsPerPage          = '10';
  static final String wooBaseUrl            = 'https://$wooBaseDomain';
  static final String wooTrackingUrl        = 'https://$wooBaseDomain/tracking/?order-id=';

  // Cache time in days
  static const double defaultCacheTime      = 7;
  static const double appSettingCacheTime   = 7;
  static const double productCacheTime      = 1;
  static const double categoryCacheTime     = 7;
  static const double orderCacheTime        = 0.1;
  static const double customerCacheTime     = 1;
  static const double couponCacheTime       = 1;

  // RazorPay credential
  static final String razorpayKey = dotenv.get('RAZORPAY_KEY', fallback: '');
  static final String razorpaySecret = dotenv.get('RAZORPAY_SECRET', fallback: '');

  static final String razorpayAuth = 'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}';

  //Define urls
  static const String urlContainProduct         = '/product/';
  static const String urlContainProductCategory = '/product-category/';
  static const String urlContainAllCategories   = '/product-categories/';
  static const String urlContainAllBrands       = '/product-brands/';
  static const String urlProductBrand           = '/brand/';
  static const String urlContainOrders          = '/my-account/orders';
  static String allCategoryUrl                  = 'https://$wooBaseDomain$urlContainAllCategories';
  static String allBrandUrl                     = 'https://$wooBaseDomain$urlContainAllBrands';
  static String productBrandUrl                 = 'https://$wooBaseDomain$urlProductBrand';
  static String productCategoryUrl              = 'https://$wooBaseDomain$urlContainProductCategory';

  static const String wooProductsApiPath    = '/wp-json/wc/v3/products/';
  static const String wooBrandsApiPath    = '/wp-json/wc/v3/products/brands/';
  static const String wooCategoriesApiPath  = '/wp-json/wc/v3/products/categories/';
  static const String wooCouponsApiPath     = '/wp-json/wc/v3/coupons/';
  static const String wooOrdersApiPath      = '/wp-json/wc/v3/orders/';
  static const String wooCustomersApiPath   = '/wp-json/wc/v3/customers/';
  static const String wooProductsReview     = '/wp-json/wc/v3/products/reviews/';
  static const String wooProductsBulkReview = '/wp-json/wc/v3/products/reviews/batch/';

  // Custom Api end points
  static const String wooSettings           = '/wp-json/flutter-app/v1/app-settings/';
  static const String wooBanners            = '/wp-json/flutter-app/v1/home-banners/';
  static const String wooCustomersPhonePath = '/wp-json/flutter-app/v1/customer-by-phone/';
  static const String wooAuthenticatePath   = '/wp-json/flutter-app/v1/authenticate/';
  static const String wooResetPassword      = '/wp-json/flutter-app/v1/reset-password/';
  static const String wooFBT                = '/wp-json/flutter-app/v1/products-sold-together/';
  static const String wooProductsReviewImage= '/wp-json/flutter-app/v1/product-reviews/';

  // fast2sms url
  static final String fast2smsUrl           = dotenv.get('FAST2SMS_API_URL', fallback: '');
  static final String fast2smsToken         = dotenv.get('FAST2SMS_API_TOKEN', fallback: '');

  // Facebook whatsapp api
  static final String whatsappPhoneNumberId     = dotenv.get('WHATSAPP_API_MOBILE_ID', fallback: '');
  static final String whatsappApiToken          = dotenv.get('WHATSAPP_API_TOKEN', fallback: '');
  static final String waApiTemplateOtp          = dotenv.get('WA_APT_TEMPLATE_OTP', fallback: '');

}