import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeText extends StatelessWidget {
  final double? availableWidth;
  final double? availableHeight;
  final String? otpText;
  final String? otpSubText;
  final PinInputController? controller;
  final Function(String)? onChanged;
  final bool obSures;
  final int length;
  final double fieldWidth;
  final double fieldHeight;
  final void Function(String)? onCompleted;
  // final PinInputController controller;
  final bool hasError;

  const PinCodeText({
    super.key,
    this.otpText,
    this.otpSubText,
    this.controller,
    this.onChanged,
    required this.obSures,
    this.onCompleted,
    required this.length,
    required this.fieldWidth,
    required this.fieldHeight, //
    // required this.errorController,
    required this.hasError,
    this.availableWidth,
    this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final aW = availableWidth ?? context.screenWidth;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          MaterialPinField(
            length: length,
            pinController: controller,
            obscureText: obSures,
            onCompleted: onCompleted,
            onChanged: onChanged,
            theme: MaterialPinTheme(
              shape: MaterialPinShape.outlined,
              cellSize: Size(fieldWidth, fieldHeight),
              borderRadius: BorderRadius.circular(8),
              fillColor: StaticColors.backgroundColor,
              focusedFillColor: StaticColors.white,
              filledFillColor: StaticColors.white,
              borderColor: hasError ? Colors.red : StaticColors.transparent,
              focusedBorderColor: hasError ? Colors.red : StaticColors.primary,
              filledBorderColor: hasError ? Colors.red : StaticColors.primary,
              errorColor: Colors.red,
              textStyle: AppTextStyle.regular18(context, aW: aW, color: StaticColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
