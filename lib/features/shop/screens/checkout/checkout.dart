import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/product/product_cards/product_card_cart_items.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../settings/app_settings.dart';
import '../../controllers/cart_controller/cart_controller.dart';
import '../../controllers/checkout_controller/checkout_controller.dart';
import 'widgets/billing_address_section.dart';
import 'widgets/billing_amount_section.dart';
import 'widgets/billing_payment_section.dart';
import 'widgets/coupon_section.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final cartController = Get.put(CartController());
    final checkoutController = Get.put(CheckoutController());
    final userController = Get.put(AuthenticationController());
    FBAnalytics.logPageView('checkout_screen');
    FBAnalytics.logBeginCheckout(cartItems: cartController.cartItems);
    // Trigger updateCheckout on widget initialization
    Future.microtask(() => checkoutController.updateCheckout());

    return Scaffold(
      appBar: const AppAppBar(title: "Order summery", showBackArrow: true),
      bottomNavigationBar: Obx((){
        if (userController.isUserLogin.value && cartController.cartItems.isNotEmpty){
          return Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: ElevatedButton(
                  onPressed: () => checkoutController.initiateCheckout(),
                  // onPressed: () {},
                  child: Obx(() => Text('Place Order (${AppSettings.appCurrencySymbol +
                      checkoutController.total.value.toStringAsFixed(0)})'))
              ),
            );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: !userController.isUserLogin.value
          ? const CheckLoginScreen(text: 'Please Login! before Checkout!')
          : SingleChildScrollView(
            padding: TSpacingStyle.defaultPageHorizontal,
            child: Column(
              children: [
                // Cart Items
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Heading(title: 'Cart Items'),
                    GridLayout(
                        crossAxisCount: 1,
                        mainAxisExtent: 95,
                        itemCount: cartController.cartItems.length,
                        itemBuilder: (_, index) => ProductCardForCart(cartItem: cartController.cartItems[index]),
                      ),
                  ],
                )),
                const SizedBox(height: AppSizes.spaceBtwSection,),

                // Billing Sections
                Column(
                  children: [
                    // coupon TextField
                    const TCouponCode(),
                    const SizedBox(height: AppSizes.spaceBtwSection,),

                    // pricing
                    Divider(thickness: AppSizes.defaultBorderWidth, color: Theme.of(context).colorScheme.outline),
                    TBillingAmountSection(),

                    // payment method
                    Divider(thickness: AppSizes.defaultBorderWidth, color: Theme.of(context).colorScheme.outline),
                    TBillingPaymentSection(),

                    // address
                    Divider(thickness: AppSizes.defaultBorderWidth, color: Theme.of(context).colorScheme.outline),
                    TBillingAddressSection(),
                    SizedBox(height: AppSizes.spaceBtwItems),
                  ],
                ),///
              ],
            ),
          ),
    );
  }
}
