import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../common/navigation_bar/app_appbar.dart';
import '../../../common/styles/spacing_style.dart';
import '../../../services/firebase_analytics/firebase_analytics.dart';
import '../../../utils/cache/cache.dart';
import '../../../utils/theme/theme_controller.dart';
import '../controllers/settings_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FBAnalytics.logPageView('setting_screen');
    final settingsController = Get.put(SettingsController());
    final themeController = Get.put(ThemeController());
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const AppAppBar(title: "Settings", showSearchIcon: true, showCartIcon: true),
      body: Padding(
        padding: TSpacingStyle.defaultPageVertical,
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Notification'),
              subtitle: Text('Turn on and off notification'),
              value: true,
              onChanged: (value) {}
            ),
            ListTile(
              title: Text('Theme'),
              subtitle: Text('Choose light and dark theme'),
              trailing: Obx(() => DropdownButton<ThemeMode>(
                value: themeController.themeMode.value,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeController.toggleTheme(mode);
                  }
                },
                underline: SizedBox(), // This removes the underline
                dropdownColor: Theme.of(context).colorScheme.surface, // Changes background color of dropdown menu
                items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                    DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                  ],
                ),
              ),
              // trailing: TextButton(onPressed: () {}, child: Text('Select', style: TextStyle(color: Colors.blue),)),
            ),
            ListTile(
              title: Text('Clear cache'),
              subtitle: Text('Remove all store cache in local'),
              trailing: TextButton(onPressed: () => DialogHelper.showDialog(
                  title: 'Clear cache',
                  message: 'Are you sure! to clear all cache',
                  toastMessage: 'All cache clear successfully',
                  actionButtonText: 'Clear',
                  onSubmit: () => CacheHelper.clearAllCacheBox(),
                  context: context
              ) , child: Text('Clear', style: TextStyle(color: Colors.red),)),
            ),
          ],
        ),
      )
    );
  }
}
