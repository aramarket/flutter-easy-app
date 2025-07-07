import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/change_profile_controller.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';

class UpdateMobileNo extends StatelessWidget {
  const UpdateMobileNo({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('update_profile_screen');

    final changeProfileController = Get.put(ChangeProfileController());
    final userController = Get.put(AuthenticationController());
    userController.refreshCustomer();
    bool isShowPhoneField = true;

    return Obx(() {
      if (!userController.isUserLogin.value || userController.isLoading.value) {
        return const SizedBox.shrink();
      }
      final phone = userController.customer.value.phone;
      if ((Validator.validatePhoneNumber(phone) != null) && isShowPhoneField) {
        changeProfileController.isPhoneVerified(false);
      }
      if (changeProfileController.isPhoneVerified.value) {
        return const SizedBox.shrink();
      }
      changeProfileController.updatePhone.text = phone;
      return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark),
                  bottom: BorderSide(color: AppColors.borderDark),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                //Ensure the Column takes minimum vertical space
                children: [
                  phone == ''
                      ? Text('Please update your phone number.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold))
                      : Text('Please provide a valid phone number', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Form(
                          key: changeProfileController.updatePhoneFormKey,
                          autovalidateMode: AutovalidateMode.always,
                          // Enable automatic validation
                          child: TextFormField(
                            controller: changeProfileController.updatePhone,
                            validator: (value) => Validator.validatePhoneNumber(value),
                            decoration: InputDecoration(
                              hintText: 'Example: 99XXXXXXXX',
                              border: const OutlineInputBorder(),
                              hintStyle: Theme.of(context).textTheme.labelLarge,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Obx(() => TextButton(
                                  onPressed: () => changeProfileController.wooUpdatePhoneNo(),
                                  child: changeProfileController.isPhoneUpdating.value
                                      ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: AppColors.linkColor))
                                      : const Text('Update', style: TextStyle(color: Colors.blueAccent)),
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(width: TSizes.sm),
                      IconButton(onPressed: () {
                        isShowPhoneField = false;
                        changeProfileController.isPhoneVerified(true);
                      },
                          icon: const Icon(Icons.close, color: Colors.red))
                    ],
                  ),
                ],
              )
          );

    });
  }
}

