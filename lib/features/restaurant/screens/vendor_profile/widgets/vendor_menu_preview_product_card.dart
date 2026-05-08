import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';

class VendorMenuPreviewProductCard extends StatefulWidget {
  const VendorMenuPreviewProductCard({
    super.key,
    required this.product,
    required this.onEditTap,
    required this.onAvailabilityChange,
  });

  final VendorProductModel product;
  final VoidCallback onEditTap;
  final Future<void> Function(bool isAvailable) onAvailabilityChange;

  @override
  State<VendorMenuPreviewProductCard> createState() =>
      _VendorMenuPreviewProductCardState();
}

class _VendorMenuPreviewProductCardState
    extends State<VendorMenuPreviewProductCard> {
  late bool _available;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _available = widget.product.isAvailable ?? true;
  }

  @override
  void didUpdateWidget(covariant VendorMenuPreviewProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      setState(() {
        _available = widget.product.isAvailable ?? true;
      });
      return;
    }
    if (!_busy) {
      final server = widget.product.isAvailable ?? true;
      if (server != _available) {
        setState(() => _available = server);
      }
    }
  }

  Future<void> _onSwitch(bool value) async {
    final prev = _available;
    setState(() {
      _available = value;
      _busy = true;
    });
    try {
      await widget.onAvailabilityChange(value);
      if (mounted) setState(() => _busy = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _available = prev;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first.imageUrl
        : null;
    final discount = widget.product.discounts.isNotEmpty
        ? widget.product.discounts.first
        : null;
    final discountBadgeText = _resolveDiscountBadgeText(discount);
    final price =
        widget.product.finalPrice?.toStringAsFixed(2) ??
        widget.product.price ??
        '-';
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
                  _unavailableImageOverlay(
                    context,
                    const BorderRadius.vertical(top: Radius.circular(12)),
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
                            widget.product.name,
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
                      widget.product.name,
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
                    widget.product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.regular12(
                      context,
                      color: StaticColors.c9AA0A6,
                    ),
                  ),
                  const Spacer(),
                  _availabilityRow(context),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: widget.onEditTap,
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

  Widget _availabilityRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            TranslationKeys.productInMenuSwitch.tr(context: context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.regular12(
              context,
              color: StaticColors.c666666,
            ),
          ),
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Switch.adaptive(
          value: _available,
          onChanged: _busy ? null : _onSwitch,
          activeTrackColor: StaticColors.primary,
          activeThumbColor: StaticColors.white,
          inactiveTrackColor: StaticColors.cE0E0E0,
          inactiveThumbColor: StaticColors.white,
        ),
      ],
    );
  }

  Widget _unavailableImageOverlay(
    BuildContext context,
    BorderRadius borderRadius,
  ) {
    if (_available) return const SizedBox.shrink();
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: StaticColors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    TranslationKeys.productUnavailableBadge.tr(
                      context: context,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.semibold12(
                      context,
                      color: StaticColors.cFF4E4E,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileCard(
    BuildContext context, {
    required String? imageUrl,
    required String? discountBadgeText,
    required String price,
    required String? oldPrice,
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
                  _unavailableImageOverlay(
                    context,
                    BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
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
                      widget.product.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.regular12(
                        context,
                        size: 11.5,
                        color: StaticColors.c9AA0A6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _availabilityRow(context),
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
                        onTap: widget.onEditTap,
                        child: Text(
                          TranslationKeys.editProductTitle.tr(
                            context: context,
                          ),
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
    final old = widget.product.price?.trim();
    if (old == null || old.isEmpty) return null;
    final finalP = widget.product.finalPrice;
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
