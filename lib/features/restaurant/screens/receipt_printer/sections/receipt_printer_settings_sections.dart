import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

class ReceiptPrinterIntroSection extends StatelessWidget {
  const ReceiptPrinterIntroSection({super.key, this.wifiIp});

  final String? wifiIp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.printerIntro.tr(
            context: context,
            namedArgs: {'port': '${ReceiptPrinterService.defaultRawPort}'},
          ),
          style: AppTextStyle.regular14(context, color: StaticColors.c666666),
        ),
        const SizedBox(height: 16),
        if (wifiIp != null)
          Text(
            TranslationKeys.printerWifiIp.tr(
              context: context,
              namedArgs: {'ip': wifiIp!},
            ),
            style: AppTextStyle.medium14(context),
          ),
      ],
    );
  }
}

class ReceiptPrinterManualConnectSection extends StatelessWidget {
  const ReceiptPrinterManualConnectSection({
    super.key,
    required this.controller,
    required this.scanning,
    required this.onScan,
    required this.onManualChanged,
  });

  final TextEditingController controller;
  final bool scanning;
  final VoidCallback onScan;
  final ValueChanged<String> onManualChanged;

  @override
  Widget build(BuildContext context) {
    final aw = MediaQuery.sizeOf(context).width;
    final buttonHeight = context.wOf(50, aw).clamp(44.0, 50.0);
    final buttonTextStyle = AppTextStyle.regular14(
      context,
      size: context.spOf(12, aw),
    );
    final stackedButtons = aw < 600;

    Widget scanButton() => CustomButton(
      label: TranslationKeys.printerSearchWifi.tr(context: context),
      onPressed: scanning ? null : onScan,
      isLoading: scanning,
      isDisabled: scanning,
      height: buttonHeight,
      textStyle: buttonTextStyle, //
    );

    return Column(
      children: [
        CommonTextField(
          controller: controller,
          onChanged: onManualChanged,
          keyboardType: TextInputType.number,
          inputFormatter: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          hint: TranslationKeys.printerIpHint.tr(context: context),
          textSize: context.spOf(14, aw).clamp(13.0, 14.0),
          padding: EdgeInsets.symmetric(
            horizontal: context.wOf(16, aw).clamp(12.0, 16.0),
            vertical: context.wOf(12, aw).clamp(10.0, 12.0),
          ),
        ),
        const SizedBox(height: 12),
        if (stackedButtons) ...[
          scanButton(),
        ] else
          scanButton(),
      ],
    );
  }
}

class ReceiptPrinterStatusSection extends StatelessWidget {
  const ReceiptPrinterStatusSection({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status != null) ...[
          Text(
            status!,
            style: AppTextStyle.regular14(context, color: StaticColors.black),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class ReceiptPrinterFoundDevicesSection extends StatelessWidget {
  const ReceiptPrinterFoundDevicesSection({
    super.key,
    required this.found,
    required this.scanning,
    required this.onTap,
  });

  final List<String> found;
  final bool scanning;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (found.isEmpty && !scanning) {
      return Text(
        TranslationKeys.printerNoSearchResult.tr(context: context),
        style: AppTextStyle.regular14(context, color: StaticColors.c666666),
      );
    }
    return Column(
      children: [
        for (final ip in found)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(ip, style: AppTextStyle.medium14(context)),
              subtitle: Text(
                TranslationKeys.printerPort.tr(
                  context: context,
                  namedArgs: {
                    'port': '${ReceiptPrinterService.defaultRawPort}',
                  },
                ),
                style: AppTextStyle.regular12(context),
              ),
              trailing: const Icon(
                Icons.link_rounded,
                color: StaticColors.primary,
              ),
              onTap: () => onTap(ip),
            ),
          ),
      ],
    );
  }
}
