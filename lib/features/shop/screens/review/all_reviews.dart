import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../models/review_model.dart';
import 'widgets/user_review_card.dart';

class AllReviews extends StatelessWidget {
  const AllReviews({super.key, required this.reviews});

  final List<ReviewModel> reviews;
  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('all_reviews');

    final userController = Get.put(AuthenticationController());
    const double allReviewTileHeight = AppSizes.reviewYourPurchaseTileHeight;


    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Reviews found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: const AppAppBar(title: 'All Reviews', showCartIcon: true, showSearchIcon: true),
        body:  !userController.isUserLogin.value
            ? const CheckLoginScreen()
            : ListView(
              padding: TSpacingStyle.defaultPagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if(reviews.isEmpty)
                  emptyWidget
                else
                  ListView.separated(
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (_, index) {
                    return Container(
                      padding: const EdgeInsets.only(left: AppSizes.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSizes.defaultRadius),
                      ),
                      child: ReviewTile(review: reviews[index])
                    );
                  },
                ),
              ],
            )
    );
  }
}


