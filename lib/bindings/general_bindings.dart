import 'package:get/get.dart';

import '../common/widgets/network_manager/network_manager.dart';
import '../data/repositories/woocommerce_repositories/authentication/woo_authentication.dart';
import '../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../features/settings/controllers/settings_controller.dart';
import '../features/shop/controllers/cart_controller/cart_controller.dart';
import '../features/shop/controllers/checkout_controller/checkout_controller.dart';
import '../features/shop/controllers/favorite/favorite_controller.dart';
import '../features/shop/controllers/product/product_controller.dart';
import '../features/shop/controllers/recently_viewed/recently_viewed_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NetworkManager());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => AuthenticationController());
    Get.lazyPut(() => AddressController());
    Get.lazyPut(() => FavoriteController());
    Get.lazyPut(() => CheckoutController());
    Get.lazyPut(() => ProductController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => RecentlyViewedController());

    Get.lazyPut(() => WooAuthenticationRepository());
    Get.lazyPut(() => WooCustomersRepository());
  }
}