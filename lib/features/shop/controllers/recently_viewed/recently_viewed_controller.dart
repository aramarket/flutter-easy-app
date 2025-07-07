
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../models/product_model.dart';
import '../product/product_controller.dart';

class RecentlyViewedController extends GetxController{
  static RecentlyViewedController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<String> recentlyViewed = <String>[].obs;      //   10913, 10914
  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    initFavorites();
  }

  //Method to initialize favorites by reading from storage
  void initFavorites(){
    var storedFavorite = localStorage.read(LocalStorage.recentlyViewed);
    if (storedFavorite != null) {
      recentlyViewed.addAll(List<String>.from(storedFavorite));
    }
  }

  void addRecentProduct(String productId) {
    if(!recentlyViewed.contains(productId)) {
      recentlyViewed.add(productId);
      saveRecentData();
    }
  }

  void removeProduct({required String productID}) {
    // Backup data
    final wasRecentlyViewed = recentlyViewed.contains(productID);
    final removedProductIndex = products.indexWhere((product) => product.id.toString() == productID);
    if (removedProductIndex == -1) return;

    final removedProduct = products.removeAt(removedProductIndex);
    if (wasRecentlyViewed) {
      recentlyViewed.remove(productID);
    }

    // Refresh UI
    recentlyViewed.refresh();
    products.refresh();
    saveRecentData();

    // Show undo snackbar
    AppMassages.showSnackBar(
      massage: 'Product removed',
      onUndo: () {
        products.insert(removedProductIndex, removedProduct);
        if (wasRecentlyViewed) {
          recentlyViewed.add(productID);
        }
        recentlyViewed.refresh();
        products.refresh();
        saveRecentData();
      },
    );
  }


  void clearHistory() {
    recentlyViewed.clear();
    products.clear(); // Clear existing orders
    localStorage.write(LocalStorage.recentlyViewed, recentlyViewed); //save data in Local Storage
  }

  Future<void> saveRecentData() async {
    localStorage.write(LocalStorage.recentlyViewed, recentlyViewed); //save data in Local Storage
    // await UserRepository.instance.appendMetaData(UserFieldName.recentItems, productId); //save data in Cloud Storage
  }

  Future<void> getRecentProducts() async {
    try {
      if(recentlyViewed.isNotEmpty) {
        final newFavorites = await ProductController().getRecentProducts(currentPage.toString());
        products.addAll(newFavorites);
      }
    } catch (e) {
      throw AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshRecentProducts() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      products.clear(); // Clear existing orders
      await getRecentProducts();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }
}