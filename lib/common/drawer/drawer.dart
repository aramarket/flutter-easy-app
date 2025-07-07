import 'package:flutter/material.dart';

import '../../features/personalization/screens/user_menu/user_menu_screen.dart';
import '../../services/firebase_analytics/firebase_analytics.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('drawer_menu_screen');

    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: UserMenuScreen(),
    );
  }
}
