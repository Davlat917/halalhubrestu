import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

class VendorClipsUploadDropArea extends StatelessWidget {
  const VendorClipsUploadDropArea({
    super.key,
    required this.thumbBytes,
    required this.fileName,
    required this.onBrowseTap,
    required this.onDeleteTap,
  });

  final Uint8List? thumbBytes;
  final String? fileName;
  final VoidCallback? onBrowseTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final hasVideo = thumbBytes != null;

    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        color: StaticColors.primary,
        radius: 14,
      ),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: StaticColors.primary.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: hasVideo
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(thumbBytes!, fit: BoxFit.cover),
                  ),
                  if (fileName != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      right: 54,
                      child: Text(
                        fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StaticColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: StaticColors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onDeleteTap,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: onDeleteTap == null
                                ? StaticColors.c9AA0A6
                                : StaticColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.addVideo.svg(width: 52, height: 52),
                  const SizedBox(height: 8),
                  Text(
                    TranslationKeys.clipsUploadVideo.tr(context: context),
                    style: AppTextStyle.medium14(
                      context,
                      color: StaticColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      TranslationKeys.clipsUploadHint.tr(context: context),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regular10(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    width: 190,
                    height: 40,
                    textStyle: AppTextStyle.regular14(
                      context,
                      color: StaticColors.white,
                    ),
                    label: TranslationKeys.browseFile.tr(context: context),
                    onPressed: onBrowseTap,
                  ),
                ],
              ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  _DashedRoundedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dash = 8.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
