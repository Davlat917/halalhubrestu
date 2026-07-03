import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/delete_account/data/delete_account_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/language/language_picker_sheet.dart';
import 'package:halalhub_restaurant/core/services/launch_social_or_phone.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Hisob menyusi uchun dialog va placeholder amallar.
abstract final class VendorAccountMenuHandlers {
  static const destructive = StaticColors.cFF4E4E;

  static void showComingSoon(BuildContext context) {
    getIt<Display>().info(TranslationKeys.comingSoon.tr(context: context));
  }

  static Future<void> showLanguagePicker(BuildContext context) async {
    await LanguagePickerSheet.open(context);
  }

  static Future<void> openInstagram(BuildContext context) {
    return _launchSocialLink(
      context,
      'instagram:${Constants.supportInstagramUsername}',
    );
  }

  static Future<void> openWhatsapp(BuildContext context) {
    return _launchSocialLink(
      context,
      'whatsapp:${Constants.supportWhatsappLaunchNumber}',
    );
  }

  static Future<void> openPhone(BuildContext context) {
    return _launchSocialLink(context, Constants.supportUsPhoneE164);
  }

  static Future<void> _launchSocialLink(
    BuildContext context,
    String target,
  ) async {
    try {
      await launchSocialOrPhone(target);
    } catch (_) {
      if (!context.mounted) return;
      getIt<Display>().error(
        TranslationKeys.commonCouldNotOpenLink.tr(context: context),
      );
    }
  }

  static void showLogOutPlaceholder(BuildContext context) {
    _showWarningDialog(
      context: context,
      icon: Assets.icons.logoutIcon,
      title: TranslationKeys.logoutConfirmTitle.tr(context: context),
      description: TranslationKeys.logoutConfirmDescription.tr(
        context: context,
      ),
      yesLabel: TranslationKeys.yes.tr(context: context),
    );
  }

  /// Sabab tanlangandan keyin yakuniy tasdiq dialogi.
  static Future<void> showDeleteAccountConfirmDialog(
    BuildContext context, {
    required String reasonLabel,
  }) async {
    await _showWarningDialog(
      context: context,
      icon: Assets.icons.deleteIcon,
      title: TranslationKeys.deleteConfirmTitle.tr(context: context),
      description: TranslationKeys.deleteConfirmDescription.tr(
        context: context,
        namedArgs: {'reason': reasonLabel},
      ),
      yesLabel: TranslationKeys.yes.tr(context: context),
      onConfirm: () => _deleteAccountAndGoToLogin(context: context),
    );
  }

  static Future<void> _showWarningDialog({
    required BuildContext context,
    required SvgGenImage icon,
    required String title,
    required String description,
    required String yesLabel,
    Future<void> Function()? onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final maxW = _warningDialogMaxWidth(ctx);
        final inset = _warningDialogInset(ctx);
        return Dialog(
          backgroundColor: StaticColors.white,
          insetPadding: inset,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: destructive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: icon.svg(
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        destructive,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.semibold18(ctx),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular14(
                      ctx,
                      color: StaticColors.c666666,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, c) => CustomButton(
                            label: TranslationKeys.cancel.tr(context: ctx),
                            type: ButtonType.outlined,
                            borderColor: StaticColors.cE2E2E2,
                            foregroundColor: StaticColors.black,
                            width: c.maxWidth,
                            height: 46,
                            textStyle: AppTextStyle.medium14(ctx),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, c) => CustomButton(
                            label: yesLabel,
                            backgroundColor: destructive,
                            foregroundColor: StaticColors.white,
                            width: c.maxWidth,
                            height: 46,
                            textStyle: AppTextStyle.medium14(
                              ctx,
                              color: StaticColors.white,
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              if (onConfirm != null) {
                                await onConfirm();
                              } else {
                                await _finishSessionAndGoToLogin();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _clearSessionTokens() async {
    final storage = getIt<Storage>();
    await storage.token.delete();
    await storage.refreshToken.delete();
  }

  static Future<void> _deleteAccountAndGoToLogin({
    required BuildContext context,
  }) async {
    final router = getIt<AppRouter>();
    final display = getIt<Display>();
    final rootCtx = router.navigatorKey.currentContext ?? context;
    var loadingShown = false;

    void hideLoading() {
      if (!loadingShown) return;
      loadingShown = false;
      final navCtx = router.navigatorKey.currentContext;
      if (navCtx != null && navCtx.mounted) {
        final nav = Navigator.of(navCtx, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }
    }

    if (rootCtx.mounted) {
      loadingShown = true;
      showDialog<void>(
        context: rootCtx,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (loadingCtx) => PopScope(
          canPop: false,
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: Card(
                color: StaticColors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator.adaptive()],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    try {
      await getIt<DeleteAccountRepository>().deleteAccount();
      await _clearSessionTokens();
      hideLoading();
      if (context.mounted) {
        display.success(
          TranslationKeys.deleteAccountSuccess.tr(context: context),
        );
      }
      await router.replaceAll([
        const AuthFlowRoute(children: [SignInRoute()]),
      ]);
    } catch (e) {
      hideLoading();
      final message = e is NetworkException
          ? e.message
          : TranslationKeys.deleteAccountFailed.tr(context: context);
      if (context.mounted) {
        display.error(
          message.isNotEmpty
              ? message
              : TranslationKeys.deleteAccountFailed.tr(context: context),
        );
      }
    }
  }

  /// Tasdiqdan keyin tokenlarni tozalash, login sahifasiga o‘tish.
  static Future<void> _finishSessionAndGoToLogin() async {
    final router = getIt<AppRouter>();
    final rootCtx = router.navigatorKey.currentContext;
    var loadingShown = false;

    if (rootCtx != null && rootCtx.mounted) {
      loadingShown = true;
      showDialog<void>(
        context: rootCtx,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (loadingCtx) => PopScope(
          canPop: false,
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Card(
                color: StaticColors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator.adaptive()],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    await _clearSessionTokens();

    if (loadingShown) {
      final navCtx = router.navigatorKey.currentContext;
      if (navCtx != null && navCtx.mounted) {
        final nav = Navigator.of(navCtx, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }
    }

    await router.replaceAll([
      const AuthFlowRoute(children: [SignInRoute()]),
    ]);
  }

  /// [CustomButton] default `width` = butun ekran — dialog ichida shu sabab cho‘zilgan.
  static double _warningDialogMaxWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ss = size.shortestSide;
    final isMobile = ResponsiveSection.isMobileLayout(context);
    final isTablet =
        ss >= ResponsiveSection.mobileBreakpoint &&
        size.width < ResponsiveSection.desktopBreakpoint;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    if (isMobile) {
      if (landscape) {
        return (size.width * 0.52).clamp(288.0, 380.0);
      }
      return (size.width * 0.88).clamp(288.0, 360.0);
    }
    if (isTablet) {
      if (landscape) {
        return 380.0;
      }
      return 400.0;
    }
    return 420.0;
  }

  static EdgeInsets _warningDialogInset(BuildContext context) {
    final isMobile = ResponsiveSection.isMobileLayout(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (isMobile) {
      final h = landscape ? 16.0 : 24.0;
      return EdgeInsets.symmetric(horizontal: 20, vertical: h);
    }
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >=
            ResponsiveSection.mobileBreakpoint &&
        MediaQuery.sizeOf(context).width < ResponsiveSection.desktopBreakpoint;
    if (isTablet && landscape) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 56, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
  }
}
