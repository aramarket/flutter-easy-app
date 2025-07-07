import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../models/address_model.dart';
import 'update_user_address.dart';
import 'address_widgets/single_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

@override
Widget build(BuildContext context) {
  FBAnalytics.logPageView('user_address_screen');

  final userController = Get.put(AuthenticationController());

  return Scaffold(
    appBar: const AppAppBar(title: "Address", showBackArrow: true, showCartIcon: true),
    body: !userController.isUserLogin.value
      ? const CheckLoginScreen()
      : Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Heading(title: 'Billing Address'),
              TSingleAddress(
                  address: userController.customer.value.billing ?? AddressModel.empty(),
                  onTap: () => Get.to(() => UpdateAddressScreen(
                      title: 'Update Billing Address',
                      address: userController.customer.value.billing ?? AddressModel.empty()
                    )),
                // onTap: () => controller.selectAddress(addresses[index])
              ),
              // const SizedBox(height: TSizes.spaceBtwInputFields),
              // const TSectionHeading(title: 'Shipping Address'),
              // TSingleAddress(
              //     address: userController.customer.value.shipping ?? AddressModel.empty(),
              //     onTap: () => Get.to(() => UpdateAddressScreen(
              //         title: 'Update Shipping Address',
              //         isShippingAddress: true,
              //         address: userController.customer.value.shipping ?? AddressModel.empty(),
              //     )),
              //     hidePhone: true
              //   // onTap: () => controller.selectAddress(addresses[index])
              // )
            ],
          ),
        ),
      ),
    );
  }
}

