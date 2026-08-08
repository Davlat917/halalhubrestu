import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowVersionSheet extends ResponsiveSection {
  const ShowVersionSheet({
    super.key,
    required this.latestVersion,
    required this.updateUrl,
    this.force = false,
  });

  final String latestVersion;
  final String updateUrl;
  final bool force;

  @override
  Widget buildMobile(BuildContext context) => _VersionContent(
    latestVersion: latestVersion,
    updateUrl: updateUrl,
    force: force,
    maxContentWidth: double.infinity,
    padding: EdgeInsets.fromLTRB(
      context.w(24),
      context.h(16),
      context.w(24),
      context.h(16),
    ),
    iconSize: context.w(48),
    showHandle: true,
  );

  @override
  Widget buildTablet(BuildContext context) => _VersionContent(
    latestVersion: latestVersion,
    updateUrl: updateUrl,
    force: force,
    maxContentWidth: 420,
    padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
    iconSize: 56,
    showHandle: false,
  );

  @override
  Widget? buildTabletLandscape(BuildContext context) => _VersionContent(
    latestVersion: latestVersion,
    updateUrl: updateUrl,
    force: force,
    maxContentWidth: 480,
    padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
    iconSize: 56,
    showHandle: false,
  );

  @override
  Widget buildDesktop(BuildContext context) =>
      buildTabletLandscape(context) ?? buildTablet(context);
}

class _VersionContent extends StatelessWidget {
  const _VersionContent({
    required this.latestVersion,
    required this.updateUrl,
    required this.force,
    required this.maxContentWidth,
    required this.padding,
    required this.iconSize,
    required this.showHandle,
  });

  final String latestVersion;
  final String updateUrl;
  final bool force;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: StaticColors.cD1D1D1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(width: 40, height: 4),
            ),
            SizedBox(height: context.h(24)),
          ],
          Icon(
            Icons.system_update_alt_rounded,
            size: iconSize,
            color: StaticColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            TranslationKeys.updateRecommendedTitle.tr(context: context),
            style: AppTextStyle.bold20(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'v$latestVersion',
            style: AppTextStyle.semibold14(
              context,
              color: StaticColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            TranslationKeys.updateRecommendedDesc.tr(context: context),
            style: AppTextStyle.regular14(
              context,
              color: StaticColors.c9AA0A6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : maxContentWidth;
              return CustomButton(
                label: TranslationKeys.updateApp.tr(context: context),
                backgroundColor: StaticColors.primary,
                foregroundColor: StaticColors.white,
                width: buttonWidth,
                onPressed: _launchStore,
              );
            },
          ),
          if (!force) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                TranslationKeys.skip.tr(context: context),
                style: AppTextStyle.medium14(
                  context,
                  color: StaticColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return SafeArea(
      child: Align(
        alignment: showHandle ? Alignment.bottomCenter : Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: body,
        ),
      ),
    );
  }

  Future<void> _launchStore() async {
    final url = updateUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
