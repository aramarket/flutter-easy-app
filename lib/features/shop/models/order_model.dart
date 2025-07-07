import 'package:get/get.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/formatters/formatters.dart';
import '../../personalization/models/address_model.dart';
import '../../settings/app_settings.dart';
import '../controllers/checkout_controller/checkout_controller.dart';
import 'cart_item_model.dart';
import 'coupon_model.dart';

class OrderModel {
  final int? id;
  final OrderStatus? status;
  final String? currency;
  final bool? pricesIncludeTax;
  final String? dateCreated;
  final String? dateModified;
  final String? discountTotal;
  final String? discountTax;
  final String? shippingTotal;
  final String? shippingTax;
  final String? cartTax;
  final String? total;
  final String? totalTax;
  final int? customerId;
  final AddressModel? billing;
  final AddressModel? shipping;
  final String? paymentMethod;
  final String? paymentMethodTitle;
  final String? transactionId;
  final String? customerIpAddress;
  final String? customerUserAgent;
  final String? customerNote;
  final String? dateCompleted;
  final String? datePaid;
  final String? number;
  final List<OrderMedaDataModel>? metaData;
  final List<CartModel>? lineItems;
  // final List<CartItemModel>? shippingLines;
  final List<CouponModel>? couponLines;
  final String? paymentUrl;
  final String? currencySymbol;
  final bool? setPaid;

  OrderModel({
    this.id,
    this.status,
    this.currency,
    this.pricesIncludeTax,
    this.dateCreated,
    this.dateModified,
    this.discountTotal,
    this.discountTax,
    this.shippingTotal,
    this.shippingTax,
    this.cartTax,
    this.total,
    this.totalTax,
    this.customerId,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.transactionId,
    this.customerIpAddress,
    this.customerUserAgent,
    this.customerNote,
    this.dateCompleted,
    this.datePaid,
    this.number,
    this.metaData,
    this.lineItems,
    this.couponLines,
    this.paymentUrl,
    this.currencySymbol,
    this.setPaid
  });

  DateTime get parsedCreatedDate => DateTime.parse(dateCreated!);
  String get formattedOrderDate => AppFormatter.formatStringDate(dateCreated!);
  String get formattedOrderCompleted => AppFormatter.formatStringDate(dateCompleted!);

  // Method to calculate the sum of total prices
  int calculateTotalSum() {
    return lineItems?.fold<int>(0,
          (previousValue, currentItem) => previousValue + (int.tryParse(currentItem.subtotal ?? '') ?? 0),) ?? 0;
  }

