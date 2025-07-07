import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/woocommerce_repositories/reviews/reviews_repository.dart';
import '../../../../services/app_review/app_review.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../models/review_model.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  // for submit review
  RxInt rating = 0.obs;
  final productReview = TextEditingController();
  GlobalKey<FormState> submitReviewFormKey = GlobalKey<FormState>();

  // for edit review
  RxInt editRating = 0.obs;
  final editProductReview = TextEditingController();
  GlobalKey<FormState> editReviewFormKey = GlobalKey<FormState>();

  final wooReviewRepository = Get.put(WooReviewsRepository());
  final userController = Get.put(AuthenticationController());

  // Get reviews by product id
  Future<void> getReviewsByProductId(String productId) async {
    try{
      //fetch products
      final newReviews = await wooReviewRepository.fetchReviewsByProductId(productId: productId, page: currentPage.toString());
      reviews.addAll(newReviews);
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Refresh Reviews
  Future<void> refreshReviews(String productId) async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      reviews.clear(); // Clear existing orders
      await getReviewsByProductId(productId);
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // create review
  Future<void> submitReview(int productId) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are adding your review..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if(!submitReviewFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      if (rating.value == 0) {
        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(title: 'Error', message: 'Star rating is mandatory');
        return;
      }

      // update single field user
      final ReviewModel review = ReviewModel(
        productId: productId,
        rating: rating.value,
        review: productReview.text.trim(),
        reviewer: userController.customer.value.name,
        reviewerEmail: userController.customer.value.email,
        reviewerAvatarUrl: userController.customer.value.avatarUrl ?? '',
      );

      // update single field user
      final ReviewModel createdReview = await wooReviewRepository.submitReview(review);

      // add this review in beginning
      reviews.insert(0, createdReview);

      productReview.text = '';
      rating.value = 0;

      // remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Review added successfully!');
      Get.back();
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    } finally {
      Future.delayed(Duration(seconds: 3), () {
        AppReview.showReviewPopup();
      });
    }
  }

  // update review
  Future<void> updateReview(int reviewId) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your review..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if(!editReviewFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      if (editRating.value == 0) {
        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(title: 'Error', message: 'Star rating is mandatory');
        return;
      }
      // update single field user
      Map<String, dynamic> reviewField = {
        ReviewFieldName.rating: editRating.value,
        ReviewFieldName.review: editProductReview.text.trim(),
      };

      // update review
      final ReviewModel updatedReview = await wooReviewRepository.updateReview(reviewId, reviewField);
      final int index = reviews.indexWhere((review) => review.id == updatedReview.id);
      if (index != -1) {
        reviews[index] = updatedReview;
      }

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Review updated successfully!');
      Get.back();
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  //Delete review
  Future<void> deleteReview(int reviewId) async {
    try {
      final ReviewModel deletedReview = await wooReviewRepository.deleteReview(reviewId: reviewId);
      reviews.removeWhere((review) => review.id == deletedReview.id);
    }  catch (error) {
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  // Show dialog box before deleting review
  void deleteReviewDialog({required BuildContext context, required int reviewId}) {
    RxBool deleting = false.obs;
    DialogHelper.showDialog(
        context: context,
        title: 'Delete Review',
        message: 'Are you sure you want to delete the review?',
        actionButtonText: 'Delete',
        toastMessage: 'Review deleted successfully',
        onSubmit: () async {
          deleting.value = true;
          // Perform delete operation
          await deleteReview(reviewId);
          deleting.value = false;
        },
    );
  }

}