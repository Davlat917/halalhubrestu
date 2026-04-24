import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

@RoutePage()
class DefaultFallbackPage extends StatelessWidget {
  const DefaultFallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: StaticColors.primary,
                size: 56,
              ),
              const SizedBox(height: 14),
              Text(
                TranslationKeys.fallbackTitle.tr(context: context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: StaticColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                TranslationKeys.fallbackDescription.tr(context: context),
                style: const TextStyle(
                  fontSize: 14,
                  color: StaticColors.c666666,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => context.router.replace(const SplashRoute()),
                child: Text(
                  TranslationKeys.fallbackGoHome.tr(context: context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
