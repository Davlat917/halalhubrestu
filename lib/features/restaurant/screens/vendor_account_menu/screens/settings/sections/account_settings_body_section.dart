import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/models/account_profile_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/widgets/account_profile_header_card.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/widgets/account_settings_info_card.dart';

class AccountSettingsBodySection extends StatelessWidget {
  const AccountSettingsBodySection({
    super.key,
    required this.profile,
    required this.maxContentWidth,
  });

  final AccountProfileModel profile;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        AccountProfileHeaderCard(profile: profile),
        const SizedBox(height: 12),
        AccountSettingsInfoCard(
          children: [
            AccountSettingsInfoRow(
              label: TranslationKeys.settingsVendorName.tr(context: context),
              value: profile.vendorName,
            ),
            AccountSettingsInfoRow(
              label: TranslationKeys.settingsEmail.tr(context: context),
              value: profile.email,
            ),
            AccountSettingsInfoRow(
              label: TranslationKeys.settingsPhoneNumber.tr(context: context),
              value: profile.phoneNumber,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ChangePasswordTile(
          onPressed: () {
            context.router.push(
              ChangePasswordRoute(initialEmail: profile.email),
            );
          },
        ),
      ],
    );

    if (maxContentWidth != null) {
      child = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: child,
        ),
      );
    }
    return child;
  }
}

class _ChangePasswordTile extends StatelessWidget {
  const _ChangePasswordTile({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StaticColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: StaticColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  TranslationKeys.settingsChangePassword.tr(context: context),
                  style: AppTextStyle.medium16(
                    context,
                    size: 15,
                    color: StaticColors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: StaticColors.c666666.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
