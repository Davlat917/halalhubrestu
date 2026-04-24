import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';

class VendorCoverHeader extends StatelessWidget {
  const VendorCoverHeader({
    super.key,
    required this.coverUrl,
    required this.logoUrl,
    required this.isTablet,
    required this.maxWidth,
    this.onLogoTap,
  });

  final String? coverUrl;
  final String? logoUrl;
  final bool isTablet;
  final double maxWidth;
  final VoidCallback? onLogoTap;

  @override
  Widget build(BuildContext context) {
    final coverH = context.wOf(isTablet ? 220 : 180, maxWidth);
    final logoSize = context.wOf(isTablet ? 100 : 88, maxWidth);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: coverH,
          width: double.infinity,
          child: NetworkImageCache(
            imgUrl: coverUrl,
            heightH: coverH,
            widthW: double.infinity,
            radius: 0,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: context.wOf(16, maxWidth),
          bottom: -(logoSize / 2),
          child: _LogoTapWrapper(
            borderRadius: BorderRadius.circular(13),
            onTap: onLogoTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StaticColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: StaticColors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: NetworkImageCache(
                  imgUrl: logoUrl,
                  widthW: logoSize,
                  heightH: logoSize,
                  radius: 0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoTapWrapper extends StatelessWidget {
  const _LogoTapWrapper({
    required this.borderRadius,
    required this.child,
    this.onTap,
  });

  final BorderRadius borderRadius;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

