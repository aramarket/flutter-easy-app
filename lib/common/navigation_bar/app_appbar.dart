import 'package:aramarket/utils/helpers/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/authentication/controllers/Authentication_controller/authentication_controller.dart';
import '../../features/settings/app_settings.dart';
import '../../features/settings/screen/setting_screen.dart';
import '../../features/shop/screens/search/search.dart';
import '../../services/share/share.dart';
import '../../utils/constants/icons.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/device/device_utility.dart';
import '../widgets/product/cart/cart_counter_icon.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget{
  const AppAppBar({
    super.key,
    this.title = '',
    this.isShowLogo = false,
    this.showBackArrow = false,
    this.showCartIcon = false,
    this.showSearchIcon = false,
    this.seeLogoutButton = false,
    this.seeSettingButton = false,
    this.sharePageLink = "",
    this.widgetInActions, // If null, search icon won't be shown
    this.bottom, // If null, search icon won't be shown
    this.toolbarHeight, // If null, search icon won't be shown
  });

  final String title;
  final bool showBackArrow;
  final bool isShowLogo;
  final bool showCartIcon;
  final bool showSearchIcon;
  final bool seeLogoutButton;
  final bool seeSettingButton;
  final String sharePageLink;
  final Widget? widgetInActions; // Nullable search type
  final PreferredSizeWidget? bottom; // Nullable search type
  final double? toolbarHeight; // Nullable search type

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      title: isShowLogo
          ? Image(image: AssetImage(isDark ? AppSettings.darkAppLogo : AppSettings.lightAppLogo), height: 34)
          : Text(title),
      actions: [
            showSearchIcon ? IconButton( icon: Icon(AppIcons.search), onPressed: () => showSearch(context: context, delegate: TSearchDelegate())) : const SizedBox.shrink(),
            sharePageLink.isNotEmpty
                ? IconButton(
                    icon: Icon(AppIcons.share),
                    onPressed: () => AppShare.shareUrl(
                        url: sharePageLink,
                        contentType: 'Category',
                        itemName: title,
                        itemId:  ''
                    ),
                  )
                : const SizedBox.shrink(),
            if(showCartIcon)
              TCartCounterIcon(),
            if(seeLogoutButton) ...[
                Obx(() => AuthenticationController.instance.isUserLogin.value
                    ? InkWell(
                          onTap: () => AuthenticationController.instance.logout(),
                          child: Row(
                            children: [
                              Text('Logout'),
                              const SizedBox(width: AppSizes.sm),
                              Icon(AppIcons.logout, size: 20,),
                              const SizedBox(width: AppSizes.sm),
                            ],
                          )
                      )
                    : InkWell(
                          onTap: () => NavigationHelper.navigateToLoginScreen(),
                          child: Row(
                            children: [
                              Icon(Iconsax.user),
                              const SizedBox(width: AppSizes.sm),
                              Text('Login', style: TextStyle(fontSize: 15),),
                              const SizedBox(width: AppSizes.md),
                            ],
                          )
                      )
                ),
              ],
            seeSettingButton ? IconButton( icon: Icon(Icons.settings), onPressed: () => Get.to(() => SettingScreen())) : const SizedBox.shrink(),
            widgetInActions != null
                ? widgetInActions!
                : SizedBox.shrink()
      ],
      leading: showBackArrow ? IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Iconsax.arrow_left)) :  null,
      bottom: bottom,
      // toolbarHeight: toolbarHeight,
    );
  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight() + (toolbarHeight ?? 0));
}