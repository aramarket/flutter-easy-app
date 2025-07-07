import 'package:flutter/material.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/widgets/product/product_cards/product_card.dart';
import '../../../../common/widgets/shimmers/product_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/cloud_helper_function.dart';
import '../../controllers/product/product_controller.dart';
import '../../models/category_model.dart';

class TSubCategoriesScreen extends StatelessWidget {
  const TSubCategoriesScreen({super.key, required this.category});

  final CategoryModel category;
  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('sub_categories_screen');

    final productController = ProductController.instance;
    return Scaffold(
      appBar: AppAppBar(title: category.name ?? '', showBackArrow: true),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: productController.getProductsByCategoryId(category.id ?? '', '1'),
            builder: (context, snapshot){
              //Nothing Found Widget
              const emptyWidget = AnimationLoaderWidgets(
                text: 'Whoops! No product fount in this category',
                animation: Images.pencilAnimation,
              );
              const loader = ProductShimmer(itemCount: 4);
              final widget = TCloudHelperFunction.checkMultiRecodeState(snapshot: snapshot, loader: loader, nothingFound: emptyWidget);
              if(widget != null) return SizedBox(height: 600, child: widget);
              final products = snapshot.data!;
              return Column(
                children: [
                  GridLayout(
                    mainAxisExtent: 290,
                    itemCount: products.length,
                    itemBuilder: (_, index) => ProductCard(product: products[index],pageSource: 'sub_categories'),
                  ),
                ],
              );
            }
        ),
      )
    );
  }
}
