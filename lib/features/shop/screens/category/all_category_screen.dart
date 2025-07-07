import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/category_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/category_controller/category_controller.dart';
import '../products/scrolling_products.dart';
import 'widgets/single_category_item.dart';
import 'category_tap_bar.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('category_screen');
    final categoryController = Get.put(CategoryController());
    final ScrollController scrollController = ScrollController();
    final double categoryTileHeight = AppSizes.categoryTileHeight;

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!categoryController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (categoryController.categories.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          categoryController.isLoadingMore(true);
          categoryController.currentPage++; // Increment current page
          await categoryController.getAllCategory();
          categoryController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      appBar: AppAppBar(title: 'Categories', showCartIcon: true, sharePageLink: APIConstant.allCategoryUrl,),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => categoryController.refreshCategories(),
        child: ListView(
          controller: scrollController,
          padding: TSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Obx(() {
              if (categoryController.isLoading.value){
                return const CategoryTileShimmer(itemCount: 20, crossAxisCount: 3);
              } else if(categoryController.categories.isEmpty) {
                return const AnimationLoaderWidgets(
                  text: 'Whoops! Categories is Empty...',
                  animation: Images.pencilAnimation,
                );
              } else {
                final categories = categoryController.categories;
                return GridLayout(
                  crossAxisCount: 3,
                  mainAxisExtent: categoryTileHeight,
                  itemCount: categoryController.isLoadingMore.value ? categories.length + 4 : categories.length,
                  itemBuilder: (context, index) {
                    if (index < categories.length) {
                      final category = categories[index];
                      return SingleCategoryTile(
                          title: category.name ?? '',
                          image: category.image ?? '',
                          onTap: () => Get.to(CategoryTapBarScreen(categoryId: category.id ?? ''))
                      );
                    } else {
                      return const CategoryTileShimmer(itemCount: 1);
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