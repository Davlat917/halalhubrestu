import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class RestaurantStepIndicator extends StatelessWidget {
  const RestaurantStepIndicator({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    required this.availableWidth,
    this.onStepTap,
  });

  final int currentStep;
  final List<bool> completedSteps;
  final double availableWidth;
  final void Function(int index)? onStepTap;

  static const _titles = ['Basic', 'Documents', 'Location', 'Work hours'];

  @override
  Widget build(BuildContext context) {
    final dotSize = context.wOf(22, availableWidth);
    return Column(
      children: [
        SizedBox(
          height: dotSize + context.wOf(26, availableWidth),
          child: Stack(
            children: [
              Positioned(
                top: dotSize / 2 - 1,
                left: 0,
                right: 0,
                child: Align(
                  child: FractionallySizedBox(
                    widthFactor: (_titles.length - 1) / _titles.length,
                    child: Row(
                      children: List.generate(_titles.length - 1, (i) {
                        final isActive = i < currentStep;
                        return Expanded(
                          child: Container(
                            height: 2,
                            color: isActive || completedSteps[i]
                                ? StaticColors.primary
                                : StaticColors.cD1D1D1,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_titles.length, (i) {
                  final done = completedSteps[i];
                  final active = i == currentStep;
                  final dotColor = done
                      ? StaticColors.primary
                      : StaticColors.white;
                  final iconColor = done
                      ? StaticColors.white
                      : StaticColors.primary;
                  return Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: onStepTap == null ? null : () => onStepTap!(i),
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              border: Border.all(color: StaticColors.primary),
                            ),
                            child: Icon(
                              done ? Icons.check : Icons.circle,
                              size: done ? 20 : 8,
                              color: iconColor,
                            ),
                          ),
                        ),
                        SizedBox(height: context.wOf(6, availableWidth)),
                        Text(
                          _titles[i],
                          textAlign: TextAlign.center,
                          style: AppTextStyle.regular12(
                            context,
                            aW: availableWidth,
                            color: done || active
                                ? StaticColors.primary
                                : StaticColors.c9AA0A6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
