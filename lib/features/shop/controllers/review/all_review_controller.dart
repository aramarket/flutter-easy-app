import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/woocommerce_repositories/orders/woo_orders_repository.dart';
import '../../../../data/repositories/woocommerce_repositories/reviews/reviews_repository.dart';
import '../../../../services/app_review/app_review.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/review_model.dart';

class ReviewYourPurchasesController extends GetxController {
  static ReviewYourPurchasesController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<ReviewModel> previousReviews = <ReviewModel>[].obs;
  RxList<OrderModel> purchasedOrders = <OrderModel>[].obs;
  RxList<CartModel> cartItems = <CartModel>[].obs;
  RxList<CartModel> unreviewedCartItems = <CartModel>[].obs; // This will store only unreviewed items
  RxList<ReviewModel> editedReviews = <ReviewModel>[].obs;

  final wooReviewRepository = Get.put(WooReviewsRepository());
  final wooOrdersRepository = Get.put(WooOrdersRepository());
  final userController = Get.put(AuthenticationController());

  // Get user order by customer id
  Future<void> getOrdersByCustomerId() async {
    try {
      final List<OrderModel> newOrders = await wooOrdersRepository.fetchOrdersByCustomerId(customerId: userController.customer.value.id.toString(), page: currentPage.toString());
      purchasedOrders.addAll(newOrders);
      extractCartItemsFromOrders(); // extract from orders to cartItems
      filterUnreviewedPurchasedProducts(); // filter unreviewed into unreviewedCartItems
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> getAllOrdersByCustomerId() async {
    try {
      int page = 1;
      bool hasMore = true;
      purchasedOrders.clear();
      while (hasMore) {
        final List<OrderModel> newOrders = await wooOrdersRepository.fetchOrdersByCustomerId(
            customerId: userController.customer.value.id.toString(),
            page: page.toString(),
            orderStatus: OrderStatus.completed
        );
        if (newOrders.isEmpty) {
          hasMore = false;
        } else {
          purchasedOrders.addAll(newOrders);
          page++;
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> getAllReviewsByCustomerId() async {
    try {
      int page = 1;
      bool hasMore = true;
      previousReviews.clear();
      while (hasMore) {
        final newReviews = await wooReviewRepository.fetchReviewsByUserEmail(customerEmail: userController.customer.value.email ?? '', page: page.toString());
        if (newReviews.isEmpty) {
          hasMore = false;
        } else {
          previousReviews.addAll(newReviews);
          page++;
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Extract product items from all purchased orders
  void extractCartItemsFromOrders() {
    cartItems.clear();
    for (var order in purchasedOrders) {
      if (order.lineItems != null) {
        for (var item in order.lineItems!) {
          final alreadyExists = cartItems.any((cartItem) => cartItem.productId == item.productId);
          if (!alreadyExists) {
            cartItems.add(item);
          }
        }
      }
    }
  }

  /// Filter out unreviewed products and store in unreviewedCartItems
  void filterUnreviewedPurchasedProducts() {
    unreviewedCartItems.clear();
    final reviewedProductIds = previousReviews.map((review) => review.productId).toSet();
    final unreviewed = cartItems.where((item) => !reviewedProductIds.contains(item.productId)).toList();
    unreviewedCartItems.addAll(unreviewed);
  }

  /// Refresh entire review list and purchased products
  Future<void> refreshAllReview() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      purchasedOrders.clear();
      cartItems.clear();
      unreviewedCartItems.clear();
      if(!userController.isUserLogin.value) return;
      var customerId = userController.customer.value.id;
      if(customerId == null){
        await userController.refreshCustomer();
      }
      await getAllReviewsByCustomerId();
      await getAllOrdersByCustomerId();
      extractCartItemsFromOrders();
      filterUnreviewedPurchasedProducts();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  void addReview({required int productId, required int rating}) {
    final customer = userController.customer.value;

    final newReview = ReviewModel(
      rating: rating,
      productId: productId,
      review: '⭐️ $rating star rating',
      reviewer: customer.name,
      reviewerEmail: customer.email,
      reviewerAvatarUrl: customer.avatarUrl,
    );

    final existingIndex = editedReviews.indexWhere((r) => r.productId == productId);

    if (existingIndex != -1) {
      editedReviews[existingIndex] = newReview;
    } else {
      editedReviews.add(newReview);
    }
    editedReviews.refresh();
  }

  void removeReview({required int productId}) {
    final existingIndex = editedReviews.indexWhere((r) => r.productId == productId);
    editedReviews.removeAt(existingIndex);
  }

  bool checkIsReviewExisting({required int productId}) {
    final existingIndex = editedReviews.indexWhere((r) => r.productId == productId);
    if (existingIndex != -1) {
      return true;
    } else{
      return false;
    }
  }

  // Submit Bulk Reviews
  Future<void> submitReviewBulk() async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are adding your reviews...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      if (editedReviews.isEmpty) {
        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(title: 'Error', message: 'No reviews to submit.');
        return;
      }

      // Call API to submit bulk reviews (create only)
      final List<ReviewModel> newReviewList = await wooReviewRepository.submitBulkReview(
        createReviews: editedReviews.map((review) => review.toJson()).toList(),
      );

      // Clear input fields if needed
      editedReviews.clear();
      unreviewedCartItems.removeWhere((unreviewedCartItem) => newReviewList.any((review) => review.productId == unreviewedCartItem.productId));
      // Success feedback
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Reviews submitted successfully!');
    } catch (error) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    } finally {
      Future.delayed(Duration(seconds: 3), () async {
        AppReview.showReviewPopup();
      });
    }
  }

}
