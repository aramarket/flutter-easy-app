import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/icons.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatters.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../controllers/product/image_controller.dart';
import '../../../controllers/review/review_controller.dart';
import '../../../models/review_model.dart';
import '../../products/products_widgets/product_title_text.dart';
import '../update_product_review.dart';

class ReviewTile extends StatelessWidget {
  ReviewTile({super.key, required this.review});

  ReviewModel review;
  @override
  Widget build(BuildContext context) {
    final userController = Get.put(AuthenticationController());
    final productReviewController = Get.put(ReviewController());
    final imagesController = Get.put(ImagesController());
    // final imagesController = Get.find<ImagesController>();

    // Using Html widget to parse HTML text
    final String reviewerName = Validator.isEmail(review.reviewer ?? '') ? AppFormatter.maskEmail(review.reviewer ?? '') : review.reviewer ?? '';
    return ListTile(
      contentPadding: EdgeInsets.only(top: AppSizes.sm, left: AppSizes.sm), // Removes extra padding
      leading: RoundedImage(
        image: review.reviewerAvatarUrl ?? Images.tProfileImage,
        height: 30,
        width: 30,
        borderRadius: 100,
        padding: 0,
        isNetworkImage: true,
      ),
      title: Row(
        spacing: AppSizes.spaceBtwItems,
        children: [
          Text(reviewerName, style: TextStyle(fontSize: 12),),
          Icon(Icons.circle, size: 5),
          Text(AppFormatter.formatRelativeDate(review.dateCreated ?? ''), style: TextStyle(fontSize: 11))
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizes.xs),
          RatingBarIndicator(
            rating: review.rating!.toDouble(),
            itemSize: 14,
            unratedColor: Colors.grey[300],
            itemBuilder: (_, __) =>  Icon(AppIcons.starRating, color: AppColors.ratingStar),
          ),
          SizedBox(height: AppSizes.xs),
          ReadMoreText(
            review.review!.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('<br />', ''),
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            trimLines: 4,
            trimMode: TrimMode.Line,
            trimExpandedText: ' show less',
            trimCollapsedText: ' show more',
            moreStyle: const TextStyle(fontSize: 14, color: Colors.blue),
            lessStyle: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Fix: Prevents Row from taking full width
        children: [
          review.image != null && review.image!.isNotEmpty
              ? RoundedImage(
                  backgroundColor: Colors.transparent,
                  image: review.image ?? "",
                  height: 60,
                  width: 50,
                  borderRadius: 0,
                  padding: 0,
                  isNetworkImage: true,
                  onTap: () => imagesController.showEnlargedImage(review.image ?? ""),
                )
              : SizedBox.shrink(),
          userController.customer.value.email == review.reviewerEmail
              ? PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Delete') {
                productReviewController.deleteReviewDialog(context: context, reviewId: review.id ?? 0);
              } else if (value == 'Edit') {
                Get.to(() => UpdateReviewScreen(review: review));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'Delete',
                child: Text('Delete'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: AppColors.linkColor),
          )
              : PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Report',
                child: Text('Report'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
