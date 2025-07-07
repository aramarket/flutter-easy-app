import 'package:aramarket/common/widgets/custom_shape/image/circular_image.dart';
import 'package:aramarket/common/widgets/shimmers/shimmer_effect.dart';
import 'package:aramarket/features/shop/screens/products/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../controllers/discover/discover_screen_controller.dart';
import '../../models/product_model.dart';
import '../search/search_input_field.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoverScreenController = Get.put(DiscoverScreenController());
    final ScrollController scrollController = ScrollController();

    discoverScreenController.refreshDiscoverProducts();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!discoverScreenController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (discoverScreenController.discoverProducts.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          discoverScreenController.isLoadingMore(true);
          discoverScreenController.currentPage++; // Increment current page
          await discoverScreenController.getDiscoverProducts();
          discoverScreenController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Product Found...',
      animation: Images.pencilAnimation,
      showAction: true,
      actionText: 'Please Refresh',
      onActionPress: () async => discoverScreenController.refreshDiscoverProducts(),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: AppSizes.sm, right: AppSizes.sm), // Adjust for status bar
          child: SearchField(searchText: AppTexts.search),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => discoverScreenController.refreshDiscoverProducts(),
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Obx(() {
              if (discoverScreenController.isLoading.value) {
                return shimmerBuildLayoutBuilder(10);
              } else if(discoverScreenController.discoverProducts.isEmpty) {
                return emptyWidget;
              } else {
                final products = discoverScreenController.discoverProducts;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double squareSize = (screenWidth - 8) / 3; // 3 columns, adjust spacing

                    return Obx(() => Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface,
                      child: StaggeredGrid.count(
                        crossAxisCount: 3, // 3 items per row
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: [
                          ..._buildGrid(products: products, size: squareSize),
                          if (discoverScreenController.isLoadingMore.value) ...[
                            ShimmerEffect(width: 100, height: 100),
                            ShimmerEffect(width: 100, height: 100),
                            ShimmerEffect(width: 100, height: 100),
                          ],
                        ],
                      ),
                    ),
                    );
                  },
                );




              }

            }),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildGrid({required List<ProductModel> products, required double size}) {
    List<Widget> tiles = [];

    for (int i = 0; i < products.length; i += 3) {
      if (i + 2 < products.length) {
        bool reverse = (i ~/ 3) % 2 == 1; // Reverse every second row
        if (!reverse) {
          tiles.add(_squareTile(product: products[i], crossAxis: 1, size: size));   // 33%
          tiles.add(_squareTile(product: products[i + 1], crossAxis: 2, size: size)); // 66%
          tiles.add(_squareTile(product: products[i + 2], crossAxis: 1, size: size)); // Below first (33%)
        } else {
          tiles.add(_squareTile(product: products[i], crossAxis: 2, size: size));  // 66%
          tiles.add(_squareTile(product: products[i + 1], crossAxis: 1, size: size)); // 33%
          tiles.add(_squareTile(product: products[i + 2], crossAxis: 1, size: size)); // Below first (33%)
        }
      }
    }
    return tiles;
  }

  Widget _squareTile({required ProductModel product, required int crossAxis, required double size}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxis,
      mainAxisCellCount: crossAxis, // Ensure square aspect ratio
      child: RoundedImage(
              height: size * crossAxis,
              width: size * crossAxis,
              isNetworkImage: true,
              borderRadius: 0,
              image: product.mainImage ?? '',
              onTap: () => Get.to(() => ProductScreen(product: product)),
            ),
    );
  }

  LayoutBuilder shimmerBuildLayoutBuilder(int itemCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double squareSize = (screenWidth - 8) / 3; // 3 columns, adjust spacing

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 4),
            physics: AlwaysScrollableScrollPhysics(),
            child: StaggeredGrid.count(
              crossAxisCount: 3, // 3 items per row
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: _buildGridSimmer(itemCount, squareSize),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGridSimmer(int itemCount, double size) {
    List<Widget> tiles = [];

    for (int i = 0; i < itemCount; i += 3) {
      if (i + 2 < itemCount) {
        bool reverse = (i ~/ 3) % 2 == 1; // Reverse every second row
        if (!reverse) {
          tiles.add(_squareTileShimmer(index: i, crossAxis: 1, size: size));   // 33%
          tiles.add(_squareTileShimmer(index: i + 1, crossAxis: 2, size: size)); // 66%
          tiles.add(_squareTileShimmer(index: i + 2, crossAxis: 1, size: size)); // Below first (33%)
        } else {
          tiles.add(_squareTileShimmer(index: i, crossAxis: 2, size: size));  // 66%
          tiles.add(_squareTileShimmer(index: i + 1, crossAxis: 1, size: size)); // 33%
          tiles.add(_squareTileShimmer(index: i + 2, crossAxis: 1, size: size)); // Below first (33%)
        }
      }
    }
    return tiles;
  }

  Widget _squareTileShimmer({required int index, required int crossAxis, required double size}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxis,
      mainAxisCellCount: crossAxis, // Ensures square aspect ratio
      child: ShimmerEffect(width: size * crossAxis, height: size * crossAxis),
    );
  }



}
