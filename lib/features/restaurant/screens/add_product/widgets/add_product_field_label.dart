import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTextStyle.regular14(
          context,
          size: 15,
          color: StaticColors.c4C4C4C,
        ),
        children: required
            ? [
                TextSpan(
                  text: '*',
                  style: AppTextStyle.regular14(
                    context,
                    size: 15,
                    color: StaticColors.cFF4E4E,
                  ),
                ),
              ]
            : const [],
      ),
    );
  }
}
