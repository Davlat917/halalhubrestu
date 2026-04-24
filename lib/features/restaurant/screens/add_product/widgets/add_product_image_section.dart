import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';

class AddProductImageSection extends StatelessWidget {
  const AddProductImageSection({
    super.key,
    required this.images,
    required this.onPick,
    required this.onRemoveImage,
    this.initialImageUrls = const [],
    this.onRemoveInitialImage,
  });

  final List<XFile> images;
  final Future<void> Function() onPick;
  final ValueChanged<int> onRemoveImage;
  final List<String> initialImageUrls;
  final ValueChanged<int>? onRemoveInitialImage;

  @override
  Widget build(BuildContext context) {
    final visibleInitialUrls = initialImageUrls.take(3).toList(growable: false);
    final hasMaxImages = visibleInitialUrls.length + images.length >= 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TranslationKeys.productFoodImage.tr(context: context),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: hasMaxImages ? null : onPick,
          child: CustomPaint(
            painter: _DashedRectPainter(
              color: StaticColors.primary,
              radius: 14,
            ),
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F3),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.uploadIcon.svg(height: 44),
                  const SizedBox(height: 10),
                  Text(
                    TranslationKeys.productFoodImageHint.tr(context: context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: StaticColors.primary),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: TranslationKeys.browseFile.tr(context: context),
                    onPressed: hasMaxImages ? null : onPick,
                    backgroundColor: hasMaxImages
                        ? StaticColors.cE2E2E2
                        : StaticColors.primary,
                    foregroundColor: StaticColors.white,
                    textStyle: AppTextStyle.regular14(
                      context,
                      color: StaticColors.white,
                    ),
                    width: 180,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _ImageSlot(
                    imageUrl: i < visibleInitialUrls.length
                        ? visibleInitialUrls[i]
                        : null,
                    file:
                        i >= visibleInitialUrls.length &&
                            (i - visibleInitialUrls.length) < images.length
                        ? images[i - visibleInitialUrls.length]
                        : null,
                    onRemove:
                        i >= visibleInitialUrls.length &&
                            (i - visibleInitialUrls.length) < images.length
                        ? () => onRemoveImage(i - visibleInitialUrls.length)
                        : (i < visibleInitialUrls.length &&
                                  onRemoveInitialImage != null
                              ? () => onRemoveInitialImage!(i)
                              : null),
                  ),
                ),
              ),
              if (i != 2) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot({this.file, this.imageUrl, this.onRemove});

  final XFile? file;
  final String? imageUrl;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (file == null && (imageUrl == null || imageUrl!.isEmpty)) {
      return CustomPaint(
        painter: _DashedRectPainter(color: StaticColors.primary, radius: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7F3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    final imageWidget = file != null
        ? (kIsWeb
              ? Image.network(
                  file!.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _errorImage(),
                )
              : Image.file(
                  File(file!.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _errorImage(),
                ))
        : Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorImage(),
          );

    return CustomPaint(
      painter: _DashedRectPainter(color: StaticColors.primary, radius: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(child: imageWidget),
          ),
          if (onRemove != null)
            Positioned(
              right: 10,
              bottom: 10,
              child: Material(
                color: StaticColors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.delete_outline, size: 22),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      color: StaticColors.cF4F4F4,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
