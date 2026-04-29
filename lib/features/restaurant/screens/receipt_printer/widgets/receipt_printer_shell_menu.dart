import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/vendor_pos_providers_response.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Restaurant logosi yonida: printer holati va sozlamalar menyusi.
class ReceiptPrinterShellMenu extends StatefulWidget {
  const ReceiptPrinterShellMenu({super.key, this.iconSize = 22, this.showStatusLabel = false});

  final double iconSize;
  final bool showStatusLabel;

  @override
  State<ReceiptPrinterShellMenu> createState() => _ReceiptPrinterShellMenuState();
}

class _ReceiptPrinterShellMenuState extends State<ReceiptPrinterShellMenu> {
  late final VendorPosProvidersBloc _providersBloc = getIt<VendorPosProvidersBloc>();
  bool _isProcessingSelection = false;

  void _setProcessing(bool value) {
    if (!mounted) return;
    setState(() => _isProcessingSelection = value);
  }

  @override
  void initState() {
    super.initState();
    _providersBloc.add(const VendorPosProvidersRequested());
  }

  @override
  void dispose() {
    _providersBloc.close();
    super.dispose();
  }

  List<VendorPosProviderItem> _fallbackProviders(BuildContext context) {
    return [
      VendorPosProviderItem(
        provider: 'tablet',
        label: TranslationKeys.printerOptionTablet.tr(context: context),
        connected: true,
        active: false,
        missingFields: const [],
      ),
      VendorPosProviderItem(
        provider: 'clover',
        label: TranslationKeys.printerOptionClover.tr(context: context),
        connected: true,
        active: false,
        missingFields: const [],
      ),
    ];
  }

  List<VendorPosProviderItem> _menuProviders(BuildContext context, VendorPosProvidersState providersState) {
    final data = providersState.data;
    if (data != null && data.providers.isNotEmpty) return data.providers;
    return _fallbackProviders(context);
  }

  VendorPosProviderItem? _findProvider(List<VendorPosProviderItem> list, String id) {
    final key = id.trim().toLowerCase();
    for (final p in list) {
      if (p.providerId == key) return p;
    }
    return null;
  }

  String _displayLabel(BuildContext context, VendorPosProviderItem? item, String providerId) {
    if (item != null && item.label.trim().isNotEmpty) return item.label.trim();
    if (providerId == 'clover') {
      return TranslationKeys.printerOptionClover.tr(context: context);
    }
    if (providerId == 'tablet') {
      return TranslationKeys.printerOptionTablet.tr(context: context);
    }
    return providerId.isEmpty ? '—' : providerId;
  }

