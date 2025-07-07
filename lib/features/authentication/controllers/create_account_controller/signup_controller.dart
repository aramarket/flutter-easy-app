import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/woocommerce_repositories/authentication/woo_authentication.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../Authentication_controller/authentication_controller.dart';
import '../login_controller/login_controller.dart';

class SignupController extends GetxController{
  static SignupController get instance => Get.find();

  ///variables
  final localStorage = GetStorage();
  final hidePassword = true.obs; //Observable for hiding/showing password
  final privacyPolicyChecked = true.obs; //Observable for privacy policy checked or not
  final firstName     = TextEditingController();
  final lastName     = TextEditingController();
  final email     = TextEditingController();
  final password  = TextEditingController();
  final phone     = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>(); //Form key for form validation

  final userController = Get.put(AuthenticationController());
  final loginController = Get.put(LoginController());
  final wooAuthenticationRepository = Get.put(WooAuthenticationRepository());

  void signupWithEmailPassword() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are creating account..', Images.docerAnimation);
      final isConnected = await Get.put(NetworkManager()).isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if(!signupFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      //privacy policy check
      if(!privacyPolicyChecked.value) {
        AppMassages.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you have to read and accept the privacy Policy & Terms of Use.');
        return;
      }
      //update single field user
      Map<String, dynamic> newCustomer = {
        CustomerFieldName.firstName: firstName.text.trim(),
        CustomerFieldName.lastName: lastName.text.trim(),
        CustomerFieldName.email: email.text.trim(),
        CustomerFieldName.password: password.text,
        CustomerFieldName.role: "customer",
        CustomerFieldName.billing: {
          AddressFieldName.email: email.text.trim(),
          AddressFieldName.phone: phone.text.trim()
        },
      };

      //remove Loader
      final customer = await wooAuthenticationRepository.singUpWithEmailAndPass(newCustomer);

      //save to local storage
      if(loginController.rememberMe.value) {
        localStorage.write(LocalStorage.rememberMeEmail, email.text.trim());
        localStorage.write(LocalStorage.rememberMePassword, password.text);
      }

      FullScreenLoader.stopLoading();
      userController.login(user: customer, loginMethod: 'signup');
    } catch (error) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Oh Snap!', message: error.toString());
    }
  }

}




