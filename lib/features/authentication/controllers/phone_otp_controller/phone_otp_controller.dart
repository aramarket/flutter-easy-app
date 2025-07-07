import 'dart:math';

import 'package:aramarket/features/settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/whatsapp_api/authentication/whatsapp_auth_repo.dart';
import '../../../../data/repositories/woocommerce_repositories/customers/woo_customer_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../utils/validators/validation.dart';
import '../Authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../screens/create_account/signup.dart';
import '../../screens/phone_otp_login/enter_otp_screen.dart';
import '../create_account_controller/signup_controller.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  Rx<bool> isLoading = false.obs;
  Rx<bool> isPhoneVerified = false.obs;
  Rx<String> countryCode = ''.obs;
  Rx<String> phoneNumber = ''.obs;

  final otp = TextEditingController();

  // Otp variables
  int otpLength = AppSettings.otpLength;
  String _generatedOtp = '';
  DateTime? _otpExpiry;
  int expiryTime = 10; // minutes

  // A map to store phone number and their request timestamps
  final Map<String, List<DateTime>> _otpRequestTimestamps = {};
  // Limit settings
  static const int maxRequests = 3;
  static const Duration limitDuration = Duration(minutes: 5);

  // Otp attempt protection
  final Map<String, List<DateTime>> _otpVerificationAttempts = {};
  static const int maxVerificationAttempts = 5;
  static const Duration attemptWindow = Duration(minutes: 10);

  final wooCustomersRepository = Get.put(WooCustomersRepository());
  final userController = Get.put(AuthenticationController());


  @override
  void onClose() {
    super.onClose();
    otp.dispose();
    // SmsAutoFill().unregisterListener();
  }

  // void initSmsAutoFill() async {
  //   // Request permission if not granted
  //   final permissionStatus = await RequestPermissions.checkPermission(Permission.sms);
  //   if (permissionStatus) {
  //     // Get app signature
  //     final signature = await SmsAutoFill().getAppSignature;
  //     // Start listening for SMS code
  //     SmsAutoFill().listenForCode;
  //   } else {
  //     // Handle permission denied
  //     Get.snackbar('Permission Denied', 'SMS permission is required');
  //     // RequestPermissions.showPermissionDialog(context);
  //   }
  // }

  // Send OTP through WhatsApp API
  Future<void> whatsappSendOtp({required String phone}) async {
    try {
      isLoading(true);

      // Check internet connectivity
      final isConnected = await Get.put(NetworkManager()).isConnected();
      if (!isConnected) {
        AppMassages.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Format and validate phone
      String fullPhoneNumber = Validator.formatPhoneNumberForWhatsAppOTP(countryCode: countryCode.value, phoneNumber: phone);

      // Rate limiting logic
      final now = DateTime.now();
      final timestamps = _otpRequestTimestamps[fullPhoneNumber] ?? [];

      // Remove timestamps older than limit duration
      final recentTimestamps = timestamps.where((t) => now.difference(t) < limitDuration).toList();

      if (recentTimestamps.length >= maxRequests) {
        AppMassages.errorSnackBar(
          title: 'Too Many Requests',
          message: 'You can only request OTP $maxRequests times every ${limitDuration.inMinutes} minutes.',
        );
        return;
      }

      // Store the new timestamp
      recentTimestamps.add(now);
      _otpRequestTimestamps[fullPhoneNumber] = recentTimestamps;

      // Generate and send OTP
      _generateAndStoreOtp();
      await WhatsappApi.sendOtp(phoneNumber: fullPhoneNumber, otp: _generatedOtp);

      // Navigate to OTP screen
      Get.to(() => const EnterOTPScreen());

    } catch (error) {
      AppMassages.errorSnackBar(title: 'Oh Snap!', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> verifyOtp(String otp) async {
    String phone = ''; // Initialize with an empty string
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('Logging you in...', Images.docerAnimation);

      final isConnected = await Get.put(NetworkManager()).isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      phone = phoneNumber.value;
      String? formattedPhone = Validator.getFormattedTenDigitNumber(phone);
      if (formattedPhone == null) {
        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(title: 'Error', message: 'No 10-digit number found');
        return;
      }

      // Check brute-force protection
      final now = DateTime.now();
      final attempts = _otpVerificationAttempts[formattedPhone] ?? [];

      // Keep only recent attempts within the time window
      final recentAttempts = attempts.where((t) => now.difference(t) < attemptWindow).toList();

      if (recentAttempts.length >= maxVerificationAttempts) {
        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(
          title: 'Too Many Attempts',
          message: 'Too many incorrect attempts. Try again later.',
        );
        return;
      }

      // Verify OTP
      if (!_isOtpValid(otp)) {
        recentAttempts.add(now); // Log failed attempt
        _otpVerificationAttempts[formattedPhone] = recentAttempts;

        FullScreenLoader.stopLoading();
        AppMassages.errorSnackBar(title: 'Error', message: 'Invalid OTP');
        return;
      }

      // OTP is valid — clear attempts
      _otpVerificationAttempts.remove(formattedPhone);

      final userId = await wooCustomersRepository.fetchCustomerByPhone(formattedPhone);
      final CustomerModel customer = await wooCustomersRepository.fetchCustomerById(userId);

      isPhoneVerified.value = true;
      FullScreenLoader.stopLoading();
      userController.login(user: customer, loginMethod: 'PhoneOTP');
    } catch (error) {
      FullScreenLoader.stopLoading();
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      if (error.toString().contains('Customer not found')) {
        Get.put(SignupController()).phone.text = Validator.getFormattedTenDigitNumber(phone) ?? '';
        Get.to(() => SignUpScreen());
      } else {
        AppMassages.errorSnackBar(title: 'Error', message: error.toString());
      }
    }
  }

  void _generateAndStoreOtp() {
    _generatedOtp = _generateOtp(length: otpLength);
    _otpExpiry = DateTime.now().add(Duration(minutes: expiryTime));
  }

  bool _isOtpValid(String inputOtp) {
    if (_generatedOtp.isEmpty || _otpExpiry == null) return false;
    if (DateTime.now().isAfter(_otpExpiry!)) return false;

    return inputOtp == _generatedOtp;
  }

  String _generateOtp({int length = 4}) {
    final random = Random();
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString(); // Adds a digit from 0 to 9
    }
    return otp;
  }
}