  // String get orderStatusText => status == OrderStatus.delivered ? 'Delivered' : status == OrderStatus.shipped ? 'Shipment on the way' : 'Processing';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json[OrderFieldName.id],
      status: OrderStatusExtension.fromString(json[OrderFieldName.status]),
      currency: json[OrderFieldName.currency] ?? '',
      pricesIncludeTax: json[OrderFieldName.pricesIncludeTax] ?? false,
      dateCreated: json[OrderFieldName.dateCreated] ?? '',
      dateModified: json[OrderFieldName.dateModified] ?? '',
      discountTotal: json[OrderFieldName.discountTotal] ?? '',
      discountTax: json[OrderFieldName.discountTax] ?? '',
      shippingTotal: json[OrderFieldName.shippingTotal] ?? '',
      shippingTax: json[OrderFieldName.shippingTax] ?? '',
      cartTax: json[OrderFieldName.cartTax] ?? '',
      total: json[OrderFieldName.total],
      totalTax: json[OrderFieldName.totalTax] ?? '',
      customerId: json[OrderFieldName.customerId] ?? 0,
      billing: AddressModel.fromJson(json[OrderFieldName.billing]),
      shipping: AddressModel.fromJson(json[OrderFieldName.shipping]),
      paymentMethod: json[OrderFieldName.paymentMethod] ?? '',
      paymentMethodTitle: json[OrderFieldName.paymentMethodTitle] ?? '',
      transactionId: json[OrderFieldName.transactionId] ?? '',
      customerIpAddress: json[OrderFieldName.customerIpAddress] ?? '',
      customerUserAgent: json[OrderFieldName.customerUserAgent] ?? '',
      customerNote: json[OrderFieldName.customerNote] ?? '',
      dateCompleted: json[OrderFieldName.dateCompleted] ?? '',
      datePaid: json[OrderFieldName.datePaid] ?? '',
      number: json[OrderFieldName.number] ?? '',
      lineItems: List<CartModel>.from(json[OrderFieldName.lineItems].map((item) => CartModel.fromJson(item))),
      paymentUrl: json[OrderFieldName.paymentUrl] ?? '',
      currencySymbol: json[OrderFieldName.currencySymbol] ?? '',
    );
  }


  Map<String, dynamic> toJson(){
    return {
      OrderFieldName.status:        status?.name ?? '',
      OrderFieldName.discountTotal: discountTotal ?? '',
      OrderFieldName.discountTax:   discountTax ?? '',
      OrderFieldName.shippingTotal: shippingTotal ?? '',
      OrderFieldName.shippingTax:   shippingTax ?? '',
      OrderFieldName.cartTax:       cartTax ?? '',
      OrderFieldName.total:         total ?? '',
      OrderFieldName.totalTax:      totalTax ?? '',
      OrderFieldName.customerId:    customerId.toString(),
      OrderFieldName.billing:       billing?.toJsonForWoo(),
      OrderFieldName.shipping:      shipping?.toJsonForWoo(),
      OrderFieldName.paymentMethod: paymentMethod ?? '',
      OrderFieldName.paymentMethodTitle: paymentMethodTitle ?? '',
      OrderFieldName.transactionId: transactionId ?? '',
      OrderFieldName.customerIpAddress: customerIpAddress ?? '',
      OrderFieldName.customerUserAgent: customerUserAgent ?? '',
      OrderFieldName.customerNote:  customerNote ?? '',
      OrderFieldName.datePaid:      datePaid ?? '',
      OrderFieldName.lineItems:     lineItems?.map((item) => item.toJsonForWoo()).toList(),
      OrderFieldName.setPaid:     setPaid ?? false,
    };
  }

  Map<String, dynamic> toJsonForWoo() {
    final Map<String, dynamic> json = {
      OrderFieldName.customerId: customerId ?? 0,
      OrderFieldName.status: status?.name ?? '',
      OrderFieldName.paymentMethod: paymentMethod ?? '',
      OrderFieldName.paymentMethodTitle: paymentMethodTitle ?? '',
      OrderFieldName.billing: billing?.toJsonForWoo(),
      OrderFieldName.shipping: shipping?.toJsonForWoo(),
      OrderFieldName.lineItems: lineItems?.map((item) => item.toJsonForWoo()).toList(),
      OrderFieldName.metaData: metaData?.map((item) => item.toJsonForWoo()).toList(),
    };

    if(CheckoutController.instance.shipping.value != 0) {
      json[OrderFieldName.shippingLines] = shippingLines;
    }
    // Add coupon lines only if couponLines is not empty or null
    if (couponLines != null && couponLines!.isNotEmpty) {
      final List<Map<String, dynamic>> couponJsonList = couponLines!
          .where((coupon) => !coupon.areAllPropertiesNull())
          .map((coupon) => coupon.toJsonForWoo())
          .toList();
      json[OrderFieldName.couponLines] = couponJsonList;
    }
    return json;
  }

  final List<Map<String, dynamic>> shippingLines = [
    {
      "method_id": "flat_rate",
      "method_title": "Shipping",
      "total": '${AppSettings.shippingCharge}'
    }
  ];

}

class OrderMedaDataModel{
  final int? id;
  final String? key;
  final String? value;

  OrderMedaDataModel({
  this.id,
  this.key,
  this.value,
  });

  //Convert a cartItem to a Json map
  Map<String, dynamic> toJsonForWoo() {
    return {
      OrderMetaDataName.key: key ?? '',
      OrderMetaDataName.value: value ?? '',
    };
  }
}

class OrderAttributeModel {
  String? source;
  String? sourceType; // e.g., referral, organic, unknown, utm, Web Admin, typein (Direct)
  String? medium; // e.g., cart page source
  String? campaign; // e.g., google_cpc
  String? referrer; // e.g., referral URL
  DateTime? date;

  OrderAttributeModel({
    this.source,
    this.sourceType,
    this.medium,
    this.campaign,
    this.referrer,
    this.date,
  });

  Map<String, dynamic> toJson({bool isLocal = false}) {
    final Map<String, dynamic> data = {};

    if (source != null) data[OrderMetaKeyName.source] = source;
    if (sourceType != null) data[OrderMetaKeyName.sourceType] = sourceType;
    if (medium != null) data[OrderMetaKeyName.medium] = medium;
    if (campaign != null) data[OrderMetaKeyName.campaign] = campaign;
    if (referrer != null) data[OrderMetaKeyName.referrer] = referrer;
    if(isLocal){
      if (date != null) data[OrderMetaKeyName.date] = date!.toIso8601String();
    }
    return data;
  }

  factory OrderAttributeModel.fromJson(Map<String, dynamic> json) {
    return OrderAttributeModel(
      source: json[OrderMetaKeyName.source],
      sourceType: json[OrderMetaKeyName.sourceType],
      medium: json[OrderMetaKeyName.medium],
      campaign: json[OrderMetaKeyName.campaign],
      referrer: json[OrderMetaKeyName.referrer],
      date: json[OrderMetaKeyName.date] != null ? DateTime.parse(json[OrderMetaKeyName.date]) : null,
    );
  }
}
