import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPermissions {

  static Future<bool> checkPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.request();
    return permissionStatus.isGranted;
  }

  static void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Permission to access photos is required to perform this action."),
        actions: <Widget>[
          TextButton(
            child: const Text("Open Settings"),
            onPressed: () {
              openAppSettings(); // Opens app settings so the user can grant the permission
            },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  static Future<bool> permissionsForSMS() async {
    PermissionStatus permissionStatus = await Permission.sms.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForMediaImages() async {
    PermissionStatus permissionStatus = await Permission.mediaLibrary.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForMediaVideos() async {
    PermissionStatus permissionStatus = await Permission.mediaLibrary.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForFullScreenIntent() async {
    PermissionStatus permissionStatus = await Permission.notification.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> openAccessibilitySettings() async {
    const url = 'package:flutter_settings_screens/flutter_settings_screens.dart';
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
      return true; // Successfully opened accessibility settings
    } else {
      return false; // Failed to open accessibility settings
    }
  }
}
