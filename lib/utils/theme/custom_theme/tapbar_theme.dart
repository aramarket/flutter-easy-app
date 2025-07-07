import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppTabBarTheme {
  AppTabBarTheme._(); // Private constructor to prevent instantiation

  static const lightTabBarTheme = TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.label,
    labelColor: AppColors.labelColorLight, // Active tab text color
    unselectedLabelColor: AppColors.unselectedLabelColorLight, // Inactive tab text color
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 2.0, color: AppColors.underlineTabIndicatorLight), // Active tab underline
    ),
  );

  static const darkTabBarTheme = TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.label,
    labelColor: AppColors.labelColorDark,
    unselectedLabelColor: AppColors.unselectedLabelColorDark,
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 2.0, color: AppColors.underlineTabIndicatorDark),
    ),
  );
}
