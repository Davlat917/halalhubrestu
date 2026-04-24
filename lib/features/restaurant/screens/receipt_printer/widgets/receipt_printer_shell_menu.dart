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
      stream: service.watchSavedHost(),
      initialData: service.savedHost,
      builder: (context, snap) {
        final host = snap.data;
        final connected = host != null && host.isNotEmpty;
        return PopupMenuButton<String>(
          tooltip: TranslationKeys.printerTooltip.tr(context: context),
          padding: EdgeInsets.zero,
          offset: const Offset(0, 40),
          onSelected: (action) async {
            if (action == 'settings') {
              await context.router.push(const ReceiptPrinterSettingsRoute());
            } else if (action == 'disconnect') {
              await service.clearSavedPrinter();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              value: '_',
              child: Text(
                connected
                    ? TranslationKeys.printerStatusConnectedHost.tr(
                        context: context,
                        namedArgs: {'host': host},
                      )
                    : TranslationKeys.printerDisconnected.tr(context: context),
                style: const TextStyle(
                  fontSize: 13,
                  color: StaticColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'settings',
              child: Text(
                TranslationKeys.printerMenuSettings.tr(context: context),
              ),
            ),
            if (connected)
              PopupMenuItem(
                value: 'disconnect',
                child: Text(
                  TranslationKeys.printerMenuDisconnect.tr(context: context),
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.print_outlined,
                      size: iconSize,
                      color: StaticColors.c666666,
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connected
                              ? StaticColors.primary
                              : StaticColors.cE2E2E2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StaticColors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showStatusLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    connected
                        ? TranslationKeys.printerConnected.tr(context: context)
                        : TranslationKeys.printerDisconnected.tr(
                            context: context,
                          ),
                    style: TextStyle(
                      fontSize: 12,
                      color: connected
                          ? StaticColors.primary
                          : StaticColors.c666666,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
