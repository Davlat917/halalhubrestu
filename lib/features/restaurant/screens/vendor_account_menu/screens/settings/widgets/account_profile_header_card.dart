import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/models/account_profile_model.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

class AccountProfileHeaderCard extends StatelessWidget {
  const AccountProfileHeaderCard({super.key, required this.profile});

  final AccountProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Row(
        children: [
          const _ProfileIcon(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.semibold18(context),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email.isNotEmpty ? profile.email : profile.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regular14(
                    context,
                    color: StaticColors.c666666,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: const BoxDecoration(
        color: StaticColors.cEAF8EF,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Assets.icons.profileIcon.svg(
        width: 32,
        height: 32,
        colorFilter: const ColorFilter.mode(
          StaticColors.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
