import 'package:aramarket/features/shop/models/brand_model.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/brands/woo_brands_repository.dart';
import '../../../../data/repositories/woocommerce_repositories/category/woo_category_repository.dart';
import '../../../../data/repositories/woocommerce_repositories/products/woo_product_repositories.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../recently_viewed/recently_viewed_controller.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  // RxBool isLoading = false.obs;
  // Rx<ProductModel> product = ProductModel.empty().obs; // Initialize with a default value if necessary
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;

  final wooProductRepository = Get.put(WooProductRepository());
  final wooCategoryRepository = Get.put(WooCategoryRepository());
  final wooBrandsRepository = Get.put(WooBrandsRepository());
  final recentlyViewedController = Get.put(RecentlyViewedController());


  // Get All products
  Future<List<ProductModel>> getAllProducts(String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchAllProducts(page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get All products
  Future<List<ProductModel>> getRandomProducts(String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchRandomProducts(page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get All Featured products
  Future<List<ProductModel>> getFeaturedProducts(String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchFeaturedProducts(page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get Products under ₹199
  Future<List<ProductModel>> getProductsUnderPrice(String price, String page) async {
    try{
      //fetch products
      // final products = await compute(() => wooProductRepository.fetchProductsUnderPrice(page: page, price: price));
      final products = await wooProductRepository.fetchProductsUnderPrice(page: page, price: price);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get recent products
  Future<List<ProductModel>> getRecentProducts(String page) async {
    try{
      //fetch products
      if(recentlyViewedController.recentlyViewed.isNotEmpty) {
        final jointedString = recentlyViewedController.recentlyViewed.reversed.toList().join(',');
        final products = await wooProductRepository.fetchProductsByIds(productIds: jointedString, page: page);
        return products;
      }else{
        return [];
      }
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get products by category id
  Future<List<ProductModel>> getProductsByCategoryId(String categoryId, String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchProductsByCategoryID(categoryId: categoryId, page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get products by category id
  Future<List<ProductModel>> getProductsByBrandId(String brandID, String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchProductsByBrandID(brandID: brandID, page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get products by category slug
  Future<List<ProductModel>> getProductsByBrandSlug(String slug, String page) async {
    try{
      //fetch products
      final BrandModel brand = await wooBrandsRepository.fetchBrandBySlug(slug);
      final products = await wooProductRepository.fetchProductsByBrandID(brandID: brand.id.toString(), page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }
  // Get products by category slug
  Future<List<ProductModel>> getProductsByCategorySlug(String slug, String page) async {
    try{
      //fetch products
      final CategoryModel category = await wooCategoryRepository.fetchCategoryBySlug(slug);
      final products = await wooProductRepository.fetchProductsByCategoryID(categoryId: category.id ?? '', page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  // Get products by products ids
  Future<List<ProductModel>> getProductsByIds(String productIds, String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchProductsByIds(productIds: productIds, page: page);
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> getVariationByProductsIds({required String parentID}) async {
    try {
      final List<ProductModel> variations = await wooProductRepository.fetchVariationByProductsIds(parentID: parentID);
      return variations;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Variation Fetching', message: e.toString());
      return [];
    }
  }

  //Get products by product id
  Future<ProductModel> getProductById(String productsId) async {
    try{
      //fetch products
      final ProductModel product = await wooProductRepository.fetchProductById(productsId);
      return product;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return ProductModel.empty();
    }
  }


  //Get products by product's slug
  Future<ProductModel> getProductBySlug(String permalink) async {
    try{
      //fetch products
      final ProductModel product = await wooProductRepository.fetchProductBySlug(permalink);
      return product;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return ProductModel.empty();
    }
  }

  // Get Products By Search Query
  Future<List<ProductModel>> getProductsBySearchQuery(String searchQuery) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchProductsBySearchQuery(query: searchQuery, page: '1');
      return products;
    } catch (e){
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }

  //Get Products By Search Query
  Future<List<ProductModel>> getFBTProducts(String productId, String page) async {
    try{
      //fetch products
      final products = await wooProductRepository.fetchFBTProducts(productId: productId);
      return products;
    } catch (e){
      // TLoaders.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
      return [];
    }
  }
}
