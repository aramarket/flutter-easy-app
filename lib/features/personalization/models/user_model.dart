import '../../../utils/constants/db_constants.dart';
import 'address_model.dart';

//for woocommerce
class CustomerModel {
  final int? id;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? role;
  String? username;
  AddressModel? billing;
  AddressModel? shipping;
  bool? isPayingCustomer;
  String? avatarUrl;
  String? dateCreated;
  bool? isPhoneVerified;
  String? fCMToken;
  bool? isCODBlocked;

  CustomerModel({
    this.id,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.role,
    this.username,
    this.billing,
    this.shipping,
    this.isPayingCustomer,
    this.avatarUrl,
    this.dateCreated,
    this.isPhoneVerified,
    this.fCMToken,
    this.isCODBlocked,
  });

  static CustomerModel empty() => CustomerModel(id: 0);
  String get name => '${firstName ?? ''} ${lastName ?? ''}';
  String get phone => billing?.phone ?? '';

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[CustomerFieldName.id] ?? 0,
      email: json[CustomerFieldName.email] ?? '',
      firstName: json[CustomerFieldName.firstName] ?? '',
      lastName: json[CustomerFieldName.lastName] ?? '',
      role: json[CustomerFieldName.role] ?? '',
      username: json[CustomerFieldName.username] ?? '',
      billing: AddressModel.fromJson(json[CustomerFieldName.billing] ?? {}),
      shipping: AddressModel.fromJson(json[CustomerFieldName.shipping] ?? {}),
      isPayingCustomer: json[CustomerFieldName.isPayingCustomer] ?? false,
      avatarUrl: json[CustomerFieldName.avatarUrl] ?? '',
      dateCreated: json[CustomerFieldName.dateCreated] ?? '',
      isPhoneVerified: (json[CustomerFieldName.metaData] as List?)?.any((meta) => meta['key'] == CustomerMetaDataName.verifyPhone && meta['value'] == true) ?? false,
      fCMToken: (json[CustomerFieldName.metaData] as List?)?.firstWhere((meta) => meta['key'] == CustomerMetaDataName.fCMToken, orElse: () => {'value': ''},)['value'] ?? '',
      isCODBlocked: (json[CustomerFieldName.metaData] as List?)?.any((meta) => meta['key'] == CustomerFieldName.isCODBlocked && meta['value'] == "1") ?? false,
    );
  }

  Map<String, dynamic> toJsonForWooSingUp(){
    return {
      CustomerFieldName.firstName: firstName,
      CustomerFieldName.username: username,
      CustomerFieldName.email: email,
      CustomerFieldName.password: password,
      CustomerFieldName.billing: billing?.toJsonForWoo(),
      CustomerFieldName.shipping: shipping?.toJsonForWoo(),
    };
  }
}

class CustomerMetaDataModel{
  final int? id;
  final String? key;
  final String? value;

  CustomerMetaDataModel({
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







