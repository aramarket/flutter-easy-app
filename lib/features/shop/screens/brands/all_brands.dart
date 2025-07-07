import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/brand_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/brand_controller/brand_controller.dart';
import '../../controllers/product/product_controller.dart';
import '../products/scrolling_products.dart';
import 'brand_tap_bar.dart';
import 'widgets/single_brand_tile.dart';

class AllBrandScreen extends StatelessWidget {
  const AllBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('all_brand_screen');
    final brandController = Get.put(BrandController());
    final ScrollController scrollController = ScrollController();
    final double brandTileHeight = AppSizes.brandTileHeight;

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!brandController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (brandController.productBrands.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          brandController.isLoadingMore(true);
          brandController.currentPage++; // Increment current page
          await brandController.getAllBrands();
          brandController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      appBar: AppAppBar(title: 'All Brands', showCartIcon: true, showSearchIcon: true, sharePageLink: APIConstant.allBrandUrl,),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => brandController.refreshBrands(),
        child: ListView(
          controller: scrollController,
          padding: TSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Obx(() {
              if (brandController.isLoading.value){
                return const BrandTileShimmer(itemCount: 20, crossAxisCount: 3);
              } else if(brandController.productBrands.isEmpty) {
                return const AnimationLoaderWidgets(
                  text: 'Whoops! Brands is Empty...',
                  animation: Images.pencilAnimation,
                );
              } else {
                final brands = brandController.productBrands;
                return GridLayout(
                  crossAxisCount: 3,
                  mainAxisExtent: brandTileHeight,
                  // mainAxisExtent: 400,
                  itemCount: brandController.isLoadingMore.value ? brands.length + 3 : brands.length,
                  itemBuilder: (context, index) {
                    if (index < brands.length) {
                      final brand = brands[index];
                      return Column(
                        children: [
                          SingleBrandTile(
                              title: brand.name ?? '',
                              image: brand.image ?? '',
                              onTap: () => Get.to(BrandTapBarScreen(brandID: brand.id ?? 0))
                          ),
                        ],
                      );
                    } else {
                      return const BrandTileShimmer(itemCount: 1);
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
