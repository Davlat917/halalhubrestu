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
    required this.connectInProgress,
    required this.onManualConnect,
    required this.onScan,
    required this.onManualChanged,
  });

  final TextEditingController controller;
  final bool scanning;
  final bool connectInProgress;
  final VoidCallback onManualConnect;
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
    final busy = scanning || connectInProgress;

    Widget connectButton() => CustomButton(
      label: TranslationKeys.printerConnect.tr(context: context),
      onPressed: busy ? null : onManualConnect,
      isLoading: connectInProgress,
      isDisabled: busy,
      height: buttonHeight,
      textStyle: buttonTextStyle,
    );

    Widget scanButton() => CustomButton(
      label: TranslationKeys.printerSearchWifi.tr(context: context),
      onPressed: busy ? null : onScan,
      isLoading: scanning,
      isDisabled: busy,
      height: buttonHeight,
      textStyle: buttonTextStyle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.printerManualConnect.tr(context: context),
          style: AppTextStyle.semibold16(context, color: StaticColors.black),
        ),
        const SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          onChanged: onManualChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          inputFormatter: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z.:\-]')),
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
          connectButton(),
          const SizedBox(height: 10),
          scanButton(),
        ] else
          Row(
            children: [
              Expanded(child: connectButton()),
              SizedBox(width: context.wOf(12, aw).clamp(10.0, 12.0)),
              Expanded(child: scanButton()),
            ],
          ),
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
    required this.selectedHost,
    required this.connectingHost,
    required this.onTap,
  });

  final List<String> found;
  final bool scanning;
  final String? selectedHost;
  final String? connectingHost;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedHost?.trim();
    if (found.isEmpty && !scanning) {
      if (selected != null && selected.isNotEmpty) {
        return _NetworkCard(
          ip: selected,
          selected: true,
          connecting: false,
          onTap: () => onTap(selected),
        );
      }
      return const SizedBox.shrink();
    }
    if (scanning && found.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StaticColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StaticColors.cE2E2E2),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                TranslationKeys.printerSearchingNetwork.tr(
                  context: context,
                  namedArgs: {'port': '${ReceiptPrinterService.defaultRawPort}'},
                ),
                style: AppTextStyle.regular14(context, color: StaticColors.c666666),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final ip in found)
          _NetworkCard(
            ip: ip,
            selected: selected == ip,
            connecting: connectingHost == ip,
            onTap: connectingHost == null ? () => onTap(ip) : null,
          ),
      ],
    );
  }
}

class ReceiptPrinterWifiHeaderSection extends StatelessWidget {
  const ReceiptPrinterWifiHeaderSection({
    super.key,
    required this.networkCount,
  });

  final int networkCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WiFi', style: AppTextStyle.semibold24(context, color: StaticColors.black)),
              const SizedBox(height: 2),
              Text(
                TranslationKeys.printerNetworkCount.tr(
                  context: context,
                  namedArgs: {'count': '$networkCount'},
                ),
                style: AppTextStyle.regular14(context, color: StaticColors.c666666),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({
    required this.ip,
    required this.selected,
    required this.connecting,
    required this.onTap,
  });

  final String ip;
  final bool selected;
  final bool connecting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: selected
            ? const LinearGradient(
                colors: [StaticColors.primary, Color(0xFF32BC66)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : StaticColors.white,
        border: selected ? null : Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.semibold18(
                          context,
                          color: selected ? StaticColors.white : StaticColors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        connecting
                            ? TranslationKeys.printerCheckingHost.tr(
                                context: context,
                                namedArgs: {'host': ip},
                              )
                            : selected
                            ? TranslationKeys.printerConnected.tr(context: context)
                            : TranslationKeys.printerPort.tr(
                                context: context,
                                namedArgs: {
                                  'port': '${ReceiptPrinterService.defaultRawPort}',
                                },
                              ),
                        style: AppTextStyle.regular12(
                          context,
                          color: selected
                              ? StaticColors.white.withValues(alpha: 0.9)
                              : StaticColors.c666666,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: connecting
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(StaticColors.white),
                          ),
                        )
                      : Icon(
                          selected ? Icons.check_rounded : Icons.wifi_rounded,
                          key: ValueKey(selected ? 'check' : 'wifi'),
                          color: selected ? StaticColors.white : StaticColors.primary,
                          size: 24,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
