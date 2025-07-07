import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/order_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../controllers/order/order_controller.dart';
import 'widgets/order_tile.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('order_screen');
    final orderController = Get.put(OrderController());
    final ScrollController scrollController = ScrollController();
    final userController = Get.put(AuthenticationController());
    final double orderTileHeight = AppSizes.orderTileHeight;

    orderController.refreshOrders();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!orderController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (orderController.orders.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          orderController.isLoadingMore(true);
          orderController.currentPage++; // Increment current page
          await orderController.getOrdersByCustomerId();
          // await orderController.fetchOrders();
          orderController.isLoadingMore(false);

        }
      }
    });

    return Scaffold(
      appBar: const AppAppBar(title: "My Orders", showBackArrow: true),
      body: !userController.isUserLogin.value
        ? const CheckLoginScreen()
        : RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async {
            await orderController.refreshOrders();
          },
          child: ListView(
              controller: scrollController,
              padding: TSpacingStyle.defaultPagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Obx(() {
                  if(orderController.isLoading.value){
                    return const OrderShimmer(itemCount: 4);
                  }else if(orderController.orders.isEmpty) {
                    return AnimationLoaderWidgets(
                      text: 'Whoops! Order is Empty...',
                      animation: Images.orderCompletedAnimation,
                      showAction: true,
                      actionText: 'Let\'s add some',
                      onActionPress: () => NavigationHelper.navigateToBottomNavigation(),
                    );
                  } else {
                    return GridLayout(
                      mainAxisExtent: orderTileHeight,
                      itemCount: orderController.isLoadingMore.value ? orderController.orders.length + 1 : orderController.orders.length,
                      itemBuilder: (context, index) {
                        if (index < orderController.orders.length) {
                          return OrderTile(order: orderController.orders[index]);
                        } else {
                          return const OrderShimmer();
                        }
                      },
                    );
                  }
                }),
              ],
            ),
          ),
    );
  }
}
