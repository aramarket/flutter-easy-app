import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/coupons/woo_coupon_repository.dart';
import '../../models/coupon_model.dart';
import '../checkout_controller/checkout_controller.dart';

class CouponController extends GetxController {
  static CouponController get instance => Get.find();

  //Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<CouponModel> coupons = <CouponModel>[].obs;

  RxBool isCouponLoad = false.obs;
  RxString couponText = ''.obs;

  final wooCouponRepository = Get.put(WooCouponRepository());
  final checkoutController = Get.put(CheckoutController());
  final couponTextEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    couponTextEditingController.text = checkoutController.appliedCoupon.value.code?.toUpperCase() ?? '';
    couponTextEditingController.addListener(() {
      couponText.value = couponTextEditingController.text;
    });
  }

  //Get All Coupon
  Future<void> getAllCoupons() async {
    try {
      final newCoupons = await wooCouponRepository.fetchAllCoupons(currentPage.toString());
      // Filter coupons where showOnCheckout is true
      final filteredCoupons = newCoupons.where((coupon) => coupon.showOnCheckout == true).toList();
      coupons(filteredCoupons);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Function to refresh orders
  Future<void> refreshCoupons() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      coupons.clear(); // Clear existing orders
      await getAllCoupons();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  //Get Coupon by code
  Future<CouponModel> getCouponByCode(String couponCode) async {
    try {
      final CouponModel coupon = await wooCouponRepository.fetchCouponByCode(couponCode);
      return coupon;
    } catch (e) {
      rethrow;
    }
  }

  //Apply coupon
  Future<void> applyCoupon(String couponCode) async {
    try {
      isCouponLoad.value = true;
      if(couponCode.isEmpty) {
        // Handle case where the user submits an empty coupon code
        isCouponLoad.value = false;
        AppMassages.errorSnackBar(title: 'Error', message: 'Coupon should not be empty');
        return;
      }
      final CouponModel coupon = await getCouponByCode(couponCode);
      validateCoupon(coupon);
      checkoutController.appliedCoupon.value = coupon;
      checkoutController.updateCheckout();
      couponTextEditingController.text = couponCode.toUpperCase();

      AppMassages.showToastMessage(message: 'Coupon applied successfully');
      // Show the GIF
      FullScreenLoader.showCouponGif();

    } catch(error){
      // Handle error occurred during coupon retrieval
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
      return;
    } finally {
      isCouponLoad.value = false;
    }
  }

  void validateCoupon(CouponModel coupon) {
    try {
      String? validityErrorMessage = coupon.getValidityErrorMessage();
      // Apply logic based on coupon validity
      if (validityErrorMessage != null) {
        throw validityErrorMessage;
      }
    }
    catch(e){
      rethrow;
    }
  }
}