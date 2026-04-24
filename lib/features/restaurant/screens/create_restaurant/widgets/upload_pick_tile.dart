import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';

class UploadPickTile extends StatelessWidget {
  const UploadPickTile({
    super.key,
    required this.availableWidth,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onPressed,
    this.height,
    this.imagePath,
    this.onDeleteImage,
    this.useDashedBorder = false,
    this.emptyIconAssetPath,
    this.buttonHeight, //
    this.hideIconInLandscape = true,
    this.compactInLandscape = true,
  });

  final double availableWidth;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double? height;
  final String? imagePath;
  final VoidCallback? onDeleteImage;
  final bool useDashedBorder;
  final String? emptyIconAssetPath;
  final double? buttonHeight;
  final bool hideIconInLandscape;
  final bool compactInLandscape;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final tileHeight = height ?? context.wOf(105, availableWidth);
    final effectiveHeight = isLandscape && compactInLandscape
        ? tileHeight * 0.84
        : tileHeight;
    final isNetworkImage =
        imagePath != null &&
        (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));
    Widget content = Container(
      height: effectiveHeight,
      padding: imagePath != null
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              vertical: context.wOf(10, availableWidth),
              horizontal: context.wOf(10, availableWidth),
            ),
      decoration: BoxDecoration(
        color: StaticColors.cEAF8EF,
        borderRadius: BorderRadius.circular(10),
        border: useDashedBorder
            ? null
            : Border.all(color: StaticColors.primary),
      ),
      child: imagePath != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isNetworkImage
                        ? Image.network(
                            imagePath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                if (onDeleteImage != null)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Material(
                      color: StaticColors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: onDeleteImage,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final localW = constraints.maxWidth.clamp(120.0, 560.0);
                final tightHeight = constraints.maxHeight < 110;
                final showIcon =
                    !(isLandscape && hideIconInLandscape) &&
                    buttonLabel == null;
                final showSubtitle =
                    subtitle != null &&
                    constraints.maxHeight >= 96 &&
                    !(isLandscape && buttonLabel != null);
                final resolvedButtonHeight =
                    buttonHeight ??
                    (tightHeight ? 34.0 : context.wOf(34, localW));
                final verticalGap = tightHeight ? 4.0 : context.wOf(6, localW);
                final buttonWidth = (constraints.maxWidth - 24).clamp(
                  96.0,
                  130.0,
                );
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: buttonLabel != null
                          ? MainAxisAlignment.spaceEvenly
                          : MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showIcon) ...[
                          if (emptyIconAssetPath != null)
                            Image.asset(
                              emptyIconAssetPath!,
                              width: tightHeight ? 18 : context.wOf(22, localW),
                              height: tightHeight
                                  ? 18
                                  : context.wOf(22, localW),
                              fit: BoxFit.contain,
                            )
                          else
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: StaticColors.primary,
                              size: 18,
                            ),
                          SizedBox(height: verticalGap),
                        ],
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.medium12(
                            context,
                            size: 13,
                            color: StaticColors.primary,
                          ),
                        ),
                        if (showSubtitle)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.regular10(
                              context,
                              size: 11,
                              color: StaticColors.primary,
                            ),
                          ),
                        if (buttonLabel != null) ...[
                          SizedBox(
                            height: tightHeight
                                ? 6
                                : context.wOf(8, availableWidth),
                          ),
                          SizedBox(
                            width: buttonWidth > constraints.maxWidth
                                ? constraints.maxWidth - 8
                                : buttonWidth,
                            height: resolvedButtonHeight,
                            child: CustomButton(
                              label: buttonLabel!,
                              width: buttonWidth > constraints.maxWidth
                                  ? constraints.maxWidth - 8
                                  : buttonWidth,
                              height: resolvedButtonHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              textStyle: AppTextStyle.medium12(
                                context,
                                size: 11,
                                color: StaticColors.white,
                              ),
                              onPressed: onPressed,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
    if (useDashedBorder && imagePath == null) {
      content = CustomPaint(
        painter: _DashedRectPainter(color: StaticColors.primary, radius: 10),
        child: content,
      );
    }
    return GestureDetector(onTap: onPressed, child: content);
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
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final metric in metrics) {
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
