
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/firebase/authentication/firebase_auth_repository.dart';
import '../../../../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../Authentication_controller/authentication_controller.dart';
import '../../screens/create_account/signup.dart';
import '../create_account_controller/signup_controller.dart';
import '../login_controller/login_controller.dart';

class SocialLoginController extends GetxController{
  static SocialLoginController get instance => Get.find();

  final firebaseAuthRepository = Get.put(FirebaseAuthRepository());
  final wooCustomersRepository = Get.put(WooCustomersRepository());
  final authenticationController = Get.put(AuthenticationController());
  final loginController = Get.put(LoginController());

  //Google SignIn Authentication
  Future<void> signInWithGoogle() async {
    String googleEmail = ''; // Initialize with an empty string
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('Logging you in...', Images.docerAnimation);
      final isConnected = await Get.put(NetworkManager()).isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Google Authentication
      final userCredentials = await firebaseAuthRepository.signInWithGoogle();
      googleEmail = userCredentials.user?.email ?? ''; // Assign the value here
      final customer = await wooCustomersRepository.fetchCustomerByEmail(googleEmail);

      FullScreenLoader.stopLoading();
      authenticationController.login(user: customer, loginMethod: 'Google');
    } catch (error) {
      // Remove Loader
      FullScreenLoader.stopLoading();
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      if (error.toString().contains('Customer not found')) {
        Get.put(SignupController()).email.text = googleEmail; // Now 'googleEmail' is accessible here
        Get.to(() => SignUpScreen());
      } else {
        AppMassages.errorSnackBar(title: 'Error', message: error.toString());
      }
    }
  }
}

