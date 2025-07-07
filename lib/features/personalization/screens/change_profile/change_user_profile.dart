import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/change_profile_controller.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';


class ChangeUserProfile extends StatelessWidget {
  const ChangeUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('change_user_profile_screen');

    final changeProfileController = Get.put(ChangeProfileController());
    final userController = Get.put(AuthenticationController());
    changeProfileController.firstName.text = userController.customer.value.firstName ?? '';
    changeProfileController.lastName.text = userController.customer.value.lastName ?? '';
    changeProfileController.email.text = userController.customer.value.email ?? '';
    changeProfileController.phone.text = Validator.getFormattedTenDigitNumber(userController.customer.value.phone) ?? '';

    return Scaffold(
      appBar: const AppAppBar(title: "Update Profile", showBackArrow: true),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => userController.refreshCustomer(),
        child: SingleChildScrollView(
          child: Padding(
            padding: TSpacingStyle.paddingWidthAppbarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                    key: changeProfileController.changeProfileFormKey,
                    child: Column(
                        children: [
                          const SizedBox(height: AppSizes.spaceBtwSection),
                          //Name
                          Row(
                            children: [
                              Expanded(
                                  child: TextFormField(
                                    controller: changeProfileController.firstName,
                                    validator: (value) => Validator.validateEmptyText('First Name', value),
                                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'First Name*'),
                                  )
                              ),
                              const SizedBox(width: AppSizes.inputFieldSpace),
                              //Pincode
                              Expanded(
                                  child: TextFormField(
                                      controller: changeProfileController.lastName,
                                      decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user4), labelText: 'Last name')
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.inputFieldSpace),
                          //email
                          TextFormField(
                              controller: changeProfileController.email,
                              validator: (value) => Validator.validateEmail(value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.direct_right),
                                labelText: AppTexts.tEmail,
                              )
                          ),
                          const SizedBox(height: AppSizes.inputFieldSpace),
                          // phone
                          TextFormField(
                              controller: changeProfileController.phone,
                              validator: (value) => Validator.validatePhoneNumber(value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.call),
                                labelText: AppTexts.tPhone,
                              )
                          ),
                          const SizedBox(height: AppSizes.spaceBtwSection),
                          // save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text('Update'),
                              onPressed: () => changeProfileController.wooChangeProfileDetails(),
                            ),
                          ),
                        ]
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

