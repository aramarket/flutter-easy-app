import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:http/http.dart' as http;

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../settings/app_settings.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import 'checkout_controller.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find();

  final userController = Get.put(AuthenticationController());
  final checkoutController = Get.put(CheckoutController());

  static List<Map<String, String>> paymentJson = [
    {
      PaymentFieldName.id           : PaymentMethods.razorpay.name,
      PaymentFieldName.title        : PaymentMethods.razorpay.title,
      PaymentFieldName.description  : PaymentMethods.razorpay.description,
      PaymentFieldName.image        : Images.razorpay,
    },
    {
      PaymentFieldName.id           : PaymentMethods.cod.name,
      PaymentFieldName.title        : PaymentMethods.cod.title,
      PaymentFieldName.description  : PaymentMethods.cod.description,
      PaymentFieldName.image        : Images.cod,
    },
  ];

  List<PaymentModel> getAllPaymentMethod = PaymentModel.parsePaymentModels(paymentJson);

  final Razorpay _razorpay = Razorpay();

  PaymentController() {
    // Register event listeners during initialization
    _registerEventListeners();
  }


  void _registerEventListeners() {
    // Listen for payment success event
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      _completer?.complete(response.paymentId);
    });

    // Listen for payment failure event
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      // Notify user about payment failure
      _completer?.completeError("Payment failed: ${response.message}");
    });

    // Listen for payment cancel event
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      // Notify user about payment cancellation
      AppMassages.warningSnackBar(title: 'External Wallet Razorpay:', message: 'Wallet Name: ${response.walletName}');
      _completer?.completeError("Payment cancelled by user.");
    });
  }

  Completer<String>? _completer;

  Future<String> startPayment({required OrderModel order}) async {

    final int orderId = order.id ?? 0;
    final int orderTotal = int.tryParse(order.total ?? '0') ?? 0;

    // Prepare payment options
    var options = {
      'key': APIConstant.razorpayKey,
      'amount': orderTotal * 100, // * 100 Amount in smallest currency unit
      'name': AppSettings.appName,
      'description': 'orderId_#$orderId', // productName
      'prefill': {
        'contact': userController.customer.value.phone,
        'email': userController.customer.value.email,
      },
      // Notes (Custom key-value pairs for internal use)
      'notes': {
        'order_id': '#$orderId', // (String) Custom order ID for merchant reference
      },
    };

    // Create a completer to handle async operations
    _completer = Completer<String>();

    try {
      // Open the Razorpay payment interface
      _razorpay.open(options);
    } catch (e) {
      // Handle initialization errors
      _completer?.completeError("Payment initialization failed. Error: $e");
    }

    // Return the future from the completer
    return _completer!.future;
  }

  @override
  void onClose() {
    // Dispose of event listeners when the controller is closed
    _razorpay.clear();
    super.onClose();
  }

  Future<bool> capturePayment({required int amount, required String paymentID}) async {
    try {
      final Uri uri = Uri.https('api.razorpay.com', '/v1/payments/$paymentID/capture');

      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.razorpayAuth,
        },
        body: jsonEncode({
          'amount': amount * 100,
          'currency': 'INR',
        }),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['error']['description'];
        throw errorMessage ?? 'Failed to capture payment';
      }
      return true;
    } catch (error) {
      rethrow;
    }
  }
}