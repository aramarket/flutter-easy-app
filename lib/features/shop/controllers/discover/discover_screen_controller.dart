import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/products/woo_product_repositories.dart';
import '../../models/product_model.dart';
import '../product/product_controller.dart';

class DiscoverScreenController extends GetxController{
  static DiscoverScreenController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<ProductModel> discoverProducts = <ProductModel>[].obs;
  final wooProductRepository = Get.put(WooProductRepository());
  final productController = Get.put(ProductController());


  Future<void> getDiscoverProducts() async {
    try {
        final newProducts = await productController.getRandomProducts(currentPage.toString());
        discoverProducts.addAll(newProducts);
    } catch (e) {
      throw AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshDiscoverProducts() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      discoverProducts.clear(); // Clear existing orders
      await getDiscoverProducts();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }
}