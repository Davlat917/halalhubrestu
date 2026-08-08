import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/app_version/app_version_compare.dart';
import 'package:halalhub_restaurant/core/app_version/app_version_repository.dart';
import 'package:halalhub_restaurant/core/app_version/models/app_version_model.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/core/widgets/show_version_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Vendor shell ochilganda bir marta chaqiriladi (force/soft update).
class AppVersionGate {
  AppVersionGate._();

  static bool _checkedThisSession = false;

  static Future<void> checkOnce(BuildContext context) async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version.split('+').first.trim();
      final model = await getIt<AppVersionRepository>().fetchVendorAppVersion();
      final result = _evaluate(current, model);
      if (!result.shouldShowUpdate) return;
      if (!context.mounted) return;

      final isMobile = ResponsiveSection.isMobileLayout(context);
      if (isMobile) {
        await _showMobileSheet(context, result);
      } else {
        await _showTabletDialog(context, result);
      }
    } catch (_) {
      // Version check must never block the vendor shell.
    }
  }

  static Future<void> _showMobileSheet(
    BuildContext context,
    AppVersionCheckResult result,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: !result.isForceUpdate,
      enableDrag: !result.isForceUpdate,
      backgroundColor: StaticColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => PopScope(
        canPop: !result.isForceUpdate,
        child: ShowVersionSheet(
          latestVersion: result.latestVersion,
          updateUrl: result.updateUrl,
          force: result.isForceUpdate,
        ),
      ),
    );
  }

  static Future<void> _showTabletDialog(
    BuildContext context,
    AppVersionCheckResult result,
  ) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final maxWidth = isLandscape ? 480.0 : 420.0;

    return showDialog<void>(
      context: context,
      barrierDismissible: !result.isForceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !result.isForceUpdate,
        child: Dialog(
          backgroundColor: StaticColors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 48 : 40,
            vertical: isLandscape ? 24 : 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ShowVersionSheet(
              latestVersion: result.latestVersion,
              updateUrl: result.updateUrl,
              force: result.isForceUpdate,
            ),
          ),
        ),
      ),
    );
  }

  static AppVersionCheckResult _evaluate(
    String currentVersion,
    AppVersionModel model,
  ) {
    final platform = Platform.isIOS ? model.ios : model.android;
    final latest = platform?.latestVersion?.trim() ?? '';
    final minSupported = platform?.minSupportedVersion?.trim() ?? '';
    final updateUrl = platform?.updateUrl?.trim() ?? '';

    var shouldShow = false;
    var force = false;

    if (minSupported.isNotEmpty &&
        compareAppVersions(currentVersion, minSupported) < 0) {
      shouldShow = true;
      force = true;
    } else if (latest.isNotEmpty &&
        compareAppVersions(currentVersion, latest) < 0) {
      shouldShow = true;
      force = false;
    }

    return AppVersionCheckResult(
      shouldShowUpdate: shouldShow,
      isForceUpdate: force,
      latestVersion: latest.isNotEmpty ? latest : currentVersion,
      updateUrl: updateUrl,
    );
  }
}
