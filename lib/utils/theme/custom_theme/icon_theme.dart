import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppIconTheme {
  AppIconTheme._(); // Private constructor to prevent instantiation

  static final lightIconTheme = IconThemeData(
    color: AppColors.iconLight, // Matches light theme text color
    size: 20, // Default size, adjust if needed
  );

  static final darkIconTheme = IconThemeData(
    color: AppColors.iconDark, // Matches dark theme text color
    size: 20, // Consistent icon size
  );
}
