import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/product/quantity_add_buttons/quantity_add_buttons.dart';
import '../../../../common/widgets/shimmers/single_product_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../services/share/share.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/icons.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../settings/app_settings.dart';
import '../../controllers/cart_controller/cart_controller.dart';
import '../../controllers/product/product_controller.dart';
import '../../controllers/recently_viewed/recently_viewed_controller.dart';
import '../../models/product_model.dart';
import '../all_products/all_products.dart';
import 'scrolling_products_by_item_id.dart';
import 'scrolling_products.dart';
import '../review/product_review.dart';
import 'products_widgets/bottom_add_to_cart.dart';
import 'products_widgets/in_stock_label.dart';
import 'products_widgets/product_image_slider.dart';
import 'products_widgets/product_star_rating.dart';
import 'products_widgets/product_price.dart';

class ProductDetailScreen1 extends StatefulWidget {
  const ProductDetailScreen1({super.key, this.product, this.slug, this.productId});

  final ProductModel? product;
  final String? productId;
  final String? slug;

  @override
  State<ProductDetailScreen1> createState() => _ProductDetailScreenState1();
}

class _ProductDetailScreenState1 extends State<ProductDetailScreen1> {
  final RxBool _isLoading = false.obs;
  RxInt quantityInCart = 1.obs;

  final Rx<ProductModel> _product = ProductModel.empty().obs;
  final cartController = Get.put(CartController());
  final productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    _fetchProduct(product: widget.product, slug: widget.slug, productId: widget.productId);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Fetch product data when the screen is loaded
  //   WidgetsBinding.instance?.addPostFrameCallback((_) {
  //     quantityInCart.value = cartController.getCartQuantity(_product.value.id);
  //     // _refreshProduct(); // Call the method to set isLoading after the widget is built
  //   });
  // }

  Future<void> _fetchProduct({ProductModel? product, String? slug, String? productId}) async {
    try {
      _isLoading(true);
      // this.product.value = ProductModel.empty();
      if (product != null) {
        // If product is provided, set it directly
        _product.value = product;
      } else if (slug != null) {
        final fetchedProduct = await productController.getProductBySlug(slug);
        _product.value = fetchedProduct;
      } else if (productId != null) {
        final fetchedProduct = await productController.getProductById(productId);
        _product.value = fetchedProduct;
      } else {
        throw Exception('Either product or productId must be provided.');
      }
    } catch (e) {
      rethrow;
    } finally {
      quantityInCart.value = cartController.getCartQuantity(_product.value.id);
      _isLoading(false); // Set loading state to false
    }
  }

