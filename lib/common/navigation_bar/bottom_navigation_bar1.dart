import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/personalization/screens/user_menu/user_menu_screen.dart';
import '../../features/shop/controllers/cart_controller/cart_controller.dart';
import '../../features/shop/screens/cart/cart.dart';
import '../../features/shop/screens/category/all_category_screen.dart';
import '../../features/shop/screens/home/home.dart';
import '../../features/shop/screens/discover/discover_screen.dart';
import '../../routes/external_routes.dart';
import '../../routes/internal_routes.dart';
import '../../routes/routes.dart';
import '../../utils/constants/icons.dart';
import '../dialog_box_massages/snack_bar_massages.dart';


class BottomNavigation1 extends StatefulWidget {
  const BottomNavigation1({super.key, this.route});

  final String? route;

  @override
  State<BottomNavigation1> createState() => _BottomNavigation1State();
}

class _BottomNavigation1State extends State<BottomNavigation1> {
  final cartController = Get.put(CartController());

  int _currentIndex = 0;
  DateTime? _lastBackPressedTime; // Variable to track the time of the last back button press
  final screens = [
    const MyHomePage(),
    const DiscoverScreen(),
    const CartScreen(),
    const CategoryScreen(),
    const UserMenuScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Execute after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.route != null) {
        final route = AppRouter.handleRoute(route: widget.route ?? '/');
        if(route != null) Navigator.push(context, route);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    // FBAnalytics.logPageView('bottom_navigation_bar1_screen');
    return PopScope(
      canPop: false, // This property disables the system-level back navigation
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if(_currentIndex != 0){
          setState(() => _currentIndex = 0);
        } else {
          // Check if _lastBackPressedTime is not null and the difference between the current time
          // and the last back pressed time is less than 2 seconds
          if (_lastBackPressedTime != null &&
              DateTime.now().difference(_lastBackPressedTime!) <= const Duration(seconds: 2)) {
            // If the conditions are met, exit the app
            SystemNavigator.pop();
          } else {
            // If not, show a toast message and update _lastBackPressedTime
            AppMassages.showToastMessage(message: "Press Back Again To Exit");
            _lastBackPressedTime = DateTime.now();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // Disables ripple effect
            highlightColor: Colors.transparent, // Removes highlight on tap
            hoverColor: Colors.transparent, // Ensures no hover effect
            cardColor: Colors.transparent,
          ),
          child: Container(
            // height: 60, // Adjust height as needed
            // padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline, // Change color as needed
                  width: 0.2, // Adjust thickness
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              iconSize: 25,
              fixedColor: Theme.of(context).colorScheme.onSurface,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              // backgroundColor: Theme.of(context).colorScheme.surface,
              // selectedFontSize: 12,
              // unselectedFontSize: 12,
              // selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              // unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              // selectedFontSize: 10,
              // unselectedFontSize: 20,
              items: [
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home), // Icon when selected
                ),
                BottomNavigationBarItem(
                  label: 'Search',
                  icon: Icon(AppIcons.search),
                  activeIcon: Icon(AppIcons.search), // Icon when selected
                ),
                BottomNavigationBarItem(
                  label: 'Cart',
                  icon: Obx(() => Stack(
                    clipBehavior: Clip.none, // Ensures the red dot is not clipped
                    alignment: Alignment.bottomCenter,
                    children: [
                      Icon(AppIcons.bottomNavigationCart, size: 25),
                      if (cartController.noOfCartItems.value > 0)
                        Positioned(
                            bottom: -7, // Adjust this value as needed
                            child: Icon(Icons.circle, size: 5, color: Colors.red,),
                        )
                    ],
                  )),
                  activeIcon: Icon(AppIcons.bottomNavigationCart), // Icon when selected
                ),
                BottomNavigationBarItem(
                  label: 'Category',
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category), // Icon when selected
                ),
                BottomNavigationBarItem(
                  label: 'Account',
                  icon: Icon(AppIcons.user),
                  activeIcon: Icon(AppIcons.user),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
