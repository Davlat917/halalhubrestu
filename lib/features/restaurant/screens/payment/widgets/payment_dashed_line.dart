import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class PaymentDashedLine extends StatelessWidget {
  const PaymentDashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(dashCount, (index) {
            return Expanded(
              child: Container(
                height: 1.2,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                color: index.isEven ? StaticColors.c9AA0A6 : Colors.transparent,
              ),
            );
          }),
        );
      },
    );
  }
}
