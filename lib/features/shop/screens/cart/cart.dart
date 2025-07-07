import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/product/product_cards/product_card_cart_items.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../../settings/app_settings.dart';
import '../../controllers/cart_controller/cart_controller.dart';
import '../../controllers/checkout_controller/checkout_controller.dart';
import '../checkout/checkout.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final checkoutController = Get.put(CheckoutController());
    FBAnalytics.logPageView('cart_screen');
    FBAnalytics.logViewCart(cartItems: cartController.cartItems);
    // make empty cart animation
    final emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! Cart is Empty...',
      animation: Images.addToCartAnimation,
      showAction: true,
      actionText: 'Let\'s add some',
      onActionPress: () => NavigationHelper.navigateToBottomNavigation(),
    );

    return Scaffold(
        appBar: const AppAppBar(title: "Cart", showSearchIcon: true),
        bottomNavigationBar: Obx(() =>
            cartController.cartItems.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: ElevatedButton(
                  onPressed: () {
                    checkoutController.updateCheckout();
                    Get.to(const CheckoutScreen());
                  },
                  child: Obx(() => Text('Buy Now (${AppSettings.appCurrencySymbol + (cartController.totalCartPrice.value).toStringAsFixed(0)})'))
              ),
            )
            : const SizedBox.shrink()),
        body: Obx(() {
          // check empty cart
          if(cartController.cartItems.isEmpty) {
            return emptyWidget;
          } else {
            return Padding(
              padding: TSpacingStyle.defaultPageHorizontal,
              child: GridLayout(
                crossAxisCount: 1,
                mainAxisExtent: AppSizes.cartCardHorizontalHeight,
                itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return Dismissible(
                      key: Key(item.productId.toString()),
                      direction: DismissDirection.endToStart, // Swipe left to remove
                      onDismissed: (direction) {
                        cartController.removeFromCart(item: item);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(AppSizes.defaultProductRadius),
                          // border: Border.all(
                          //   width: Sizes.defaultBorderWidth,
                          //   color: Theme.of(context).colorScheme.outline, // Border color
                          // )
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ProductCardForCart(cartItem: item, showBottomBar: true),
                    );
                  }
              ),
            );
          }
        }
      ),
    );
  }
}


