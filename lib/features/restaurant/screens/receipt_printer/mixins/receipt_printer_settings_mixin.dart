import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

class ReceiptPrinterSettingsVm {
  const ReceiptPrinterSettingsVm({
    this.scanning = false,
    this.printing = false,
    this.found = const [],
    this.wifiIp,
    this.status,
    this.selectedHost,
  });

  final bool scanning;
  final bool printing;
  final List<String> found;
  final String? wifiIp;
  final String? status;
  final String? selectedHost;

  ReceiptPrinterSettingsVm copyWith({
    bool? scanning,
    bool? printing,
    List<String>? found,
    String? wifiIp,
    String? status,
    String? selectedHost,
    bool clearStatus = false,
  }) {
    return ReceiptPrinterSettingsVm(
      scanning: scanning ?? this.scanning,
      printing: printing ?? this.printing,
      found: found ?? this.found,
      wifiIp: wifiIp ?? this.wifiIp,
      status: clearStatus ? null : (status ?? this.status),
      selectedHost: selectedHost ?? this.selectedHost,
    );
  }
}

mixin ReceiptPrinterSettingsMixin<T extends StatefulWidget> on State<T> {
  final manualController = TextEditingController();
  final service = getIt<ReceiptPrinterService>();
  final vm = ValueNotifier<ReceiptPrinterSettingsVm>(
    const ReceiptPrinterSettingsVm(),
  );

  Future<void> initReceiptPrinterSettings() async {
    final saved = service.savedHost;
    if (saved != null && saved.isNotEmpty) {
      manualController.text = saved;
      vm.value = vm.value.copyWith(selectedHost: saved);
    }
    await loadWifiIp();
  }

  Future<void> loadWifiIp() async {
    final ip = await service.currentWifiIpv4();
    if (!mounted) return;
    vm.value = vm.value.copyWith(
      wifiIp: ip,
      status: ip == null
          ? TranslationKeys.printerWifiIpNotDetected.tr(context: context)
          : null,
      clearStatus: ip != null,
    );
  }

  Future<void> onScan() async {
    vm.value = vm.value.copyWith(
      scanning: true,
      found: const [],
      status: TranslationKeys.printerSearchingNetwork.tr(
        context: context,
        namedArgs: {'port': '${ReceiptPrinterService.defaultRawPort}'},
      ),
    );
    try {
      final list = await service.discoverRawPrinters();
      if (!mounted) return;
      vm.value = vm.value.copyWith(
        found: list,
        status: list.isEmpty
            ? TranslationKeys.printerNotFoundHint.tr(context: context)
            : TranslationKeys.printerFoundCount.tr(
                context: context,
                namedArgs: {'count': '${list.length}'},
              ),
      );
    } finally {
      if (mounted) {
        vm.value = vm.value.copyWith(scanning: false);
      }
    }
  }

  Future<bool> connectTo(String host) async {
    vm.value = vm.value.copyWith(
      status: TranslationKeys.printerCheckingHost.tr(
        context: context,
        namedArgs: {'host': host},
      ),
    );
    final ok = await service.probeHost(host);
    if (!mounted) return false;
    if (!ok) {
      vm.value = vm.value.copyWith(
        status: TranslationKeys.printerConnectFailedHost.tr(
          context: context,
          namedArgs: {'host': host},
        ),
      );
      return false;
    }
    await service.savePrinterHost(host);
    if (!mounted) return false;
    manualController.text = host;
    vm.value = vm.value.copyWith(
      status: TranslationKeys.printerConnectedHost.tr(
        context: context,
        namedArgs: {'host': host},
      ),
      selectedHost: host,
    );
    return true;
  }

  void onManualInputChanged(String value) {
    final host = value.trim();
    vm.value = vm.value.copyWith(
      selectedHost: host.isEmpty ? null : host,
      clearStatus: host.isNotEmpty,
    );
  }

  void selectFoundHost(String host) {
    manualController.text = host;
    vm.value = vm.value.copyWith(selectedHost: host, clearStatus: true);
  }

  Future<void> confirmConnectAndFinish(BuildContext context) async {
    final host = (vm.value.selectedHost ?? manualController.text).trim();
    if (host.isEmpty) {
      vm.value = vm.value.copyWith(
        status: TranslationKeys.printerEnterIp.tr(context: context),
      );
      return;
    }
    final ok = await connectTo(host);
    if (!mounted || !ok) return;
    await service.setSelectedPrinterType('tablet');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TranslationKeys.commonSuccessTitle.tr(context: ctx)),
        content: Text(
          TranslationKeys.printerStatusConnectedHost.tr(
            context: ctx,
            namedArgs: {'host': host},
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
    if (!context.mounted) return;
    context.router.maybePop(true);
  }

  Future<void> connectManual() async {
    final host = manualController.text.trim();
    if (host.isEmpty) {
      vm.value = vm.value.copyWith(
        status: TranslationKeys.printerEnterIp.tr(context: context),
      );
      return;
    }
    vm.value = vm.value.copyWith(selectedHost: host);
  }

  Future<void> testPrint() async {
    final saved = service.savedHost?.trim();
    final manual = manualController.text.trim();
    final host = (saved != null && saved.isNotEmpty) ? saved : manual;
    if (host.isEmpty) {
      vm.value = vm.value.copyWith(
        status: TranslationKeys.printerConnectOrEnterIpFirst.tr(
          context: context,
        ),
      );
      return;
    }
    vm.value = vm.value.copyWith(
      printing: true,
      status: TranslationKeys.printerSendingTest.tr(context: context),
    );
    final ok = await service.printTestReceipt(host: host);
    if (!mounted) return;
    vm.value = vm.value.copyWith(
      printing: false,
      status: ok
          ? TranslationKeys.printerTestSent.tr(context: context)
          : TranslationKeys.printerSendFailed.tr(
              context: context,
              namedArgs: {'port': '${ReceiptPrinterService.defaultRawPort}'},
            ),
    );
  }

  Future<void> clearSavedPrinter() async {
    await service.clearSavedPrinter();
    if (!mounted) return;
    vm.value = vm.value.copyWith(
      status: TranslationKeys.printerSavedRemoved.tr(context: context),
    );
  }

  @override
  void dispose() {
    vm.dispose();
    manualController.dispose();
    super.dispose();
  }
}
