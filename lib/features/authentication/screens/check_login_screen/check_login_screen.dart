import 'package:flutter/material.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/navigation_helper.dart';


class CheckLoginScreen extends StatelessWidget {
  const CheckLoginScreen({
    super.key, this.text = 'Please Login! to access this page', this.animation = Images.pencilAnimation,
  });
  final String text;
  final String animation;

  @override
  Widget build(BuildContext context) {
    return AnimationLoaderWidgets(
      text: text,
      animation: animation,
      showAction: true,
      actionText: 'Login',
      onActionPress: () => NavigationHelper.navigateToLoginScreen(),
    );
  }
}