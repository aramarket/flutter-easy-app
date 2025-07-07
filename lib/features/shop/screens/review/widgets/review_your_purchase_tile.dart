import 'package:aramarket/features/shop/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../controllers/review/all_review_controller.dart';
import '../../../models/cart_item_model.dart';
import '../../products/product_detail.dart';
import '../../products/products_widgets/product_title_text.dart';
import '../create_product_review.dart';


class ReviewYourPurchaseTile extends StatelessWidget {
  const ReviewYourPurchaseTile({super.key, required this.cartItem});

  final CartModel cartItem;

  @override
  Widget build(BuildContext context) {
    final CustomerModel customer = Get.find<AuthenticationController>().customer.value;
    final reviewYourPurchasesController = Get.find<ReviewYourPurchasesController>();

    const double allReviewTileHeight = AppSizes.reviewYourPurchaseTileHeight;
    const double allReviewTileWidth = AppSizes.reviewYourPurchaseTileWidth;
    const double allReviewTileImageSize = AppSizes.reviewYourPurchaseTileImageSize;
    const double allReviewTileRadius = AppSizes.reviewYourPurchaseTileRadius;

    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(allReviewTileRadius),
        border: Border.all(
          width: AppSizes.defaultBorderWidth,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          // Product Image
          RoundedImage(
            image: cartItem.image ?? '',
            height: allReviewTileImageSize,
            width: allReviewTileImageSize,
            borderRadius: allReviewTileRadius,
            isNetworkImage: true,
            padding: 0,
            onTap: () => Get.to(() => ProductScreen(
              productId: cartItem.productId.toString(),
              pageSource: 'ProductCardForCart',
            )),
          ),

          // Title & Rating
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ProductTitle(title: cartItem.name ?? '', maxLines: 1, size: 13),

                  // Star Rating
                  Obx(() {
                    final reviews = reviewYourPurchasesController.editedReviews;
                    final existingIndex = reviews.indexWhere((r) => r.productId == cartItem.productId);
                    final currentRating = existingIndex != -1 ? reviews[existingIndex].rating ?? 0 : 0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => reviewYourPurchasesController.addReview(productId: cartItem.productId, rating: index + 1),
                          icon: Icon(
                            index < currentRating ? Icons.star : Icons.star_border,
                            color: AppColors.ratingStar,
                            size: 30,
                          ),
                        );
                      }),
                    );
                  }),

                  // Action Buttons
                  Obx(() {
                    final existingIndex = reviewYourPurchasesController.editedReviews.indexWhere((r) => r.productId == cartItem.productId,);
                    if (existingIndex == -1) return const SizedBox.shrink();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 13),
                            minimumSize: const Size(150, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () {
                            Get.to(() => CreateReviewScreen(
                              productId: cartItem.productId,
                              productTitle: cartItem.name ?? '',
                              productImgUrl: cartItem.image ?? '',
                            ));
                          },
                          child: const Text('Write a Review'),
                        ),
                        TextButton(
                          onPressed: () => reviewYourPurchasesController.removeReview(productId: cartItem.productId),
                          child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
