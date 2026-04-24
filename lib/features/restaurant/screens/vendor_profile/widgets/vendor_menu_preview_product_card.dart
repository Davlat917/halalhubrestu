import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';

class VendorMenuPreviewProductCard extends StatelessWidget {
  const VendorMenuPreviewProductCard({
    super.key,
    required this.product,
    required this.onEditTap,
  });

  final VendorProductModel product;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first.imageUrl
        : null;
    final discount = product.discounts.isNotEmpty
        ? product.discounts.first
        : null;
    final discountBadgeText = _resolveDiscountBadgeText(discount);
    final price =
        product.finalPrice?.toStringAsFixed(2) ?? product.price ?? '-';
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.shortestSide < 600;
    final isTabletLandscape =
        size.shortestSide >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final oldPrice = _resolveOldPriceText();

    if (isMobile) {
      return _mobileCard(
        context,
        imageUrl: imageUrl,
        discountBadgeText: discountBadgeText,
        price: price,
        oldPrice: oldPrice,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: StaticColors.cF4F4F4,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? const Icon(
                              Icons.image_not_supported_outlined,
                              color: StaticColors.c9AA0A6,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    color: StaticColors.c9AA0A6,
                                  ),
                            ),
                    ),
                  ),
                  if (discountBadgeText != null)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.8,
                        ),
                        child: _DiscountBadge(
                          text: discountBadgeText,
                          color: StaticColors.cFF4E4E,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTabletLandscape)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.medium16(
                              context,
                              size: 14,
                              color: StaticColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$price \$',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.medium16(
                            context,
                            color: StaticColors.primary,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      '$price \$',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.medium16(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.medium16(
                        context,
                        size: 14,
                        color: StaticColors.black,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.regular12(
                      context,
                      color: StaticColors.c9AA0A6,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onEditTap,
                      child: Text(
                        TranslationKeys.editProductTitle.tr(context: context),
                        style: AppTextStyle.regular14(
                          context,
                          color: StaticColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: StaticColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCard(
    BuildContext context, {
    required String? imageUrl,
    required String? discountBadgeText,
    required String price,
    required String? oldPrice, //
  }) {
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: StaticColors.cF4F4F4,
                      width: 120,
                      height: 120,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? const Icon(
                              Icons.image_not_supported_outlined,
                              color: StaticColors.c9AA0A6,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    color: StaticColors.c9AA0A6,
                                  ),
                            ),
                    ),
                  ),
                  if (discountBadgeText != null)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.8,
                        ),
                        child: IntrinsicWidth(
                          child: _DiscountBadge(
                            text: discountBadgeText,
                            color: const Color(0xFFFF8A1E),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.medium16(
                      context,
                      size: 13,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      product.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.regular12(
                        context,
                        size: 11.5,
                        color: StaticColors.c9AA0A6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$price USD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.medium16(
                                context,
                                size: 13,
                                color: StaticColors.primary,
                              ),
                            ),
                            if (oldPrice != null)
                              Text(
                                '$oldPrice USD',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.regular12(
                                  context,
                                  size: 10.5,
                                  color: StaticColors.c9AA0A6,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: StaticColors.c9AA0A6,
                                ),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: onEditTap,
                        child: Text(
                          TranslationKeys.editProductTitle.tr(context: context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.regular12(
                            context,
                            size: 11,
                            color: StaticColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: StaticColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveDiscountBadgeText(VendorProductDiscountModel? discount) {
    if (discount == null) return null;
    final percent = discount.percent ?? 0;
    if (percent != 0) {
      final formattedPercent = percent % 1 == 0
          ? percent.toStringAsFixed(0)
          : percent.toString();
      return TranslationKeys.productPercentOff.tr(
        namedArgs: {'percent': formattedPercent},
      );
    }
    final title = discount.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return null;
  }

  String? _resolveOldPriceText() {
    final old = product.price?.trim();
    if (old == null || old.isEmpty) return null;
    final finalP = product.finalPrice;
    if (finalP == null) return null;
    final oldNum = double.tryParse(old);
    if (oldNum == null) return null;
    if ((oldNum - finalP).abs() < 0.001) return null;
    return oldNum % 1 == 0 ? oldNum.toStringAsFixed(0) : oldNum.toString();
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.regular10(context, color: StaticColors.white),
      ),
    );
  }
}
