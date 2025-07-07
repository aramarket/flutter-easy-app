import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../controllers/recently_viewed/recently_viewed_controller.dart';
import '../products/scrolling_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';

class RecentlyViewed extends StatelessWidget {
  const RecentlyViewed({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('recently_viewed_screen');
    final ScrollController scrollController = ScrollController();
    final recentlyViewedController = Get.put(RecentlyViewedController());

    recentlyViewedController.refreshRecentProducts();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!recentlyViewedController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (recentlyViewedController.products.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          recentlyViewedController.isLoadingMore(true);
          recentlyViewedController.currentPage++; // Increment current page
          await recentlyViewedController.getRecentProducts();
          recentlyViewedController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Recent Products...',
      animation: Images.pencilAnimation,
      showAction: true,
      actionText: 'Let\'s add some',
      onActionPress: () => NavigationHelper.navigateToBottomNavigation(),
    );
    return Scaffold(
        appBar: const AppAppBar(title: 'Recently viewed', showCartIcon: true, showSearchIcon: true,),
        body: RefreshIndicator(
                color: AppColors.refreshIndicator,
                onRefresh: () async => recentlyViewedController.refreshRecentProducts(),
                child: ListView(
                  controller: scrollController,
                  padding: TSpacingStyle.defaultPagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      onTap: recentlyViewedController.clearHistory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Clear history', style: Theme.of(context).textTheme.bodyMedium!,),
                            const SizedBox(width: AppSizes.sm),
                            const Icon(Icons.delete, size: 18, color: Colors.pink),
                          ],
                        ),
                      ),
                    ),
                    ProductGridLayout(
                      controller: recentlyViewedController,
                      orientation: OrientationType.horizontal,
                      emptyWidget: emptyWidget, sourcePage: 'recently_view',
                      isDismissible: true,
                    ),
                  ],
                ),
              )
    );
  }
}