  Future<void> _onProviderChosen(BuildContext context, ReceiptPrinterService service, int vendorId, String providerId, String displayLabel) async {
    if (_isProcessingSelection) return;
    final id = providerId.trim().toLowerCase();
    if (id == 'rezku') {
      getIt<Display>().info(TranslationKeys.comingSoonWithLabel.tr(context: context, namedArgs: {'label': displayLabel}));
      return;
    }

    if (vendorId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationKeys.printerVendorNotFound.tr(context: context))),
      );
      return;
    }
    _setProcessing(true);
    try {
      _providersBloc.add(VendorPosProviderSelected(vendorId: vendorId, provider: id));
      final result = await _providersBloc.stream.firstWhere((s) => !s.isSubmitting);
      if (!context.mounted) return;
      if (result.status == VendorPosProvidersLoadStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ??
                  TranslationKeys.printerSelectProviderFailed.tr(context: context),
            ),
          ),
        );
        return;
      }

      if (id == 'clover') {
        await service.clearSavedPrinter();
      }

      await service.setSelectedPrinterType(id);
      if (!context.mounted) return;

      if (id == 'clover') {
        try {
          final oauth = await getIt<VendorPosProvidersRepository>().connectClover(vendorId: vendorId);
          if (!context.mounted) return;
          final url = oauth.authorizeUrl.trim();
          if (url.isEmpty) {
            getIt<Display>().error(TranslationKeys.printerCloverConnectFailed.tr(context: context));
            return;
          }
          final uri = Uri.tryParse(url);
          if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
            getIt<Display>().error(TranslationKeys.printerCloverConnectFailed.tr(context: context));
            return;
          }
          final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!context.mounted) return;
          if (!opened) {
            getIt<Display>().error(TranslationKeys.printerCloverOpenBrowserFailed.tr(context: context));
          }
        } catch (e) {
          if (!context.mounted) return;
          getIt<Display>().error(TranslationKeys.printerCloverConnectFailed.tr(context: context));
        }
        return;
      }

      if (id == 'tablet') {
        final connected = await context.router.push(const ReceiptPrinterSettingsRoute());
        if (!context.mounted) return;
        if (connected == true) {
          getIt<Display>().success(
            TranslationKeys.printerConnected.tr(context: context),
          );
        }
      }
    } finally {
      _setProcessing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = getIt<ReceiptPrinterService>();
    return BlocProvider<VendorPosProvidersBloc>.value(
      value: _providersBloc,
      child: StreamBuilder<String?>(
        stream: service.watchSelectedPrinterType(),
        initialData: service.selectedPrinterType,
        builder: (context, typeSnap) {
          return BlocBuilder<VendorPosProvidersBloc, VendorPosProvidersState>(
            builder: (context, providersState) {
              final activeProvider = providersState.data?.activeProvider.trim().toLowerCase();
              final selectedType = (activeProvider != null && activeProvider.isNotEmpty) ? activeProvider : (typeSnap.data ?? 'tablet').toLowerCase();
              final menuList = _menuProviders(context, providersState);
              final selectedItem = _findProvider(menuList, selectedType);
              final selectedLabel = _displayLabel(context, selectedItem, selectedType);
              final resolvedIconSize = widget.iconSize.clamp(14.0, 18.0).toDouble();
              final selectedIcon = _providerIconWidget(selectedType, selected: true, size: resolvedIconSize);
              final isExternal = selectedType != 'tablet';

              return IgnorePointer(
                ignoring: _isProcessingSelection,
                child: PopupMenuButton<String>(
                  tooltip: TranslationKeys.printerTooltip.tr(context: context),
                  color: StaticColors.white,
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (action) async {
                    if (_isProcessingSelection) return;
                    if (action == 'disconnect') {
                      await service.clearSavedPrinter();
                      await service.setSelectedPrinterType('tablet');
                      return;
                    }
                    final vendorId = providersState.data?.vendorId ?? 0;
                    final item = _findProvider(menuList, action);
                    final label = _displayLabel(context, item, action);
                    await _onProviderChosen(context, service, vendorId, action, label);
                  },
                  itemBuilder: (ctx) {
                  final items = <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      enabled: false,
                      height: 42,
                      value: '_current',
                      child: _PrinterMenuRow(icon: _providerIconWidget(selectedType, selected: true, size: 20), title: selectedLabel, selected: true),
                    ),
                  ];
                  for (final p in menuList) {
                    final id = p.providerId;
                    final label = _displayLabel(context, p, id);
                    final rowSelected = id == selectedType;
                    final enabled = id.isNotEmpty;
                    items.add(
                      PopupMenuItem<String>(
                        value: id,
                        enabled: enabled,
                        height: 42,
                        child: _PrinterMenuRow(
                          icon: _providerIconWidget(id, selected: rowSelected, size: 20),
                          title: label,
                          selected: rowSelected,
                        ),
                      ),
                    );
                  }
                  if (isExternal) {
                    items.add(const PopupMenuDivider());
                    items.add(
                      PopupMenuItem<String>(
                        value: 'disconnect',
                        child: Text(TranslationKeys.printerMenuDisconnect.tr(context: context)),
                      ),
                    );
                  }
                  return items;
                },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showStatusLabel) ...[
                        Text(
                          TranslationKeys.printerSendOrdersTo.tr(context: context),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: StaticColors.black),
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
                            selectedIcon,
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                selectedLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: StaticColors.black),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _isProcessingSelection
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: StaticColors.black,
                                    ),
                                  )
                                : const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: StaticColors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _providerIconWidget(String providerId, {required bool selected, required double size}) {
  switch (providerId.trim().toLowerCase()) {
    case 'tablet':
      return Icon(Icons.tablet_mac_rounded, size: size, color: selected ? StaticColors.black : StaticColors.c666666);
    case 'clover':
      return Assets.icons.cloverIcon.svg(height: size, width: size);
    case 'rezku':
      return Assets.icons.rezkuIcon.svg(height: size, width: size);
    default:
      return Icon(Icons.point_of_sale_rounded, size: size, color: selected ? StaticColors.black : StaticColors.c666666);
  }
}

class _PrinterMenuRow extends StatelessWidget {
  const _PrinterMenuRow({required this.icon, required this.title, this.selected = false});

  final Widget icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? StaticColors.black : StaticColors.c666666),
          ),
        ),
      ],
    );
  }
}
