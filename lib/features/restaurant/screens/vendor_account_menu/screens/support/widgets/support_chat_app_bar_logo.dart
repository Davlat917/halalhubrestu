import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Keng logo doira ichida qirqilmasin — [BoxFit.contain] + padding.
class SupportChatAppBarLogo extends StatelessWidget {
  const SupportChatAppBarLogo({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: StaticColors.cF4F4F4,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ClipOval(
          child: Assets.images.logoImage.image(
            width: d - 10,
            height: d - 10,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
