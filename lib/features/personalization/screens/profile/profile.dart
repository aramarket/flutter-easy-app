import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/dialog_box/dialog_massage.dart';
import '../../../../common/navigation_bar/appbar2.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/shimmers/shimmer_effect.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';
import '../change_profile/change_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Scaffold(
      appBar: const TAppBar2(titleText: 'Profile Setting', showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          ///- user image
          child: Column(
            children: [
              const SizedBox(height: TSizes.spaceBtwSection),
              Stack(
                children: [
                  SizedBox(
                    width: 100, height: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Obx((){
                          final networkImage = controller.customer.value.avatarUrl;
                          final image = networkImage != null && networkImage.isNotEmpty ? networkImage : TImages.tProfileImage; // Checking null safety
                          if (controller.imageUploading.value) {
                            return const TShimmerEffect(width: 55, height: 55);
                          } else {
                            if (networkImage != null && networkImage.isNotEmpty) { // Checking null safety
                              return CachedNetworkImage(
                                // fit: BoxFit.cover,
                                // color: Colors.grey,
                                imageUrl: image,
                                progressIndicatorBuilder: (context, url, downloadProgress) => const TShimmerEffect(width: 55, height: 55),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              );
                            } else {
                              return Image(image: AssetImage(image)); // Using safe null access
                            }
                          }
                        })
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                          borderRadius : BorderRadius.circular(100),
                          color: Colors.yellow// tAccentColor.withOpacity(0.1)
                      ),
                      child: IconButton(
                        onPressed: () => controller.uploadProfilePicture(context),
                        icon: const Icon(Iconsax.edit_2, size: 16, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSection),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(title: 'Profile Information', seeActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() {
                if(controller.isLoading.value){
                  return const Center(child: CircularProgressIndicator(color: TColors.linkColor),);
                } else {
                  return Column(
                    children: [
                      TProfileMenu(
                          title: 'Name',
                          value: controller.customer.value.name,
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeProfile()));}
                      ),
                      Divider(color: Colors.grey[200]),
                      TProfileMenu(
                          title: 'Email',
                          value: controller.customer.value.email ?? "Email",
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeProfile()));}),
                      Divider(color: Colors.grey[200]),
                      TProfileMenu(
                          title: 'Phone',
                          value: controller.customer.value.phone,
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeProfile()));}),
                      const Divider(),
                      Center(
                        child: TextButton(
                            child: const Text('Delete Account', style: TextStyle(color: Colors.red),),
                            onPressed: () => DialogMessage().showDialog(
                              title: 'Delete Account',
                              message: 'Are you sure you want to delete your account permanently? This Action is not reversible and all of your data will be removed permanently',
                              toastMassage: 'Your Account Deleted successfully!',
                              function: () async {
                                await controller.wooDeleteAccount();
                              },
                            ),
                        )
                      )
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key, required this.title, required this.value, required this.onTap, this.icon = Iconsax.arrow_right_34,
  });
  final String title, value;
  final void Function() onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.spaceBtwItems),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            Expanded(flex: 5, child: Text(value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            Expanded(child: Icon(icon, size: 18,)),
          ],
        ),
      ),
    );
  }
}