  //Get products by Refresh page
  Future<void> _refreshProduct() async {
    final productId = _product.value.id;
    try {
      _product.value = ProductModel.empty();
      await _fetchProduct(productId: productId.toString());
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('product1_screen');

    // Adding the product to recently viewed outside Obx's reactive context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_product.value.id != 0) {
        RecentlyViewedController.instance.addRecentProduct(_product.value.id.toString());
      }
    });

    return Scaffold(
      appBar: AppAppBar(title: widget.product?.name ?? 'Product Details', showCartIcon: true),
      bottomNavigationBar: Obx(() => TBottomAddToCart(product: _product.value, quantity: quantityInCart.value, pageSource: 'product_detail1',)),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshProduct(),
        child: ListView(
          padding: TSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Obx(() {
              if (_isLoading.value){
                return const SingleProductShimmer();
              }
              if(_product.value.id == 0) {
                return const AnimationLoaderWidgets(
                  text: 'Whoops! No Product Found...',
                  animation: Images.pencilAnimation,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // //search bar
                  // const TSearchBar(searchText: TTexts.search),
                  // const Divider(),

                  //product images
                  TProductImageSlider(product: _product.value),
                  const SizedBox(height: AppSizes.sm),
                  const Divider(),

                  //Breadcrumb
                  InkWell(onTap: () =>
                      Get.to(() => TAllProducts(
                          title: _product.value.categories?[0].name ?? '',
                          categoryId: _product.value.categories?[0].id ?? '',
                          sharePageLink: '${AppSettings.appName} - ${_product.value.categories?[0].permalink}',
                          futureMethodTwoString: productController.getProductsByCategoryId)
                      ),
                      child: Row(
                        children: [
                          Text(_product.value.categories?[0].name ?? '',
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.linkColor)
                          ),
                          SizedBox(width: AppSizes.sm,),

                          GestureDetector(
                            onTap: () => AppShare.shareUrl(
                                url: '${_product.value.categories?[0].permalink}',
                                contentType: 'Category',
                                itemName: _product.value.categories?[0].name ?? '',
                                itemId: _product.value.categories?[0].id ?? ''
                            ),
                            child: Icon(
                              AppIcons.share,
                              size: AppSizes.md,
                              color: AppColors.linkColor,
                            ),
                          )
                        ],
                      )
                  ),

                  //Product detail page Title description
                  const SizedBox(height: AppSizes.sm),
                  Text(_product.value.name ?? '', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),),

                  //Star Rating
                  const SizedBox(height: AppSizes.sm),
                  ProductStarRating(
                      averageRating: _product.value.averageRating ?? 0.0,
                      ratingCount: _product.value.ratingCount ?? 0,
                      onTap: () => Get.to(() => ProductReviewScreen(product: _product.value)),
                      size: 18
                  ),

                  //Price
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      TOfferWidget(label: '${_product.value.calculateSalePercentage()}% off'),
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      ProductPrice(salePrice: _product.value.salePrice,
                          regularPrice: _product.value.regularPrice ?? 0.0,
                      ),
                      // const SizedBox(width: TSizes.spaceBtwItems),
                      // TSaleLabel(discount: salePercentage),
                    ],
                  ),

                  //Free Delivery
                  _product.value.getPrice() >= 999
                      ? RoundedContainer(
                          radius: AppSizes.defaultProductRadius,
                          backgroundColor: Colors.blue.shade50,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Free Delivery', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.linkColor)),
                              const SizedBox(width: AppSizes.spaceBtwItems),
                              Icon(AppIcons.truck, color: AppColors.linkColor, size: 15),
                              const SizedBox(width: 5),
                            ],
                          )
                        )
                      : RoundedContainer(
                            radius: AppSizes.defaultProductRadius,
                            backgroundColor: Colors.blue.shade50,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Free delivery over ₹999', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.linkColor)),
                                const SizedBox(width: AppSizes.spaceBtwItems),
                                Icon(AppIcons.truck, color: AppColors.linkColor, size: 15),
                                const SizedBox(width: 5),
                              ],
                            )
                        ),

                  //Stock Status
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  InStock(isProductAvailable: _product.value.isProductAvailable()),

                  // const SizedBox(height: TSizes.sm),
                  const SectionHeading(title: 'Select Quantity'),
                  Obx(() {
                    return QuantityAddButtons(
                          size: 35,
                          quantity: quantityInCart.value,
                          // Accessing value of RxInt
                          add: () => quantityInCart.value += 1,
                          // Incrementing value
                          remove: () => quantityInCart.value <= 1
                              ? null
                              : quantityInCart.value -= 1,
                        );
                  }),

                  const SizedBox(height: AppSizes.sm),
                  ProductsScrollingByItemID(
                      itemName: 'Frequently Bought together',
                      itemID: _product.value.id.toString(),
                      futureMethod: productController.getFBTProducts
                  ),

                  const SizedBox(height: AppSizes.spaceBtwSection),
                  _product.value.description != ''
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeading(title: 'Description'),
                            const SizedBox(height: AppSizes.sm),
                            // Text(product.description ?? ''),
                            Html(data: _product.value.description)
                          ],
                        )
                      : const SizedBox.shrink(),

                  //Shown products by category
                  ProductsScrollingByItemID(
                      itemName: _product.value.categories?[0].name ?? '',
                      itemID: _product.value.categories?[0].id ?? '',
                      futureMethod: productController.getProductsByCategoryId
                  ),
                  const SizedBox(height: AppSizes.sm),

                  //Shown products by related products, up sale,cross sale
                  ProductsScrollingByItemID(
                      itemName: 'Related Products',
                      itemID: _product.value.getAllRelatedProductsIdsAsString(),
                      futureMethod: productController.getProductsByIds
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Divider(),

                  //Review
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 250,
                          child: SectionHeading(title: 'Reviews(${_product.value.ratingCount})')),
                      IconButton(
                          onPressed: () => Get.to(() => ProductReviewScreen(product: _product.value)),
                          icon: const Icon(Iconsax.arrow_right_3, size: 18)
                      )
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TOfferWidget extends StatelessWidget {
  const TOfferWidget({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.offerColor, fontWeight: FontWeight.w600));
  }
}