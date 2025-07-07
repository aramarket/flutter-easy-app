import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../common/styles/spacing_style.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/icons.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/phone_otp_controller/phone_otp_controller.dart';
import '../email_login/email_login.dart';
import '../create_account/signup.dart';
import '../social_login/social_buttons.dart';

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('mobile_login_screen');
    final otpController = Get.put(OTPController());
    final bool isWhatsappOtpLogin = true;
    return Scaffold(
      // appBar: const TAppBar2(titleText: "Login", showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWidthAppbarHeight,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: TextButton(
                  onPressed: () => NavigationHelper.navigateToBottomNavigation(),
                  child: Text('Skip', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 120,),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //login, Title, Subtitle
                    Column(
                      children: [
                        Text('Your Phone!', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: AppSizes.sm),
                        Text(AppTexts.loginSubTitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSection),

                    // Form Field
                    // PhoneFieldHint/TextField,
                    // PhoneFieldHint(),
                    // Phone number field with auto-fill
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      validator: (value) => Validator.validatePhoneNumber(value.toString()),
                      languageCode: "en",
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        otpController.countryCode.value = phone.countryCode; // +91
                        otpController.phoneNumber.value = phone.number;  // 82xxxxxxx92
                      },
                      onCountryChanged: (country) {
                        otpController.countryCode.value = country.dialCode.toString();
                        // otpController.selectedCountry1.value = country.dialCode.toString();
                      },
                    ),
                    const SizedBox(height: AppSizes.inputFieldSpace),

                    if(isWhatsappOtpLogin)
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => OutlinedButton(
                            onPressed: () => otpController.whatsappSendOtp(phone: otpController.phoneNumber.value),
                            child: otpController.isLoading.value
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.whatsAppColor, strokeWidth: 2,))
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: AppSizes.sm,
                                  children: [
                                    Icon(AppIcons.whatsapp, size: 20, color: AppColors.whatsAppColor,),
                                    Text('Get Whatsapp OTP'),
                                  ],
                                )
                        ),
                        ),
                      ),

                    //Not a Member?  Divider
                    const SizedBox(height: AppSizes.spaceBtwSection),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[700],
                          )),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(AppTexts.orContinueWith.capitalize!, style: Theme.of(context).textTheme.labelMedium),
                          ),
                          Expanded(child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[700],
                          )),
                        ],
                      ),
                    ),

                    //Social login
                    const SizedBox(height: AppSizes.inputFieldSpace),
                    const TSocialButtons(),

                    // Continue with email and password
                    const SizedBox(height: AppSizes.inputFieldSpace),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          onPressed: () => Get.to(() => const EmailLoginScreen()),
                          child: const Text('Login with Email and Password')
                      ),
                    ),

                    // Not a Member? register
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Not a member?', style: Theme.of(context).textTheme.labelLarge),
                          TextButton(
                              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));},
                              child: Text(AppTexts.createAccount, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.linkColor )))
                        ]
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
