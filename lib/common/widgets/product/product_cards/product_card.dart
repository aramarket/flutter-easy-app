import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../features/settings/app_settings.dart';
import '../../../../features/shop/controllers/product/product_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../features/shop/screens/all_products/all_products.dart';
import '../../../../features/shop/screens/products/products_widgets/brand.dart';
import '../../../../features/shop/screens/products/products_widgets/in_stock_label.dart';
import '../../../../features/shop/screens/products/scrolling_products.dart';
import '../../../../features/shop/screens/products/product_detail.dart';
import '../../../../features/shop/screens/products/products_widgets/product_price.dart';
import '../../../../features/shop/screens/products/products_widgets/product_star_rating.dart';
import '../../../../features/shop/screens/products/products_widgets/product_title_text.dart';
import '../../../../features/shop/screens/products/products_widgets/sale_label.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../styles/shadows.dart';
import '../../custom_shape/image/circular_image.dart';
import '../cart/cart_card_icon.dart';
import '../favourite_icon/favourite_icon.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.pageSource = 'pc', this.orientation = OrientationType.vertical});

  final ProductModel product;
  final String pageSource;
  final OrientationType orientation;


  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductScreen(product: product, pageSource: pageSource,))),
      child: orientation == OrientationType.vertical
        ? productCardVertical(context: context)
        : productCardHorizontal(context: context)
    );
  }

  Container productCardVertical({required BuildContext context}) {
    const double productImageSizeVertical = AppSizes.productImageSizeVertical;
    const double productCardVerticalHeight = AppSizes.productCardVerticalHeight;
    const double productCardVerticalWidth = AppSizes.productCardVerticalWidth;
    const double productCardVerticalRadius = AppSizes.productCardVerticalRadius;
    final salePercentage = product.calculateSalePercentage();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: productCardVerticalWidth,
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(productCardVerticalRadius),
        border: Border.all(
          width: AppSizes.defaultBorderWidth,
          color: isDark ? Colors.transparent : Theme.of(context).colorScheme.outline, // Border color
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Main Image
          Column(
            children: [
              Stack(
                children: [

                  // Carousel for images
                  CarouselSlider(
                    options: CarouselOptions(
                      height: productImageSizeVertical,
                      aspectRatio: 1.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: Random().nextInt(6) + 3),
                      // enableInfiniteScroll: false, // Disable infinite scrolling
                      viewportFraction: 1.0,
                      scrollPhysics: const NeverScrollableScrollPhysics(), // Disable touch scroll
                    ),
                    items: product.imageUrlList.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return RoundedImage(
                            image: imageUrl,
                            height: productImageSizeVertical,
                            width: productImageSizeVertical,
                            borderRadius: productCardVerticalRadius,
                            isNetworkImage: true,
                            padding: 3,
                            backgroundColor: Colors.white,
                          );
                        },
                      );
                    }).toList(),
                  ),

                  //sale tag
                  // Positioned(
                  //   top: 10,
                  //   left: 3,
                  //   child: TSaleLabel(discount: salePercentage),
                  // ),

                  // favourite icons
                  Positioned(
                    top: 0,
                    right: 0,
                    child: WishlistIcon(product: product, iconSize: 20)
                  ),

                  // Out of stock
                  Positioned(
                      bottom: 5,
                      right: 5,
                      child: product.isProductAvailable()
                          ? const SizedBox.shrink()
                          : Container(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: AppSizes.sm),
                                color: Theme.of(context).colorScheme.surface,
                                child: InStock(isProductAvailable: product.isProductAvailable()),
                            ),
                  )
                ],
              ),
              // Title and Star rating
              const SizedBox(height: AppSizes.xs),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  child: Column(
                    children: [
                      ProductTitle(title: product.name ?? '',),
                      ProductStarRating(
                        averageRating: product.averageRating ?? 0.0,
                        ratingCount: product.ratingCount ?? 0,
                        size: 12,
                      ),
                      // Brand
                      ProductBrand(brands: product.brands ?? [], size: 12),
                    ],
                  )
              ),
            ],
          ),

          // Price and Add to cart
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Price
                ProductPrice(
                  salePrice: product.salePrice,
                  regularPrice: product.regularPrice ?? 0.0,
                  size: 16,
                ),

                // Add to cart
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.xs),
                  child: CartIcon(product: product, iconSize: 20, sourcePage: pageSource,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container productCardHorizontal({required BuildContext context}) {

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    const double productImageSizeHorizontal = AppSizes.productImageSizeHorizontal;
    const double productCardHorizontalHeight = AppSizes.productCardHorizontalHeight;
    const double productCardHorizontalWidth = AppSizes.productCardHorizontalWidth;
    const double productCardHorizontalRadius = AppSizes.productCardHorizontalRadius;
    final salePercentage = product.calculateSalePercentage();
    final productController = Get.put(ProductController(), permanent: true);

    return Container(
      width: productCardHorizontalWidth,
      // width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(productCardHorizontalRadius),
        border: Border.all(
          width: AppSizes.defaultBorderWidth,
          color: isDark ? Colors.transparent : Theme.of(context).colorScheme.outline, // Border color
        )
      ),
      child: Row(
        children: [
          // Main Image
          Stack(
            children: [
              // Thumbnail Image
              RoundedImage(
                  image: product.mainImage ?? '',
                  height: productImageSizeHorizontal,
                  width: productImageSizeHorizontal,
                  borderRadius: productCardHorizontalRadius,
                  isNetworkImage: true,
                  padding: 0
              ),

              //Sale Percentage
              // Positioned(
              //   top: 5,
              //   left: 3,
              //   child: TSaleLabel(discount: salePercentage, size: 10,)
              // ),

              // favourite icons
              Positioned(
                  top: -5,
                  right: -5,
                  child: WishlistIcon(product: product, iconSize: 20)
              ),

              // Out of stock
              Positioned(
                bottom: 5,
                right: 0,
                child: product.isProductAvailable()
                    ? const SizedBox.shrink()
                    : Container(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: AppSizes.sm),
                  color: Theme.of(context).colorScheme.surface,
                  child: InStock(isProductAvailable: product.isProductAvailable()),
                ),
              )
            ],
          ),

          // Title, Rating and price
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductTitle(title: product.name ?? '',),
                          // Star rating
                          ProductStarRating(averageRating: product.averageRating ?? 0.0, ratingCount: product.ratingCount ?? 0, size: 12,),
                          // Brand
                          ProductBrand(brands: product.brands ?? [], size: 12),
                        ],
                      ),
                      // Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProductPrice(
                              salePrice: product.salePrice ?? product.price,
                              regularPrice: product.regularPrice ?? 0.0,
                              orientationType: OrientationType.horizontal,
                              size: 16
                          ),
                          // Add to cart
                          CartIcon(product: product, iconSize: 20, sourcePage: pageSource,),
                        ],
                      )
                    ],
                  ),
            ),
          )
        ],
      ),
    );
  }
}










