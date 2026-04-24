import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

/// Restaurant logosi yonida: printer holati va sozlamalar menyusi.
class ReceiptPrinterShellMenu extends StatelessWidget {
  const ReceiptPrinterShellMenu({
    super.key,
    this.iconSize = 22,
    this.showStatusLabel = false,
  });

  final double iconSize;
  final bool showStatusLabel;

  @override
  Widget build(BuildContext context) {
    final service = getIt<ReceiptPrinterService>();
    return StreamBuilder<String?>(
      stream: service.watchSelectedPrinterType(),
      initialData: service.selectedPrinterType,
      builder: (context, typeSnap) {
        final selectedType = (typeSnap.data ?? 'tablet').toLowerCase();
        final selectedLabel = selectedType == 'clover'
            ? TranslationKeys.printerOptionClover.tr(context: context)
            : TranslationKeys.printerOptionTablet.tr(context: context);
        final isCloverSelected = selectedType == 'clover';
        final selectedIcon = isCloverSelected
            ? Icons.energy_savings_leaf_rounded
            : Icons.tablet_mac_rounded;
        final resolvedIconSize = iconSize.clamp(14.0, 18.0).toDouble();
        return PopupMenuButton<String>(
          tooltip: TranslationKeys.printerTooltip.tr(context: context),
          color: StaticColors.white,
          padding: EdgeInsets.zero,
          offset: const Offset(0, 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (action) async {
            if (action == 'clover') {
              await service.setSelectedPrinterType('clover');
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: StaticColors.white,
                  title: Text(TranslationKeys.comingSoon.tr(context: ctx)),
                  content: Text(
                    TranslationKeys.printerCloverComingSoonMessage.tr(
                      context: ctx,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(TranslationKeys.commonOk.tr(context: ctx)),
                    ),
                  ],
                ),
              );
            } else if (action == 'tablet') {
              await service.setSelectedPrinterType('tablet');
              await context.router.push(const ReceiptPrinterSettingsRoute());
            } else if (action == 'disconnect') {
              await service.clearSavedPrinter();
              await service.setSelectedPrinterType('tablet');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              height: 42,
              value: '_current',
              child: _PrinterMenuRow(
                icon: selectedIcon,
                title: selectedLabel,
                selected: true,
              ),
            ),
            PopupMenuItem(
              value: 'tablet',
              height: 42,
              child: _PrinterMenuRow(
                icon: Icons.tablet_mac_rounded,
                title: TranslationKeys.printerOptionTablet.tr(context: context),
                selected: !isCloverSelected,
              ),
            ),
            PopupMenuItem(
              value: 'clover',
              height: 42,
              child: _PrinterMenuRow(
                icon: Icons.settings_input_component_rounded,
                title: TranslationKeys.printerOptionClover.tr(context: context),
                selected: isCloverSelected,
              ),
            ),
            if (isCloverSelected) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'disconnect',
                child: Text(
                  TranslationKeys.printerMenuDisconnect.tr(context: context),
                ),
              ),
            ],
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showStatusLabel) ...[
                  Text(
                    TranslationKeys.printerSendOrdersTo.tr(context: context),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: StaticColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StaticColors.cE2E2E2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedIcon,
                        size: resolvedIconSize,
                        color: StaticColors.black,
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          selectedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: StaticColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: StaticColors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrinterMenuRow extends StatelessWidget {
  const _PrinterMenuRow({
    required this.icon,
    required this.title,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: selected ? StaticColors.black : StaticColors.c666666,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? StaticColors.black : StaticColors.c666666,
            ),
          ),
        ),
      ],
    );
  }
}
