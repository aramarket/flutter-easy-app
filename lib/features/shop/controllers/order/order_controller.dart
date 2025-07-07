import 'package:get/get.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/woocommerce_repositories/orders/woo_orders_repository.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../models/order_model.dart';
import '../cart_controller/cart_controller.dart';
import '../checkout_controller/checkout_controller.dart';
import '../checkout_controller/payment_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  //Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  final Rx<OrderModel> currentOrder = OrderModel().obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  final cartController = Get.put(CartController());
  final addressController = Get.put(AddressController());
  final checkoutController = Get.put(CheckoutController());
  final wooOrdersRepository = Get.put(WooOrdersRepository());
  final userController = Get.put(AuthenticationController());
  final paymentController = Get.put(PaymentController());

  Future<void> fetchOrder({required OrderModel? order, required String? orderId}) async {
    if(order != null) {
      currentOrder.value = order;
    } else if(orderId != null){
      await getOrderById(orderId: orderId);
    }
  }

  //Fetch orders
  Future<void> fetchOrders() async {
    try {
      final customerId = userController.customer.value.id.toString();
      final customerEmail = userController.customer.value.email.toString();

      final List<OrderModel> ordersByCustomerId =
          await wooOrdersRepository.fetchOrdersByCustomerId(customerId: customerId, page: currentPage.toString());
      final List<OrderModel> ordersByCustomerEmail = await wooOrdersRepository
          .fetchOrdersByCustomerEmail(customerEmail: customerEmail,page: currentPage.toString());


      final List<OrderModel> mergedOrders = [...ordersByCustomerId, ...ordersByCustomerEmail];

      // Define a function to check if two orders are equal based on some unique identifier
      bool areOrdersEqual(OrderModel order1, OrderModel order2) {
        return order1.id == order2.id; // Assuming `id` is a unique identifier for orders
      }

      // Remove duplicates from the merged list
      final List<OrderModel> uniqueOrders = [];
      for (var order in mergedOrders) {
        // Check if the order already exists in the unique orders list
        bool alreadyExists = uniqueOrders.any((existingOrder) => areOrdersEqual(existingOrder, order));
        // If the order doesn't exist in the unique orders list, add it
        if (!alreadyExists) {
          uniqueOrders.add(order);
        }
      }

      // Sort the merged orders by date
      uniqueOrders.sort((a, b) => b.parsedCreatedDate.compareTo(a.parsedCreatedDate));

      orders.addAll(uniqueOrders);
    } catch (e) {
    AppMassages.warningSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get user order by customer id
  Future<void> getOrdersByCustomerId() async {
    try {
      if(!userController.isUserLogin.value) return;
      var customerId = userController.customer.value.id;
      if(customerId == null){
        await userController.refreshCustomer();
        customerId = userController.customer.value.id;
      }
      final newOrders = await wooOrdersRepository.fetchOrdersByCustomerId(customerId: customerId.toString(), page: currentPage.toString());
      orders.addAll(newOrders);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  //Get user order by customer Email
  Future<void> getOrdersByCustomerEmail() async {
    try {
      String customerEmail = userController.customer.value.email.toString();
      if(customerEmail.isEmpty){
        await userController.refreshCustomer();
        customerEmail = userController.customer.value.email.toString();
      }
      final newOrders = await wooOrdersRepository.fetchOrdersByCustomerEmail(customerEmail: customerEmail, page: currentPage.toString());
      orders.addAll(newOrders);
    } catch (e) {
      AppMassages.warningSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get user order by id
  Future<void> getOrderById({required String orderId}) async {
    try {
      isLoading(true);
      final newOrders = await wooOrdersRepository.fetchOrderById(orderId: orderId);
      // Find the index of the order with the matching orderId in the orders list
      final int index = orders.indexWhere((order) => order.id == newOrders.id);

      if (index != -1) {
        // If the order is found, replace it with the updated order
        orders[index] = newOrders;
      }
      currentOrder.value = newOrders;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Function to refresh orders
  Future<void> refreshOrders() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      orders.clear(); // Clear existing orders
      await getOrdersByCustomerId();
      // await fetchOrders();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // Add methods for order processing
  Future<OrderModel> saveOrderByCustomerId({OrderAttributeModel? orderAttribute}) async {
    try {
      // Convert OrderAttributionModel to metadata list
      List<OrderMedaDataModel> orderMetaData = [];
      if (orderAttribute != null) {
        orderMetaData = orderAttribute.toJson().entries.map(
              (entry) => OrderMedaDataModel(key: entry.key, value: entry.value),
        ).toList();
      }
      // Add another custom meta value
      // orderMetaData.add(OrderMedaDataModel(key: "user_agent", value: "Android 13"));

      final order = OrderModel(
        customerId: userController.customer.value.id,
        paymentMethod: checkoutController.selectedPaymentMethod.value.id,
        paymentMethodTitle: checkoutController.selectedPaymentMethod.value.title,
        status: checkoutController.selectedPaymentMethod.value.id != PaymentMethods.cod.name
              ? OrderStatus.pendingPayment : OrderStatus.processing,
        billing:   userController.customer.value.billing,
        shipping:   userController.customer.value.billing, //if shipping address is different then use shipping instead billing
        lineItems:  cartController.cartItems,
        couponLines: [checkoutController.appliedCoupon.value],
        metaData: orderMetaData,
      );

      //save the order to Woocommerce
      final OrderModel createdOrder = await wooOrdersRepository.createOrderByCustomerId(order);
      return createdOrder;

    } catch(error) {
      rethrow;
    }
  }

  //Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      CartController.instance.isCancelLoading(true);
      final updatedOrder  = await wooOrdersRepository.updateStatusByOrderId(orderId, OrderStatus.cancelled.name);
      // Find the index of the order with the matching orderId in the orders list
      final int index = orders.indexWhere((order) => order.id == updatedOrder.id);

      if (index != -1) {
        // If the order is found, replace it with the updated order
        orders[index] = updatedOrder;
      } else {
        // If the order is not found, add the updated order to the list
        orders.add(updatedOrder);
      }
    } catch (error) {
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    } finally {
      CartController.instance.isCancelLoading(false);
    }
  }

  Future<void> updateOrderById({required String orderId, required Map<String, dynamic> data}) async {
    try {
      final updatedOrder  = await wooOrdersRepository.updateOrderById(orderId: orderId, data: data);
      // Find the index of the order with the matching orderId in the orders list
      final int index = orders.indexWhere((order) => order.id == updatedOrder.id);

      if (index != -1) {
        // If the order is found, replace it with the updated order
        orders[index] = updatedOrder;
      } else {
        // If the order is not found, add the updated order to the list
        orders.add(updatedOrder);
      }
    } catch (error) {
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  Future<void> makePayment({required OrderModel order}) async {
    bool isPaymentCaptured = false;
    String paymentId = '';
    try {
      FullScreenLoader.onlyCircularProgressDialog('Please wait while we process your payment...');
      paymentId = await paymentController.startPayment(order: order);
      if (paymentId.isNotEmpty) {
        // Capture payment
        isPaymentCaptured = await paymentController.capturePayment(amount: int.tryParse(order.total ?? '0') ?? 0, paymentID: paymentId);
        Map<String, dynamic> data = {
          OrderFieldName.status: OrderStatus.processing.name,
          OrderFieldName.transactionId: paymentId,
          OrderFieldName.setPaid: true,
        };
        await updateOrderById(orderId: order.id.toString(), data: data);
        FullScreenLoader.stopLoading();
        AppMassages.successSnackBar(title: 'Payment Successful:', message: 'Payment ID: $paymentId');
      }
      FullScreenLoader.stopLoading();
    } catch(e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Payment Failed', message: e.toString());
    } finally {
      if(!isPaymentCaptured){
        await paymentController.capturePayment(amount: int.tryParse(order.total ?? '0') ?? 0, paymentID: paymentId);
      }
    }
  }
}