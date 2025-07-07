import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/products/woo_product_repositories.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../screens/cart/cart.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  // Variables
  RxBool isLoading = false.obs;
  RxBool isCancelLoading = false.obs;
  RxInt noOfCartItems = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxInt productQuantityInCart = 1.obs;
  RxList<CartModel> cartItems = <CartModel>[].obs;

  List<String> productIdsForCloud = [];
  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  // Add to cart
  void addToCart({required ProductModel product, required int quantity, int variationId = 0, String pageSource = 'atc'}) {
    try {
      // Quantity Check
      if (quantity < 1) {
        throw 'Select Quantity';
      }
      // Out of stock status
      if (!product.isProductAvailable()) {
        throw 'Selected product is out of stock';
      }
      // Check for variable product
      if(product.type == ProductFieldName.typeVariable) {
        if(variationId == 0) {
          throw 'Please Select at least one variation';
        }
      }
      // Convert the productModel to a cartItemModel with the give quantity
      final selectedCartItem = convertProductToCart(product: product, quantity: quantity, variationId: variationId, pageSource: pageSource);

      // Check if item already in cart or not
      int index = cartItems.indexWhere(
              (cartItem) => cartItem.productId == selectedCartItem.productId && cartItem.variationId == selectedCartItem.variationId
      );
      if (index >= 0) {
        // This quantity is already added or updated/remove from the design
        cartItems[index].quantity = selectedCartItem.quantity;
        cartItems[index].subtotal = (selectedCartItem.quantity * cartItems[index].price!).toStringAsFixed(0);
      } else {
        cartItems.add(selectedCartItem);
      }

      // Log the add to cart event
      FBAnalytics.logAddToCart(cartItem: selectedCartItem);
      //update cart and show success message
      updateCart();
      AppMassages.showToastMessage(message: 'Product added ${selectedCartItem.quantity} product to Cart.');
    } catch(e) {
      AppMassages.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      rethrow;
    }
  }

  // Toggle Cart item
  void toggleCartProduct({required ProductModel product, required String sourcePage}) {
    if(!isInCart(product.id)) {
      addToCart(product: product, quantity: 1, pageSource: sourcePage);
    } else {
      // Convert the productModel to a cartItemModel with the give quantity
      final convertedCartItem = convertProductToCart(product: product, quantity: 1);
      removeFromCart(item: convertedCartItem);
    }
  }

  void removeFromCart({required CartModel item}) {
    // Log the remove from cart event
    FBAnalytics.logRemoveFromCart(cartItem: item);

    int index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index >= 0) {
      // Save item temporarily for undo
      final removedItem = cartItems.removeAt(index);
      updateCart();
      AppMassages.showSnackBar(
        massage: 'Item removed from cart',
        onUndo:  () {
          cartItems.insert(index, removedItem);
          updateCart();
        }
      );
    }
  }

  // Show dialog box before removing product
  void removeFromCartDialog({required CartModel cartItem, required BuildContext context} ) {
    DialogHelper.showDialog(
        title: 'Remove Product',
        message: 'Are you sure you want to remove this product?',
        toastMessage: 'Product removed form the cart.',
        context: context,
        actionButtonText: 'Remove',
        onSubmit: () async {
          //remove the item form cart
          removeFromCart(item: cartItem);
        }
    );
  }

  // Add single item to cart
  void addOneToCart(CartModel item) {
    int index = cartItems.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0){
      //This quantity is already added or updated/remove from the design
      cartItems[index].quantity += 1;
      cartItems[index].subtotal = (cartItems[index].quantity * cartItems[index].price!).toStringAsFixed(0);
    } else{
      cartItems.add(item);
    }
    updateCart();
  }

  // Remove single item to cart
  void removeOneToCart({required CartModel cartItem, required BuildContext context}) {
    int index = cartItems.indexWhere((cartItem) => cartItem.productId == cartItem.productId);
    if(index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
        cartItems[index].subtotal = (cartItems[index].quantity * cartItems[index].price!).toStringAsFixed(0);
      } else {
        // Show dialog before completely removing
        cartItems[index].quantity == 1 ? removeFromCartDialog(cartItem: cartItem, context: context) : cartItems.removeAt(index);
      }
    }
    updateCart();
  }

  // Update cart
  void updateCart() {
    updateCartTotal();
    saveCartItems();
    cartItems.refresh();
  }

  // Update cart total
  void updateCartTotal(){
    double calculateTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for(var item in cartItems){
      calculateTotalPrice += (item.price!) * item.quantity;
      calculatedNoOfItems += item.quantity;
    }
    totalCartPrice.value = calculateTotalPrice;
    noOfCartItems.value = calculatedNoOfItems;
  }

  // Get cart quantity for a given product
  int getCartQuantity(int productId) {
    // Find the product in the cart items and calculate the total quantity
    final cartQuantity = cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);

    // If no item is found, return 1, otherwise return the calculated quantity
    return cartQuantity <= 0 ? 1 : cartQuantity;
  }

  // Clear cart
  void clearCart(){
    productQuantityInCart.value = 0;
    cartItems.clear();
    updateCart();
  }

  // Check product is in cart
  bool isInCart(int productId) {
    int index = cartItems.indexWhere((cartItem) => cartItem.productId == productId);
    if(index >= 0){
      return true;
    } else{
      return false;
    }
  }

  // Save cart data to local storage
  void saveCartItems() {
    final cartItemsStrings = cartItems.map((item) => item.toJson()).toList();
    localStorage.write(LocalStorage.cartItems, cartItemsStrings);
  }

  // Load cart items from local storage
  void loadCartItems() {
    final List<dynamic>? cartItemStrings = localStorage.read(LocalStorage.cartItems);
    if (cartItemStrings != null) {
      List<CartModel> cartItemModels = [];

      for (final itemString in cartItemStrings) {
        final Map<String, dynamic> itemJson = itemString as Map<String, dynamic>;
        cartItemModels.add(CartModel.fromJsonLocalStorage(itemJson));
      }

      cartItems.assignAll(cartItemModels);
      updateCartTotal();
    }
  }

  // This function converts a productModel to a cartItemModel
  CartModel convertProductToCart({required ProductModel product, required int quantity, int variationId = 0, String pageSource = 'cpc'}) {
    return CartModel(
      id: 1,
      name: product.name,
      productId: product.id,
      variationId: variationId,
      quantity: quantity,
      category: product.categories?[0].name,
      subtotal: (quantity * product.getPrice()).toStringAsFixed(0),
      subtotalTax: '0',
      totalTax: '0',
      sku: product.sku,
      price: product.getPrice().toInt(),
      image: product.mainImage,
      parentName: '0',
      isCODBlocked: product.isCODBlocked,
      pageSource: pageSource,
    );
  }

  // Repeat order
  Future<void> repeatOrder(List<CartModel> selectedCartItems) async {
    try{
      isLoading.value = true; // Show loader
      List<String> productIds = selectedCartItems.map((item) => item.productId.toString()).toList();
      List<ProductModel> products = await WooProductRepository.instance.fetchProductsByIds(productIds: productIds.join(','), page: '1');
      // Add to cart Using forEach method
      for (var product in products) {
        // Find the corresponding CartItemModel
        var cartItem = selectedCartItems.firstWhere((item) => item.productId == product.id,
          orElse: () => CartModel(productId: product.id, quantity: 1),
        );
        // Add to cart
        isLoading.value = false; // Show loader
        addToCart(product: product, quantity: cartItem.quantity, pageSource: 'repeat_order');
      }
      // cartItems.addAll(selectedCartItems);
      Get.to(() => const CartScreen());
    }catch(error){
      isLoading.value = false; // Show loader
      rethrow;
    }
  }
}