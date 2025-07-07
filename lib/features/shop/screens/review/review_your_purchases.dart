import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/product_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../controllers/review/all_review_controller.dart';
import '../products/scrolling_products.dart';
import 'all_reviews.dart';
import 'widgets/review_your_purchase_tile.dart';

class ReviewYourPurchases extends StatelessWidget {
  const ReviewYourPurchases({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('review_your_purchases');

    final reviewYourPurchasesController = Get.put(ReviewYourPurchasesController());
    final userController = Get.put(AuthenticationController());
    const double allReviewTileHeight = AppSizes.reviewYourPurchaseTileHeight;

    reviewYourPurchasesController.refreshAllReview();

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Purchased Product found...',
      animation: Images.pencilAnimation,
      // showAction: true,
      // actionText: 'Let\'s add some',
      // onActionPress: () => NavigationHelper.navigateToBottomNavigation(),
    );

    return Scaffold(
        appBar: const AppAppBar(title: 'Review your Purchases', showCartIcon: true, showSearchIcon: true),
        bottomNavigationBar: Obx(() => reviewYourPurchasesController.editedReviews.isNotEmpty
         ? Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: OutlinedButton(
                  onPressed: () => reviewYourPurchasesController.submitReviewBulk(),
                  child: Text('Submit All Review')
              ),
            )
         : SizedBox.shrink()
        ),
        body:  !userController.isUserLogin.value
            ? const CheckLoginScreen()
            : RefreshIndicator(
                color: AppColors.refreshIndicator,
                onRefresh: () async => reviewYourPurchasesController.refreshAllReview(),
                child: ListView(
                  padding: TSpacingStyle.defaultPagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SectionHeading(
                      title: 'How was the Products?',
                      seeActionButton: true,
                      buttonTitle: 'All Reviews',
                      verticalPadding: false,
                      onPressed: () => Get.to(() => AllReviews(reviews: reviewYourPurchasesController.previousReviews)),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Obx(() {
                      if (reviewYourPurchasesController.isLoading.value) {
                        return ProductShimmer(
                          itemCount: 2,
                          crossAxisCount: 1,
                          orientation: OrientationType.horizontal,
                        );
                      } else if(reviewYourPurchasesController.unreviewedCartItems.isEmpty) {
                        return emptyWidget;
                      } else {
                        final cartItems = reviewYourPurchasesController.unreviewedCartItems;
                        return GridLayout(
                            crossAxisCount: 1,
                            mainAxisExtent: allReviewTileHeight,
                            itemCount: reviewYourPurchasesController.isLoadingMore.value ? cartItems.length + 1 : cartItems.length,
                            itemBuilder: (context, index) {
                              if (index < cartItems.length) {
                                return ReviewYourPurchaseTile(cartItem: cartItems[index]);
                              } else {
                                return ProductShimmer(
                                  itemCount: 1,
                                  crossAxisCount: 1,
                                  orientation: OrientationType.horizontal,
                                );
                              }
                            }
                        );
                      }
                    })
                  ],
                ),
              )
    );
  }
}


