import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/text/section_heading.dart';
import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/local_storage_constants.dart';
import '../../../utils/constants/sizes.dart';
import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../models/user_model.dart';
import '../screens/user_profile/user_profile.dart';
import '../../authentication/controllers/Authentication_controller/authentication_controller.dart';

class ChangeProfileController extends GetxController {
  static ChangeProfileController get instance => Get.find();

  ///variables
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final updatePhone = TextEditingController();
  RxBool isPhoneUpdating = false.obs;
  RxBool isPhoneVerified = true.obs;

  GlobalKey<FormState> changeProfileFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updatePhoneFormKey = GlobalKey<FormState>();

  final localStorage = GetStorage();
  final userController = Get.put(AuthenticationController());
  final wooCustomersRepository = Get.put(WooCustomersRepository());

  // Woocommerce update profile details
  Future<void> wooChangeProfileDetails() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!changeProfileFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      //update single field user
      Map<String, dynamic> updateField = {
        CustomerFieldName.firstName: firstName.text.trim(),
        CustomerFieldName.lastName: lastName.text.trim(),
        CustomerFieldName.email: email.text.trim(),
        CustomerFieldName.billing: {
          AddressFieldName.email: email.text.trim(),
          AddressFieldName.phone: phone.text.trim()
        },
      };
      final userId = userController.customer.value.id.toString();
      final CustomerModel customer = await wooCustomersRepository.updateCustomerById(userID: userId, data: updateField);
      //update the Rx user value
      userController.customer(customer);

      // update email to local storage too
      localStorage.write(LocalStorage.rememberMeEmail, email.text.trim());
      //remove Loader
      FullScreenLoader.stopLoading();
      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Details updated successfully!');
      // move to next screen
      Get.close(1);
      Get.off(() => const UserProfileScreen());
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  //Woocommerce update phone number
  Future<void> wooUpdatePhoneNo() async {
    try {
      isPhoneUpdating.value = true;
      // Form Validation
      if (!updatePhoneFormKey.currentState!.validate()) {
        isPhoneUpdating.value = false;
        return;
      }
      //update single field user
      Map<String, dynamic> updateField = {
        CustomerFieldName.billing: {AddressFieldName.phone: updatePhone.text.trim()},
      };
      final userId = userController.customer.value.id.toString();
      final CustomerModel customer = await wooCustomersRepository.updateCustomerById(userID: userId, data: updateField);
      userController.customer(customer);
      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Phone updated successfully!');
      isPhoneUpdating.value = false;
      isPhoneVerified.value = true;
    } catch (error) {
      isPhoneUpdating.value = false;
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  //Woocommerce update user meta value
  Future<CustomerModel> wooUpdateUserMeta({required String userId, required String key, required dynamic value}) async {
    try {
      //update single field user
      Map<String, dynamic> updateField = {
        CustomerMetaDataName.metaData: [
          {
            "key": key,
            "value": value
          }
        ]
      };
      final CustomerModel customer = await wooCustomersRepository.updateCustomerById(userID: userId, data: updateField);
      return customer;
    } catch (error) {
      rethrow;
    }
  }

  //update mobile number
  Future<dynamic> updateMobilePopup(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(title: 'Select Address',
                onPressed: () {},
                seeActionButton: true,
                buttonTitle: 'Add new address',
              ),
              const Expanded(
                child: Text('hi'),
              ),
              const SizedBox(height: AppSizes.defaultSpace * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Select Address'),
                ),
              )
            ],
          ),
        )
    );
  }

}

