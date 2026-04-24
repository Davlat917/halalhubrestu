import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

class ReceiptPrinterSettingsVm {
  const ReceiptPrinterSettingsVm({
    this.scanning = false,
    this.printing = false,
    this.found = const [],
    this.wifiIp,
    this.status,
  });

  final bool scanning;
  final bool printing;
  final List<String> found;
  final String? wifiIp;
  final String? status;

  ReceiptPrinterSettingsVm copyWith({
    bool? scanning,
    bool? printing,
    List<String>? found,
    String? wifiIp,
    String? status,
    bool clearStatus = false,
  }) {
    return ReceiptPrinterSettingsVm(
      scanning: scanning ?? this.scanning,
      printing: printing ?? this.printing,
      found: found ?? this.found,
      wifiIp: wifiIp ?? this.wifiIp,
      status: clearStatus ? null : (status ?? this.status),
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
    }
    await loadWifiIp();
  }

  Future<void> loadWifiIp() async {
    final ip = await service.currentWifiIpv4();
    if (!mounted) return;
    vm.value = vm.value.copyWith(
      wifiIp: ip,
      status: ip == null
          ? 'WiFi manzili aniqlanmadi. Haqiqiy qurilmada tekshiring yoki IPni qo‘lda kiriting.'
          : null,
      clearStatus: ip != null,
    );
  }

  Future<void> onScan() async {
    vm.value = vm.value.copyWith(
      scanning: true,
      found: const [],
      status:
          'Tarmoq qidirilmoqda (port ${ReceiptPrinterService.defaultRawPort})…',
    );
    try {
      final list = await service.discoverRawPrinters();
      if (!mounted) return;
      vm.value = vm.value.copyWith(
        found: list,
        status: list.isEmpty
            ? 'Printer topilmadi. IPni qo‘lda kiriting yoki printer WiFi ga ulanganini tekshiring.'
            : '${list.length} ta qurilma topildi.',
      );
    } finally {
      if (mounted) {
        vm.value = vm.value.copyWith(scanning: false);
      }
    }
  }

  Future<void> connectTo(String host) async {
    vm.value = vm.value.copyWith(status: '$host tekshirilmoqda…');
    final ok = await service.probeHost(host);
    if (!mounted) return;
    if (!ok) {
      vm.value = vm.value.copyWith(status: '$host ga ulanib bo‘lmadi.');
      return;
    }
    await service.savePrinterHost(host);
    if (!mounted) return;
    manualController.text = host;
    vm.value = vm.value.copyWith(status: 'Ulandi: $host');
  }

  Future<void> connectManual() async {
    final host = manualController.text.trim();
    if (host.isEmpty) {
      vm.value = vm.value.copyWith(status: 'IP manzilni kiriting.');
      return;
    }
    await connectTo(host);
  }

  Future<void> testPrint() async {
    final saved = service.savedHost?.trim();
    final manual = manualController.text.trim();
    final host = (saved != null && saved.isNotEmpty) ? saved : manual;
    if (host.isEmpty) {
      vm.value = vm.value.copyWith(
        status: 'Avval printerga ulaning yoki IP maydoniga manzil yozing.',
      );
      return;
    }
    vm.value = vm.value.copyWith(
      printing: true,
      status: 'Test chek yuborilmoqda…',
    );
    final ok = await service.printTestReceipt(host: host);
    if (!mounted) return;
    vm.value = vm.value.copyWith(
      printing: false,
      status: ok
          ? 'Test chek yuborildi. Printerdan chiqishini tekshiring.'
          : 'Yuborishda xato. IP, port (${ReceiptPrinterService.defaultRawPort}) va WiFi ni tekshiring.',
    );
  }

  Future<void> clearSavedPrinter() async {
    await service.clearSavedPrinter();
    if (!mounted) return;
    vm.value = vm.value.copyWith(status: 'Saqlangan printer o‘chirildi.');
  }

  @override
  void dispose() {
    vm.dispose();
    manualController.dispose();
    super.dispose();
  }
}
