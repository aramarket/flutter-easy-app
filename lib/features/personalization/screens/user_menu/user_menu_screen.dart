import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/app_appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../common/widgets/shimmers/user_shimmer.dart';
import '../../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../settings/app_settings.dart';
import '../../../authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../user_profile/user_profile.dart';
import 'widgets/contact_widget.dart';
import 'widgets/account_menu.dart';
import 'widgets/other_menu.dart';
import 'widgets/policy_widget.dart';

class UserMenuScreen extends StatelessWidget {
  const UserMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('user_menu_screen');

    final userController = Get.put(AuthenticationController());
    userController.refreshCustomer();

    return  Scaffold(
        appBar: const AppAppBar(title: 'Menu', seeLogoutButton: true, seeSettingButton: true),
        body: RefreshIndicator(
                color: AppColors.refreshIndicator,
                onRefresh: () async => userController.refreshCustomer(),
                child: ListView(
                  padding: TSpacingStyle.defaultPageVertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // Your profile
                    Obx(() {
                     if(userController.isUserLogin.value) {
                       return Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           // User profile
                           Heading(title: 'Your Profile', paddingLeft: AppSizes.defaultSpace),
                           CustomerProfileCard(userController: userController),
                         ],
                       );
                     } else {
                       return SizedBox.shrink();
                      }
                    }),

                    // Account
                    Heading(title: 'Account', paddingLeft: AppSizes.defaultSpace),
                    const AccountMenu(),

                    //Others
                    Heading(title: 'Others', paddingLeft: AppSizes.defaultSpace),
                    OtherMenu(),

                    // Contact
                    Heading(title: 'Support', paddingLeft: AppSizes.defaultSpace),
                    const SupportWidget(),

                    // Policy
                    Heading(title: 'Policy', paddingLeft: AppSizes.defaultSpace),
                    const PolicyWidget(),
                    const SizedBox(height: AppSizes.inputFieldSpace),

                    // Follow us
                    // Heading(title: 'Follow us', paddingLeft: AppSizes.defaultSpace),
                    // const FollowUs(),
                    // const SizedBox(height: AppSizes.spaceBtwInputFields),

                    // Version
                    Center(
                      child: Stack(
                        alignment: Alignment.topCenter, // Align text closer to the image
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.xs),
                            child: RoundedImage(
                                backgroundColor: Colors.transparent,
                                width: 120,
                                padding: 0,
                                image: Theme.of(context).brightness != Brightness.dark
                                    ? AppSettings.lightAppLogo
                                    : AppSettings.darkAppLogo,
                            ),
                          ),
                          Positioned(
                              bottom: 0, // Adjust this to bring text closer
                              child: Text('v${AppSettings.appVersion}', style: TextStyle(fontSize: 12))
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
            ),
      );
  }
}

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({
    super.key,
    required this.userController,
  });

  final AuthenticationController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if(userController.isLoading.value){
            return const UserTileShimmer();
          } else {
             return InkWell(
               onTap: () => Get.to(() => const UserProfileScreen()),
               child: ListTile(
                  leading: RoundedImage(
                     padding: 0,
                     height: 40,
                     width: 40,
                     borderRadius: 100,
                     isNetworkImage: userController.customer.value.avatarUrl != null ? true : false,
                     image: userController.customer.value.avatarUrl ?? Images.tProfileImage
                  ),
                  title: Text(userController.customer.value.name.isEmpty ? "User" : userController.customer.value.name,),
                  subtitle: Text(userController.customer.value.email?.isNotEmpty ?? false ? userController.customer.value.email! : '',),
                  trailing: Icon(Icons.arrow_forward_ios, size: 20,),
               ),
             );
          }
        }),
      ],
    );
  }
}






