import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/constants/sizes.dart';

/// a widgets for displaying on animated loading indicator with optional text and action button
class AnimationLoaderWidgets extends StatelessWidget {
  /// default constructor for the TAnimationLoaderWidgets
  ///
  /// Parameters:
  /// - text: the text to be displayed below the animation.
  ///  - animation: the path to the lottie animation file.
  ///  - showAction: the text to be displayed an the action button.
  ///  - onActionPressed: Callback function to be executed when the action button pressed
  const AnimationLoaderWidgets({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPress
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final void Function()? onActionPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(animation, width: MediaQuery.of(context).size.width * 0.8), //display lottie animation
            const SizedBox(height: AppSizes.lg),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.defaultSpace,),
            showAction
                ? SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: onActionPress,
                      child: Text(
                        actionText!,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
