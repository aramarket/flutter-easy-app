import 'package:aramarket/features/shop/screens/products/scrolling_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../controllers/favorite/favorite_controller.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('favourite_screen');

    final ScrollController scrollController = ScrollController();
    final favoriteController = Get.put(FavoriteController());

    favoriteController.refreshFavorites();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!favoriteController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (favoriteController.products.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          favoriteController.isLoadingMore(true);
          favoriteController.currentPage++; // Increment current page
          await favoriteController.getFavoriteProducts();
          favoriteController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! Wishlist is Empty...',
      animation: Images.pencilAnimation,
      showAction: true,
      actionText: 'Let\'s add some',
      onActionPress: () => NavigationHelper.navigateToBottomNavigation(),
    );

    return Scaffold(
          appBar: const AppAppBar(title: 'Liked products', showCartIcon: true, showSearchIcon: true),
          body: RefreshIndicator(
              color: AppColors.refreshIndicator,
              onRefresh: () async => favoriteController.refreshFavorites(),
              child: ListView(
                controller: scrollController,
                padding: TSpacingStyle.defaultPagePadding,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Heading(title: 'Liked Products'),
                  SizedBox(height: AppSizes.sm),
                  ProductGridLayout(
                    controller: favoriteController,
                    emptyWidget: emptyWidget,
                    sourcePage: 'wishlist',
                    orientation: OrientationType.horizontal,
                    isDismissible: true,
                  ),
                ],
              ),
            )
        );
  }
}


