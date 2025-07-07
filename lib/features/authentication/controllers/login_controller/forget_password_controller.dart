import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/woocommerce_repositories/authentication/woo_authentication.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../screens/email_login/reset_password_screen.dart';

class ForgetPasswordController extends GetxController{
  static ForgetPasswordController get instance => Get.find();

  ///variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>(); //Form key for form validation

  final wooAuthenticationRepository = Get.put(WooAuthenticationRepository());

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('Processing your request..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        //remove Loader
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if(!forgetPasswordFormKey.currentState!.validate()) {
        //remove Loader
        FullScreenLoader.stopLoading();
        return;
      }

      // Register user in the Firebase Authentication & save user data in the Firebase
      await wooAuthenticationRepository.resetPasswordWithEmail(email);

      FBAnalytics.logLogin('forgot_password');

      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Reset password email send');
      Get.to(() => ResetPasswordScreen(email: email));
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }
}




