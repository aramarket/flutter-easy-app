import 'package:aramarket/features/settings/app_settings.dart';
import 'package:aramarket/utils/formatters/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/web_view/my_web_view.dart';
import '../../../../../utils/constants/api_constants.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/order_helper.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../models/order_model.dart';
import '../single_order_screen.dart';
import 'order_image_gallery.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final double orderImageHeight = AppSizes.orderImageHeight;
    final double orderImageWidth = AppSizes.orderImageWidth;
    final double orderTileHeight = AppSizes.orderTileHeight;
    final double orderTileRadius = AppSizes.orderTileRadius;
    final orderController = Get.find<OrderController>();

    return InkWell(
      onTap: () => Get.to(() => SingleOrderScreen(order: order)),
      child: Container(
        padding: TSpacingStyle.defaultPagePadding,
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(orderTileRadius),
          border: Border.all(
            width: AppSizes.defaultBorderWidth,
            color: Theme.of(context).colorScheme.outline, // Border color
          )
        ),
        child: Column(
          children: [
            Column(
              spacing: AppSizes.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Number'),
                    Row(
                      spacing: AppSizes.sm,
                      children: [
                        Text(' #${order.id}'),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: order.id.toString()));
                            // You might want to show a snackbar or toast to indicate successful copy
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Id copied')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 17,),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Total'),
                    Row(
                      children: [
                        Text('${AppSettings.appCurrencySymbol}${order.total}'),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Date'),
                    Row(
                      children: [
                        Text(AppFormatter.formatStringDate(order.dateCreated ?? '')),
                      ],
                    ),
                  ],
                ),
                OrderHelper.checkOrderStatusForPayment(order.status ?? OrderStatus.unknown)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Pending'),
                          SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: AppSizes.md), // Removes default padding
                              ),
                              onPressed: () => orderController.makePayment(order: order),
                              child: Row(
                                spacing: AppSizes.sm,
                                children: [
                                  Text('Pay Now', style: TextStyle(fontSize: 13),),
                                  Icon(Icons.payment, size: 14, color: Theme.of(context).colorScheme.onSurface,)
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Status'),
                          Row(
                            spacing: AppSizes.sm,
                            children: [
                              Text(order.status?.prettyName ?? ''),
                              if(OrderHelper.checkOrderStatusForInTransit(order.status ?? OrderStatus.unknown))
                                InkWell(
                                onTap: () => Get.to(() => MyWebView(title: 'Track Order #${order.id}', url: APIConstant.wooTrackingUrl + order.id.toString())),
                                child: const Icon(Icons.open_in_new, size: 17, color: AppColors.linkColor,),
                              )
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: AppSizes.xs),
                OrderImageGallery(order: order, galleryImageHeight: 40),
              ],
            ),
            // Positioned(top: 0, right: 0, child: TOrderHelper.mapOrderStatus(order.status ?? OrderStatus.unknown)),
          ],
        ),
      ),
    );
  }
}
