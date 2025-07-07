import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../services/notification/firebase_notification.dart';
import '../../../../utils/cache/cache.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../../utils/exceptions/format_exceptions.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../personalization/models/user_model.dart';
import '../../../personalization/controllers/change_profile_controller.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  RxBool isLoading = false.obs;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GetStorage localStorage = GetStorage();
  RxBool isUserLogin = false.obs;
  Rx<CustomerModel> customer = CustomerModel.empty().obs;
  final int loginExpiryInDays = 30;
  final hidePassword = true.obs; //Observable for hiding/showing password
  final imageUploading = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();

  final wooCustomersRepository = Get.put(WooCustomersRepository());

  @override
  void onInit() {
    super.onInit();
    _loadCustomer(); // Call async loader
  }

  Future<void> _loadCustomer() async {
    final String userId = await fetchLocalAuthToken();
    if (userId.isNotEmpty) {
      customer.value = CustomerModel(id: int.tryParse(userId));
    }
  }

  // Check if the user is logged in
  Future<void> checkIsUserLogin() async {
    final String localAuthUserToken = await fetchLocalAuthToken();
    isUserLogin.value = localAuthUserToken.isNotEmpty;
  }

  // Fetch user record
  Future<void> fetchCustomerData() async {
    try {
      final String localAuthUserToken = await fetchLocalAuthToken();
      if (localAuthUserToken.isNotEmpty) { // Check if token is valid
        final customerData = await wooCustomersRepository.fetchCustomerById(localAuthUserToken);
        customer(customerData);
      } else{
        throw 'customer not found';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<String> fetchLocalAuthToken() async {
    final String? authToken = await secureStorage.read(key: LocalStorage.authUserID);
    final String? expiryString = await secureStorage.read(key: LocalStorage.loginExpiry);

    // Check if both values exist
    if (authToken == null || authToken.isEmpty || expiryString == null || expiryString.isEmpty) {
      return '';
    }

    // Parse expiry date
    final DateTime expiry = DateTime.tryParse(expiryString) ?? DateTime.fromMillisecondsSinceEpoch(0);

    // Check if current time is before expiry
    if (DateTime.now().isBefore(expiry)) {
      return authToken;
    } else {
      // Expired – clean up stored data
      await deleteLocalAuthToken();
      return '';
    }
  }


  Future<void> saveLocalAuthToken(String token) async {
    // Store user ID and login expiry
    final String expiry = DateTime.now().add(Duration(days: loginExpiryInDays)).toIso8601String();
    await secureStorage.write(key: LocalStorage.authUserID, value: token);
    await secureStorage.write(key: LocalStorage.loginExpiry, value: expiry);
  }

  Future<void> deleteLocalAuthToken() async {
    await secureStorage.delete(key: LocalStorage.authUserID);
    await secureStorage.delete(key: LocalStorage.loginExpiry);
  }

  // Refresh Customer data
  Future<void> refreshCustomer() async {
    try {
      isLoading(true);
      customer(CustomerModel.empty());
      await fetchCustomerData();
    } catch (error) {
      // TLoaders.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // Re-Authenticate before deleting
  Future<void> wooDeleteAccount() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('Processing', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {FullScreenLoader.stopLoading(); return;}

      await wooCustomersRepository.deleteCustomerById(customer.value.id.toString());

      logout();
      //save to local storage
      localStorage.remove(LocalStorage.rememberMeEmail);
      localStorage.remove(LocalStorage.rememberMePassword);

      AppMassages.showToastMessage(message: 'Your Account Deleted successfully!');
      FullScreenLoader.stopLoading();
      NavigationHelper.navigateToLoginScreen(); //navigate to other screen
    } catch (error) {
      FullScreenLoader.stopLoading();
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    }
  }

  // this function run after successfully login
  Future<void> login({required CustomerModel user, required String loginMethod}) async {
    loginMethod == 'signup'
        ? FBAnalytics.logSignup(loginMethod)
        : FBAnalytics.logLogin(loginMethod);
    customer.value = user; //update user value
    isUserLogin.value = true; //make user login
    saveLocalAuthToken(user.id.toString());
    // update fcm token to user meta in wordpress
    final fCMToken = FirebaseNotification.fCMToken;
    if(fCMToken != user.fCMToken) {
      await Get.put(ChangeProfileController()).wooUpdateUserMeta(userId: user.id.toString(), key: CustomerMetaDataName.fCMToken, value: fCMToken);
    }
    CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.orderBox);
    CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.customerBox);
    CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.productReviewBox);
    CacheHelper.clearCacheBox(cacheBoxName: CacheConstants.settingsBox);
    AppMassages.showToastMessage(message: 'Login successfully!'); //show massage for successful login
    NavigationHelper.navigateToBottomNavigation(); //navigate to other screen
  }

  //this function for logout
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await AuthenticationController.instance.deleteLocalAuthToken();
      isUserLogin.value = false;
      customer.value = CustomerModel.empty();
      deleteLocalAuthToken();
      NavigationHelper.navigateToLoginScreen();
    }
    on FirebaseAuthException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    } on FirebaseException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    }
    catch (error) {
      throw 'Something went wrong. Please try again';
    }
  }

}