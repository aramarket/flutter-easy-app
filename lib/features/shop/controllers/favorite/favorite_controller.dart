import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/products/woo_product_repositories.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../models/product_model.dart';

class FavoriteController extends GetxController{
  static FavoriteController get instance => Get.find();

  //Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;

  final RxList<String> favorites = <String>[].obs;
  final localStorage = GetStorage();
  final wooProductRepository = Get.put(WooProductRepository());

  @override
  void onInit() {
    super.onInit();
    initFavorites();
  }

  //Method to initialize favorites by reading from storage
  void initFavorites(){
    var storedFavorite = localStorage.read(LocalStorage.wishlist);
    if (storedFavorite != null) {
      favorites.addAll(List<String>.from(storedFavorite));
    }
  }

  bool isFavorite(String productId) {
    return favorites.contains(productId) ? true : false;
  }

  void toggleFavoriteProduct({required ProductModel product}) {
    final String productId = product.id.toString();
    if(!favorites.contains(productId)) {
      favorites.add(productId);
      FBAnalytics.logAddToWishlist(product: product);
      AppMassages.showToastMessage(message: 'Product added to the wishlist.');
      saveWishlistData();
    } else {
      removeProduct(productID: productId);
      AppMassages.showToastMessage(message: 'Product removed from the wishlist.');
    }
  }

  void removeProduct({required String productID}) {
    // Backup data
    final wasFavorite = favorites.contains(productID);
    final removedProductIndex = products.indexWhere((product) => product.id.toString() == productID);
    if (removedProductIndex == -1) return;

    final removedProduct = products.removeAt(removedProductIndex);
    if (wasFavorite) {
      favorites.remove(productID);
    }

    favorites.refresh();
    products.refresh();
    saveWishlistData();

    // Show undo snackbar
    AppMassages.showSnackBar(
      massage: 'Product removed from wishlist',
      onUndo: () {
        products.insert(removedProductIndex, removedProduct);
        if (wasFavorite) {
          favorites.add(productID);
        }
        favorites.refresh();
        products.refresh();
        saveWishlistData();
      },
    );
  }


  void saveWishlistData() {
    localStorage.write(LocalStorage.wishlist, favorites); // save data in Local Storage
    // await UserRepository.instance.updateMetaData(UserFieldName.wishlistItems, favorites); //save data in Cloud Storage
  }

  Future<void> getFavoriteProducts() async {
    try {
      if(favorites.isNotEmpty){
        final newFavorites = await wooProductRepository.fetchProductsByIds(productIds: favorites.join(','), page: currentPage.toString());
        products.addAll(newFavorites);
      }
    } catch (e) {
      throw AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshFavorites() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      products.clear(); // Clear existing orders
      await getFavoriteProducts();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }
}