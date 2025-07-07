import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/user_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/icons.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/review/review_controller.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import 'create_product_review.dart';
import 'widgets/user_review_card.dart';

class ProductReviewScreen extends StatelessWidget {
  const ProductReviewScreen({super.key, required this.product});

  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('review_screen');
    final productReviewController = Get.put(ReviewController());
    final ScrollController scrollController = ScrollController();

    productReviewController.refreshReviews(product.id.toString());

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!productReviewController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (productReviewController.reviews.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          productReviewController.isLoadingMore(true);
          productReviewController.currentPage++; // Increment current page
          await productReviewController.getReviewsByProductId(product.id.toString());
          productReviewController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        child: OutlinedButton(
            onPressed: () => Get.to(() => CreateReviewScreen(
              productId: product.id, productTitle: product.name ?? '', productImgUrl: product.mainImage ?? '',)),
            child: const Text('Add product review')
        ),
      ),
      body: ListView(
        controller: scrollController,
        padding: TSpacingStyle.defaultPageVertical,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Section 1
          Padding(
            padding: TSpacingStyle.defaultPageHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  spacing: AppSizes.spaceBtwItems,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingBarIndicator(
                      rating: product.averageRating ?? 0.0,
                      itemSize: 17,
                      unratedColor: Colors.grey[300],
                      itemBuilder: (_, __) =>  Icon(AppIcons.starRating, color: AppColors.ratingStar),
                    ),
                    Text(product.averageRating!.toStringAsFixed(1), style: TextStyle(fontSize: 17)),
                  ],
                ),
                Text('Based on ${product.ratingCount} reviews', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),

          // Section 2
          Column(
            children: [
              Obx(() {
                if (productReviewController.isLoading.value){
                  return const UserTileShimmer();
                } else if(productReviewController.reviews.isEmpty) {
                  return const AnimationLoaderWidgets(
                    text: 'Whoops! No Review yet! Be the First Reviewer',
                    animation: Images.pencilAnimation,
                  );
                } else{

                  final List<ReviewModel> reviews = productReviewController.reviews;

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: productReviewController.isLoadingMore.value ? reviews.length + 1 : reviews.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          if (index < reviews.length) {
                            return ReviewTile(review: reviews[index]);
                          } else {
                            return const UserTileShimmer();
                          }
                        },
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
}




