import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Faol buyurtmalar bo‘sh bo‘lganda.
class OrdersEmptyView extends StatelessWidget {
  const OrdersEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.orderEmpty.image(
                    fit: BoxFit.contain,
                    width: 280,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    TranslationKeys.ordersEmpty.tr(context: context),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.semibold16(
                      context,
                      color: StaticColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
