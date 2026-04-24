import 'package:auto_route/auto_route.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class CircleBtnWidget extends StatelessWidget {
  const CircleBtnWidget({
    super.key,
    this.bgColor,
    this.icon,
    this.iconColor,
    this.onPress,
    this.height,
    this.radius,
    this.width,
    this.padding, //
  });
  final SvgGenImage? icon;
  final Color? iconColor;
  final Color? bgColor;
  final VoidCallback? onPress;
  final double? height;
  final double? width;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    // final bool isTablet = MediaQuery.sizeOf(context).width >= 700;
    // final double resolvedSize = isTablet ? context.size24 : height ?? context.size35;
    final ShapeBorder resolvedShape = CircleBorder(side: BorderSide.none, eccentricity: 0);

    return Material(
      color: bgColor ?? StaticColors.white,
      borderRadius: BorderRadius.circular(radius ?? 100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: resolvedShape,
        onTap: onPress ?? () => context.router.pop(),
        child: Container(
          padding: padding ?? EdgeInsets.all(6),
          height: height ?? context.size35,
          width: width ?? context.size35,
          decoration: BoxDecoration(color: StaticColors.transparent, borderRadius: BorderRadius.circular(radius ?? 100)),
          child: (icon ?? Assets.icons.arrowBackIcon).svg(colorFilter: ColorFilter.mode(iconColor ?? StaticColors.black, BlendMode.srcIn)),
        ),
      ),
    );
  }
}
