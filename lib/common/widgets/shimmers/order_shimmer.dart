import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/order_helper.dart';
import '../../layout_models/product_grid_layout.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing_style.dart';
import '/common/widgets/shimmers/shimmer_effect.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key, this.itemCount = 1, this.title = '', this.height = 600 });

  final String title;
  final int itemCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double orderTileRadius = AppSizes.orderTileRadius;
    final double orderTileHeight = AppSizes.orderTileHeight;

    return GridLayout(
        mainAxisExtent: orderTileHeight,
        itemCount: itemCount,
        itemBuilder: (context, index) {
        return Container(
          padding: TSpacingStyle.defaultPagePadding,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(orderTileRadius),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.outline, // Border color
            )
          ),
          child: Stack(
            children: [
              Column(
                spacing: AppSizes.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerEffect(width: 60, height: 60),
                  Container(
                    height: 1,
                    color: AppColors.borderDark,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ShimmerEffect(width: 100, height: 17),
                          ],
                        ),
                        ShimmerEffect(width: 100, height: 17),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(top: 0, right: 0, child: OrderHelper.mapOrderStatus(OrderStatus.unknown)),
            ],
          ),
        );
      }
    );
  }
}
