import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../features/authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../../../features/authentication/screens/phone_otp_login/mobile_login_screen.dart';
import '../../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../../utils/exceptions/format_exceptions.dart';


class FirebaseAuthRepository extends GetxController {
  static FirebaseAuthRepository get instance => Get.find();

  //variable
  final _auth = FirebaseAuth.instance;
  var verificationId = ''.obs;
  final authenticationController = Get.put(AuthenticationController());

  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          authenticationController.isUserLogin.value = true;
        },
        codeSent: (verificationId, resendToken) {
          this.verificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          this.verificationId.value = verificationId;
        },
        verificationFailed: (e) {
          if (e.code == 'invalid-phone-number') {
            AppMassages.errorSnackBar(title: 'Oh Snap!', message: 'The provided phone number is not valid');
            // throw 'The provided phone number is not valid';
          } else {
            AppMassages.errorSnackBar(title: 'Oh Snap!', message: e.message ?? '');
            // throw 'Error - ${e.message}';
          }
          Get.off(() => const MobileLoginScreen());
        },

      );
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

  Future<UserCredential> verifyOTP(String otp) async {
    try {
      var credentials = PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: otp);
      var userCredential = await _auth.signInWithCredential(credentials);
      return userCredential;
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

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      //Obtain the auth details form the request
      final GoogleSignInAuthentication? googleAuth = await userAccount
          ?.authentication;

      //Create a new credential
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      //Once signed in, return the User Credential
      return await _auth.signInWithCredential(credentials);
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
      // rethrow;
      throw 'Something went wrong. Please try again';
    }
  }

  /// [Delete user] - Remove user auth and firebase account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
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