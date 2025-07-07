import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/shimmers/coupon_shimmer.dart';
import '../../../../common/widgets/shimmers/order_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/coupon/coupon_controller.dart';
import 'widgets/single_coupon.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('coupon_screen');
    final couponController = Get.put(CouponController());

    couponController.refreshCoupons();

    return Scaffold(
      appBar: const AppAppBar(title: 'Coupons', showBackArrow: true, showSearchIcon: true),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => couponController.refreshCoupons(),
        child: CouponListLayout(),
      )
    );
  }
}

class CouponListLayout extends StatelessWidget {
  const CouponListLayout({ super.key });

  @override
  Widget build(BuildContext context) {
    final couponController = Get.put(CouponController());
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!couponController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (couponController.coupons.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          couponController.isLoadingMore(true);
          couponController.currentPage++; // Increment current page
          await couponController.getAllCoupons();
          couponController.isLoadingMore(false);
        }
      }
    });

    return ListView(
      controller: scrollController,
      padding: TSpacingStyle.defaultPageVertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Heading(title: 'Coupons', paddingLeft: AppSizes.defaultSpace),
        SizedBox(height: AppSizes.spaceBtwItems),
        Obx(() {
          if(couponController.isLoading.value){
            return const CouponShimmer();
          }else if(couponController.coupons.isEmpty) {
            return const AnimationLoaderWidgets(
              text: 'Whoops! Order is Empty...',
              animation: Images.pencilAnimation,
            );
          }else {
            return GridLayout(
              mainAxisExtent: 80,
              itemCount: couponController.isLoadingMore.value ? couponController.coupons.length + 1 : couponController.coupons.length,
              itemBuilder: (context, index) {
                if (index < couponController.coupons.length) {
                  return SingleCouponItem(coupon: couponController.coupons[index]);
                } else {
                  return const CouponShimmer();
                }
              },
            );
          }
        }),

      ],
    );
  }
}
