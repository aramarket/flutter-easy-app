import 'package:aramarket/features/shop/screens/products/products_widgets/product_title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../controllers/review/review_controller.dart';

class CreateReviewScreen extends StatelessWidget {
  const CreateReviewScreen({super.key, required this.productId, required this.productTitle, required this.productImgUrl});

  final int productId;
  final String productTitle;
  final String productImgUrl;
  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('review_create_screen');

    final userController = Get.put(AuthenticationController());
    final productReviewController = Get.put(ReviewController());
    return Scaffold(
      appBar: const AppAppBar(title: 'Submit Reviews', showBackArrow: true, showCartIcon: true,),
      body: !userController.isUserLogin.value
          ? const CheckLoginScreen(text: 'Please Login! before submit review!')
          : SingleChildScrollView(
              padding: TSpacingStyle.defaultSpaceLg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: AppSizes.sm,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RoundedImage(
                          image: productImgUrl,
                          height: 50,
                          width: 50,
                          borderRadius: AppSizes.sm,
                          isNetworkImage: true,
                          padding: 0
                      ),
                      Expanded(child: ProductTitle(title: productTitle, maxLines: 2, size: 12,))
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text('How was the item?', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSizes.sm),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) => GestureDetector(
                        onTap: () {
                          productReviewController.rating.value = index + 1;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.ratingStar), // Border color
                            // borderRadius: BorderRadius.circular(50), // Border radius to make it circular
                          ),
                          margin: const EdgeInsets.all(5), // Padding to add space between border and icon
                          padding: const EdgeInsets.all(5), // Padding to add space between border and icon
                          child: Icon(
                            index < productReviewController.rating.value
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.ratingStar,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: AppSizes.xs),
                  Text('Click to rate', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSizes.xl),
                  Form(
                    key: productReviewController.submitReviewFormKey,
                    child: Column(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product review*', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppSizes.xs),
                              TextFormField(
                                controller: productReviewController.productReview,
                                validator: (value) => Validator.validateEmptyText(value, 'Product review'),
                                maxLines: 2,
                                decoration: InputDecoration(
                                    hintText: 'Example: Easy to use',
                                    border: const OutlineInputBorder(),
                                    hintStyle: Theme.of(context).textTheme.labelLarge
                                ),
                              ),
                            ]
                        ),
                        // const SizedBox(height: TSizes.spaceBtwInputFields),
                        // Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text('Nick name*', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                        //       const SizedBox(height: TSizes.xs),
                        //       TextFormField(
                        //         controller: submitReviewController.nickname,
                        //         validator: (value) => TValidator.validateEmptyText(value, 'Nick name'),
                        //         decoration: InputDecoration(
                        //             hintText: 'Example: John',
                        //             border: const OutlineInputBorder(),
                        //             hintStyle: Theme.of(context).textTheme.labelLarge
                        //         ),
                        //       ),
                        //     ]
                        // ),
                        // const SizedBox(height: TSizes.spaceBtwInputFields),
                        // Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text('Email address*', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                        //       const SizedBox(height: TSizes.xs),
                        //       TextFormField(
                        //         controller: submitReviewController.email,
                        //         validator: (value) => TValidator.validationEmail(value),
                        //         maxLines: 1,
                        //         decoration: InputDecoration(
                        //             hintText: 'Example: your@gmail.com',
                        //             border: const OutlineInputBorder(),
                        //             hintStyle: Theme.of(context).textTheme.labelLarge
                        //         ),
                        //       ),
                        //     ]
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSection),
                  ElevatedButton(
                    onPressed: () => productReviewController.submitReview(productId),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                      child: Text('Submit product review'),
                    )
                  )
                ],
              ),
            ),
    );
  }
}
