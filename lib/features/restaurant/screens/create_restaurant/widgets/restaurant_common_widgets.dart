import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class RestaurantChoiceTile extends StatelessWidget {
  const RestaurantChoiceTile({
    super.key,
    required this.availableWidth,
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final double availableWidth;
  final bool selected;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? StaticColors.primary : StaticColors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.regular14(context, aW: availableWidth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantFieldLabel extends StatelessWidget {
  const RestaurantFieldLabel({
    super.key,
    required this.availableWidth,
    required this.text,
  });

  final double availableWidth;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyle.regular14(
          context,
          aW: availableWidth,
          color: StaticColors.c666666,
        ),
      ),
    );
  }
}

class MapZoomButton extends StatelessWidget {
  const MapZoomButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StaticColors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: StaticColors.black),
        ),
      ),
    );
  }
}
