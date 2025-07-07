import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';
class AppMassages  extends GetxController {
  static OverlayEntry? _overlayEntry;
  static bool _isToastVisible = false;
  static int massagesDuration = 1500;

  static void showSnackBar({required String massage, VoidCallback? onUndo}) {
    final snackBar = SnackBar(
      content: Text(massage),
      duration: Duration(milliseconds: massagesDuration),
      action: onUndo != null
          ? SnackBarAction(
        label: 'Undo',
        onPressed: onUndo,
        textColor: Colors.blue,
      )
          : null,
    );

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showToastMessage({required String message}) {
    if (_isToastVisible) return; // Prevent showing multiple toasts

    hideToastMessage(); // Remove any existing toast before showing a new one

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: Get.height * 0.1,
        left: 50,
        right: 50,
        child: IgnorePointer(
          ignoring: true,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.defaultRadius),
                color: Theme.of(context).colorScheme.surface,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.1), // Very light shadow
                //     blurRadius: 4, // Small blur radius for less depth
                //     spreadRadius: 1, // Minimal spread
                //     offset: const Offset(0, 2), // Slight downward shadow
                //   ),
                // ],
              ),
              child: Center(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Use Get.overlayContext! instead of Get.context!
    if (Get.overlayContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
        _isToastVisible = true;
      });

      // Automatically remove toast after 1.5 seconds
      Future.delayed(Duration(milliseconds: massagesDuration), hideToastMessage);
    }
  }

  static successSnackBar({String? title, String? message}) {

    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.only(top: 16), // Add margin
      content: AwesomeSnackbarContent(
        title: title ?? 'Oh Hey!!',
        message: message ?? 'Produces done successfully',
        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

  }

  static warningSnackBar({String? title, String? message}) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.only(top: 16), // Add margin
      content: AwesomeSnackbarContent(
        title: title ?? 'Warning!',
        message: message ?? 'Some warning message',
        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.warning,
      ),
    );

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static errorSnackBar({String? title, String? message}) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.only(top: 16), // Add margin
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? 'On Snap!',
        message: message ?? 'Something went wrong',
        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void hideToastMessage() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isToastVisible = false;
    }
  }
}