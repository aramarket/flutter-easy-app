import 'package:flutter/material.dart';

import '../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../constants/db_constants.dart';
import '../constants/enums.dart';
import '../constants/sizes.dart';

class OrderHelper {

  static bool checkOrderStatusForInTransit(OrderStatus orderStatus) {
    return  orderStatus == OrderStatus.pendingPickup ||
            orderStatus == OrderStatus.inTransit ||
            orderStatus == OrderStatus.completed ||
            orderStatus == OrderStatus.returnInTransit ||
            orderStatus == OrderStatus.returnPending ||
            orderStatus == OrderStatus.returnInTransit;
  }

  static bool checkOrderStatusForReturn(OrderStatus orderStatus) {
    return orderStatus == OrderStatus.processing;
  }

  static bool checkOrderStatusForPayment(OrderStatus orderStatus) {
    return orderStatus == OrderStatus.pendingPayment;
  }

  static Widget mapOrderStatus(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.cancelled:
        return statusWidget(status: OrderStatusPritiName.cancelled, color: Colors.red);
      case OrderStatus.processing:
        return statusWidget(status: OrderStatusPritiName.processing, color: Colors.green);
      case OrderStatus.readyToShip:
        return statusWidget(status: OrderStatusPritiName.readyToShip, color: Colors.orange);
      case OrderStatus.pendingPickup:
        return statusWidget(status: OrderStatusPritiName.pendingPickup, color: Colors.orange);
      case OrderStatus.pendingPayment:
        return statusWidget(status: OrderStatusPritiName.pendingPayment, color: Colors.redAccent);
      case OrderStatus.inTransit:
        return statusWidget(status: OrderStatusPritiName.inTransit, color: Colors.orange);
      case OrderStatus.completed:
        return statusWidget(status: OrderStatusPritiName.completed, color: Colors.blue);
      case OrderStatus.returnInTransit:
        return statusWidget(status: OrderStatusPritiName.returnInTransit, color: Colors.grey);
      case OrderStatus.returnPending:
        return statusWidget(status: OrderStatusPritiName.returnPending, color: Colors.grey);
      default:
        return statusWidget(status: OrderStatus.unknown.prettyName, color: Colors.grey);
    }
  }

  static RoundedContainer statusWidget({required String status, required Color color}) {
    return RoundedContainer(
          radius: 10,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          child: Text(status, style: const TextStyle(fontSize: 14, color: Colors.white))
      );
  }

}