import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/data/state_iso_code_map.dart';
import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../shop/controllers/checkout_controller/checkout_controller.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';
import '../../authentication/controllers/Authentication_controller/authentication_controller.dart';

class AddressController extends GetxController{
  static AddressController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final pincode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  RxBool refreshData = true.obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final userController = Get.put(AuthenticationController());
  final wooCustomersRepository = Get.put(WooCustomersRepository());
  final checkoutController = Get.put(CheckoutController());


  Future<void> wooUpdateAddress(bool isShippingAddress) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your Address..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!addressFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      if(isShippingAddress){
        //update single field user
        Map<String, dynamic> updateShippingField = {
          CustomerFieldName.shipping: {
            AddressFieldName.firstName: firstName.text.trim(),
            AddressFieldName.lastName: lastName.text.trim(),
            AddressFieldName.address1: address1.text.trim(),
            AddressFieldName.address2: address2.text.trim(),
            AddressFieldName.city: city.text.trim(),
            AddressFieldName.pincode: pincode.text.trim(),
            AddressFieldName.state: StateData.getISOFromState(state.text.trim()),
            AddressFieldName.country: CountryData.getISOFromCountry(country.text.trim()),
          },
        };
        final userId = Get.put(AuthenticationController()).customer.value.id.toString();
        final CustomerModel customer = await wooCustomersRepository.updateCustomerById(userID: userId, data: updateShippingField);
        userController.customer(customer);
      } else {
        //update single field user
        Map<String, dynamic> updateBillingField = {
          CustomerFieldName.billing: {
            AddressFieldName.firstName: firstName.text.trim(),
            AddressFieldName.lastName: lastName.text.trim(),
            AddressFieldName.address1: address1.text.trim(),
            AddressFieldName.address2: address2.text.trim(),
            AddressFieldName.city: city.text.trim(),
            AddressFieldName.pincode: pincode.text.trim(),
            AddressFieldName.state: StateData.getISOFromState(state.text.trim()),
            AddressFieldName.country: CountryData.getISOFromCountry(country.text.trim()),
          },
        };
        final userId = Get.put(AuthenticationController()).customer.value.id.toString();
        final CustomerModel customer = await wooCustomersRepository.updateCustomerById(userID: userId, data: updateBillingField);
        userController.customer(customer);
        checkoutController.updateCheckout();
      }
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Address updated successfully!');
      Navigator.of(Get.context!).pop();
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

}