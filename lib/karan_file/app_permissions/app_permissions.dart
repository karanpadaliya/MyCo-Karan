import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../themes_colors/colors.dart';

enum AppPermission {
  camera,
  storage,
  photos,
  mediaLibrary,
  microphone,
  location,
  notification,
  manageExternalStorage,
}

class PermissionUtil {
  /// Request a single permission
  static Future<bool> requestPermission(AppPermission permission) async {
    final status = await _getPermission(permission).request();
    return status.isGranted;
  }

  /// Check if a single permission is granted
  static Future<bool> isPermissionGranted(AppPermission permission) async {
    final status = await _getPermission(permission).status;
    return status.isGranted;
  }

  /// Request multiple permissions
  static Future<Map<AppPermission, bool>> requestMultiplePermissions(
    List<AppPermission> permissions,
  ) async {
    Map<AppPermission, bool> results = {};

    for (AppPermission permission in permissions) {
      final status = await _getPermission(permission).request();
      results[permission] = status.isGranted;
    }

    return results;
  }

  /// Open app settings
  static Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }

  /// Show dialog when permission is denied
  static void showPermissionDeniedDialog(
    BuildContext context, {
    String message = 'Permission denied to access media.',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.GPSMediumColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Permission Needed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.subTitleColor,
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(fontSize: 16, color: AppColors.titleColor),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.borderColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettingsPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.settings, size: 20),
                label: const Text(
                  'Open Settings',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
    );
  }

  /// Map enum to real platform permission
  static Permission _getPermission(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.storage:
        return Platform.isIOS ? Permission.photos : Permission.storage;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.mediaLibrary:
        return Permission.mediaLibrary;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.location:
        return Permission.location;
      case AppPermission.notification:
        return Permission.notification;
      case AppPermission.manageExternalStorage:
        return Permission.manageExternalStorage;
      default:
        return Permission.unknown;
    }
  }

  /// Optional helper to check permission based on picker type
  static Future<bool> checkPermissionByPickerType(
    String type,
    BuildContext context,
  ) async {
    bool granted = false;

    if (type == 'camera') {
      granted = await PermissionUtil.requestPermission(AppPermission.camera);
    } else if (type == 'gallery') {
      granted = await PermissionUtil.requestPermission(AppPermission.storage);
    } else if (type == 'document') {
      if (Platform.isAndroid) {
        granted = await PermissionUtil.requestPermission(
          AppPermission.manageExternalStorage,
        );
      } else {
        granted = true;
      }
    }

    if (!granted && context.mounted) {
      PermissionUtil.showPermissionDeniedDialog(context);
    }

    return granted;
  }
}
