import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// EPSON termal printerlar WiFi orqali odatda **RAW port 9100** da qabul qiladi (ESC/POS).
@lazySingleton
class ReceiptPrinterService {
  ReceiptPrinterService(this._storage, this._dio, this._logger);

  final Storage _storage;
  final Dio _dio;
  final Logger _logger;

  void _logDebug(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, stackTrace: stackTrace);
  }

  void _logInfo(String message) {
    if (kDebugMode) _logger.i(message);
  }

  void _logWarn(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, stackTrace: stackTrace);
  }

  static const int defaultRawPort = 9100;

  /// Bir vaqtda bitta ulanish — ovoz + WS yoki ketma-ket zakazlar bir-birini bloklamasin.
  Future<void> _printQueue = Future.value();
  _ReceiptVendorHeader? _cachedHeader;
  DateTime? _cachedHeaderAt;
  static const Duration _headerTtl = Duration(minutes: 5);

  String? get savedHost => _storage.receiptPrinterHost.call();

  Stream<String?> watchSavedHost() => _storage.receiptPrinterHost.watch();

  String get selectedPrinterType {
    final type = _storage.receiptPrinterType.call()?.trim().toLowerCase();
    if (type != null && type.isNotEmpty) return type;
    // Backward compatibility: eski buildlarda host bo'lsa Clover deb ko'rsatamiz.
    final host = savedHost?.trim();
    return (host != null && host.isNotEmpty) ? 'clover' : 'tablet';
  }

  Stream<String?> watchSelectedPrinterType() => _storage.receiptPrinterType.watch();

  Future<void> setSelectedPrinterType(String type) async {
    final normalized = type.trim().toLowerCase();
    if (normalized.isEmpty) return;
    await _storage.receiptPrinterType.set(normalized);
  }

  Future<void> savePrinterHost(String host) async {
    final trimmed = host.trim();
    if (trimmed.isEmpty) return;
    await _storage.receiptPrinterHost.set(trimmed);
  }

  Future<void> clearSavedPrinter() => _storage.receiptPrinterHost.delete();

  /// RAW TCP ulanishini tekshiradi (printer ESC/POS qabul qiladigan kanal).
  Future<bool> probeHost(
    String host, {
    int port = defaultRawPort,
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    final h = host.trim();
    if (h.isEmpty) return false;
    Socket? socket;
    try {
      socket = await Socket.connect(h, port, timeout: timeout);
      return true;
    } catch (e, st) {
      _logDebug(
        'Receipt printer probe failed for $h:$port — $e',
        stackTrace: st,
      );
      return false;
    } finally {
      try {
        await socket?.close();
      } catch (_) {}
    }
  }

  /// Qurilmaning lokal IPv4 manzili (subnet skaner uchun). `dart:io`, qo‘shimcha plugin yo‘q.
  Future<String?> currentWifiIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      String? fallback;
      for (final ni in interfaces) {
        final name = ni.name.toLowerCase();
        final wifiLike =
            name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('wl') ||
            name == 'en0' ||
            name.contains('p2p');
        for (final addr in ni.addresses) {
          if (addr.isLoopback) continue;
          final ip = addr.address;
          if (ip.isEmpty || ip == '0.0.0.0') continue;
          if (ip.startsWith('169.254.')) continue;
          if (wifiLike) return ip;
          fallback ??= ip;
        }
      }
      return fallback;
    } catch (e, st) {
      _logWarn('Lokal IPv4 olishda xato: $e', stackTrace: st);
      return null;
    }
  }

  List<String> _hostsInSameSubnet(String deviceIp) {
    final parts = deviceIp.split('.');
    if (parts.length != 4) return const [];
    final a = parts[0];
    final b = parts[1];
    final c = parts[2];
    return List.generate(254, (i) => '$a.$b.$c.${i + 1}');
  }

  /// Tarmoqda port 9100 ochiq bo‘lgan qurilmalarni qidiradi (parallel partiyalar).
  Future<List<String>> discoverRawPrinters({
    int port = defaultRawPort,
    Duration perHostTimeout = const Duration(milliseconds: 650),
    int batchSize = 36,
  }) async {
    final wifiIp = await currentWifiIpv4();
    if (wifiIp == null) {
      _logInfo(
        'Receipt printer discover: WiFi IP topilmadi (simulator yoki ruxsat).',
      );
      return const [];
    }
    final hosts = _hostsInSameSubnet(wifiIp);
    final found = <String>[];

    for (var i = 0; i < hosts.length; i += batchSize) {
      final slice = hosts.sublist(
        i,
        i + batchSize > hosts.length ? hosts.length : i + batchSize,
      );
      final results = await Future.wait(
        slice.map((h) async {
          final ok = await probeHost(h, port: port, timeout: perHostTimeout);
          return ok ? h : null;
        }),
      );
      found.addAll(results.whereType<String>());
    }

    found.sort();
    return found;
  }

  Future<void> _ensureVendorHeaderLoaded({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final ts = _cachedHeaderAt;
    if (!forceRefresh &&
        _cachedHeader != null &&
        ts != null &&
        now.difference(ts) < _headerTtl) {
      return;
    }
    try {
      final r = await _dio.get(Constants.vendorsMe);
      final data = r.data;
      if (data is! Map<String, dynamic>) return;
      _cachedHeader = _ReceiptVendorHeader(
        name: data['name']?.toString().trim(),
        address: data['address']?.toString().trim(),
        phone: (data['phone_number1'] ?? data['phone'] ?? data['phone_number2'])
            ?.toString()
            .trim(),
      );
      _cachedHeaderAt = now;
    } catch (e, st) {
      _logDebug('Vendor header olishda xato: $e', stackTrace: st);
    }
  }

  /// WebSocket `order_created` xabari uchun qisqa chek (printer sozlangan bo‘lsa).
  Future<bool> printNewOrderReceiptFromWs(Map<String, dynamic> raw) async {
    final h = savedHost?.trim();
    if (h == null || h.isEmpty) return false;
    try {
      // Always refresh before printing a new order so renamed restaurant
      // headers are reflected immediately on receipts.
      await _ensureVendorHeaderLoaded(forceRefresh: true);
      final enriched = await _enrichOrderPayload(raw);
      final data = _buildNewOrderEscPosPayload(enriched);
      final ok = await _sendEscPos(data, host: h);
      if (ok) _logInfo('Yangi zakaz cheki yuborildi: $h');
      return ok;
    } catch (e, st) {
      _logWarn('Zakaz cheki chop etishda xato: $e', stackTrace: st);
      return false;
    }
  }

  Future<Map<String, dynamic>> _enrichOrderPayload(
    Map<String, dynamic> raw,
  ) async {
    final merged = Map<String, dynamic>.from(raw);
    try {
      final response = await _dio.get(Constants.vendorsOrders);
      final data = response.data;
      if (data is! Map<String, dynamic>) return merged;
      final results = data['results'];
      if (results is! List) return merged;
      final orderId = _scalarString(raw, const ['order_id', 'orderId', 'id']);
      final orderNo = _scalarString(raw, const [
        'order_number',
        'orderNumber',
        'number',
      ]);
      Map<String, dynamic>? matched;
      for (final row in results) {
        if (row is! Map) continue;
        final item = Map<String, dynamic>.from(row);
        final rowId = (item['id'] ?? item['order_id'])?.toString().trim();
        final rowNo = item['order_number']?.toString().trim();
        if (orderId != null && rowId == orderId) {
          matched = item;
          break;
        }
        if (orderNo != null && rowNo == orderNo) {
          matched = item;
          break;
        }
      }
      if (matched != null) {
        merged.addAll(matched);
      }
    } catch (e, st) {
      _logDebug('Order payload enrich xato: $e', stackTrace: st);
    }
    return merged;
  }

  /// Test uchun qisqa chek (ESC/POS, CP437/Latin1 xavfsiz matn).
  ///
  /// [host] berilmasa [savedHost] ishlatiladi.
  Future<bool> printTestReceipt({
    String? host,
    int port = defaultRawPort,
  }) async {
    final h = (host ?? savedHost)?.trim();
    if (h == null || h.isEmpty) {
      _logWarn('printTestReceipt: printer host yo‘q');
      return false;
    }
    try {
      final data = _buildTestEscPosPayload(h, port);
      final ok = await _sendEscPos(data, host: h, port: port);
      if (ok) _logInfo('Test chek yuborildi: $h:$port');
      return ok;
    } catch (e, st) {
      _logWarn('Test chek chop etishda xato: $e', stackTrace: st);
      return false;
    }
  }

  Future<bool> _sendEscPos(
    Uint8List data, {
    required String host,
    int port = defaultRawPort,
  }) {
    final done = Completer<bool>();
    _printQueue = _printQueue.then((_) async {
      try {
        final ok = await _sendEscPosWithRetries(data, host: host, port: port);
        if (!done.isCompleted) done.complete(ok);
      } catch (e, st) {
        _logWarn('ESC/POS yuborishda xato: $e', stackTrace: st);
        if (!done.isCompleted) done.complete(false);
      }
    });
    return done.future;
  }

  static const int _connectAttempts = 3;
  static const Duration _connectTimeout = Duration(seconds: 15);

  Future<bool> _sendEscPosWithRetries(
    Uint8List data, {
    required String host,
    int port = defaultRawPort,
  }) async {
    for (var attempt = 0; attempt < _connectAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 350 * attempt));
      }
      final ok = await _sendEscPosOnce(
        data,
        host: host,
        port: port,
        timeout: _connectTimeout,
      );
      if (ok) return true;
      _logDebug(
        'Printer ulanmadi (${attempt + 1}/$_connectAttempts): $host:$port',
      );
    }
    _logWarn(
      'ESC/POS: $_connectAttempts marta urinishdan keyin muvaffaqiyatsiz — $host:$port '
      '(WiFi, printer yoqilishi, AP client isolation yoki boshqa portni tekshiring).',
    );
    return false;
  }

  Future<bool> _sendEscPosOnce(
    Uint8List data, {
    required String host,
    int port = defaultRawPort,
    required Duration timeout,
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      socket.add(data);
      await socket.flush();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await socket.close();
      socket = null;
      return true;
    } catch (e, st) {
      _logDebug('ESC/POS bir martalik xato: $e', stackTrace: st);
      try {
        socket?.destroy();
      } catch (_) {}
      return false;
    }
  }

  void _appendLatin1Line(BytesBuilder b, String s) {
    final safe = String.fromCharCodes(s.runes.map((r) => r <= 0xFF ? r : 0x3F));
    b.add(latin1.encode('$safe\n'));
  }

  String? _scalarString(Map<String, dynamic> raw, List<String> keys) {
    for (final k in keys) {
      if (!raw.containsKey(k)) continue;
      final v = raw[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  Uint8List _buildNewOrderEscPosPayload(Map<String, dynamic> raw) {
    final b = BytesBuilder(copy: false);
    void line(String s) => _appendLatin1Line(b, s);
    List<String> wrapWords(String text, int maxWidth) {
      final src = text.trim();
      if (src.isEmpty) return const [''];
      final words = src.split(RegExp(r'\s+'));
      final out = <String>[];
      var current = '';
      for (final w in words) {
        if (w.length > maxWidth) {
          if (current.isNotEmpty) {
            out.add(current);
            current = '';
          }
          for (var i = 0; i < w.length; i += maxWidth) {
            final end = (i + maxWidth > w.length) ? w.length : i + maxWidth;
            out.add(w.substring(i, end));
          }
          continue;
        }
        final next = current.isEmpty ? w : '$current $w';
        if (next.length <= maxWidth) {
          current = next;
        } else {
          out.add(current);
          current = w;
        }
      }
      if (current.isNotEmpty) out.add(current);
      return out;
    }

    void pairRow(
      String left,
      String right, {
      bool addGap = false,
      bool bold = false,
    }) {
      const totalWidth = 32;
      final r0 = right.trim();
      final r = r0.length > 12 ? r0.substring(r0.length - 12) : r0;
      if (r.isEmpty) {
        for (final l in wrapWords(left, totalWidth)) {
          line(l);
        }
        if (addGap) line('');
        return;
      }
      final rightWidth = r.length < 6 ? 6 : r.length;
      final leftWidth = totalWidth - rightWidth - 1;
      final leftLines = wrapWords(left, leftWidth);
      if (bold) b.add(const [0x1B, 0x45, 0x01]);
      final firstLeft = leftLines.first;
      final spaces = totalWidth - firstLeft.length - r.length;
      line('$firstLeft${' ' * (spaces > 1 ? spaces : 1)}$r');
      for (final l in leftLines.skip(1)) {
        line(l);
      }
      if (bold) b.add(const [0x1B, 0x45, 0x00]);
      if (addGap) line('');
    }

    b.add(const [0x1B, 0x40]); // init
    b.add(const [0x1B, 0x61, 0x01]); // center

    final header = _cachedHeader ?? const _ReceiptVendorHeader();
    final brand = (header.name?.trim().isNotEmpty ?? false)
        ? header.name!.trim()
        : 'HalalHub';

    b.add(const [0x1B, 0x45, 0x01]); // bold on
    b.add(const [0x1D, 0x21, 0x11]); // 2x size
    line(brand);
    b.add(const [0x1D, 0x21, 0x00]); // normal size
    b.add(const [0x1B, 0x45, 0x00]); // bold off

    if (header.address != null && header.address!.isNotEmpty) {
      line(header.address!);
    }
    if (header.phone != null && header.phone!.isNotEmpty) {
      line(header.phone!);
    }
    line(DateTime.now().toLocal().toString().split('.').first);
    line('');
    line('');
    b.add(const [0x1B, 0x61, 0x00]); // left

    final orderNo = _scalarString(raw, const [
      'order_number',
      'orderNumber',
      'number',
    ]);
    final oid = _scalarString(raw, const ['order_id', 'orderId', 'id']);
    b.add(const [0x1B, 0x61, 0x01]); // center
    b.add(const [0x1B, 0x45, 0x01]); // bold on
    b.add(const [0x1D, 0x21, 0x11]); // 2x size
    if (orderNo != null) {
      line('#$orderNo');
    } else if (oid != null) {
      line('#ORD-$oid');
    }
    b.add(const [0x1D, 0x21, 0x00]); // normal size
    b.add(const [0x1B, 0x45, 0x00]); // bold off
    b.add(const [0x1B, 0x61, 0x00]); // left
    line('');
    line('');

    final orderType =
        _scalarString(raw, const ['order_type', 'orderType']) ?? 'pickup';
    final paymentType =
        _scalarString(raw, const [
          'payment_type',
          'paymentType',
          'payment_method',
        ]) ??
        'card';
    final normalizedOrderType = orderType.trim().toLowerCase();
    final isDeliveryOrder =
        normalizedOrderType == 'delivery' ||
        normalizedOrderType == 'driver' ||
        normalizedOrderType == 'courier';
    pairRow('Order type:', orderType);
    pairRow('Payment type:', paymentType);
    line('-' * 32);
    line('');

    final items = _extractReceiptItems(raw);
    if (items.isNotEmpty) {
      for (final item in items) {
        pairRow('${item.qty}x ${item.name}', item.price);
      }
    } else {
      final ordersSummary = _scalarString(raw, const [
        'orders',
        'items_summary',
      ]);
      if (ordersSummary != null) {
        pairRow(ordersSummary, '');
      }
      final msg = _scalarString(raw, const ['message', 'title', 'body']);
      if (msg != null) pairRow(msg, '');
      if (ordersSummary == null && msg == null) {
        line('Items ma\'lumoti kelmadi');
      }
    }

    line('-' * 32);
    line('');
    final itemTotal = _money(raw, const [
      'item_total_price',
      'subtotal',
      'items_total',
      'items_total_price',
    ]);
    final delivery = _money(raw, const ['delivery_price', 'delivery_fee']);
    final promotion = _money(raw, const ['promotion', 'discount']);
    final service = _money(raw, const ['service_fee', 'commission_fee']);
    final tax = _money(raw, const ['tax']);
    final tip = _money(raw, const ['tip']);
    final originalTotal = _money(raw, const ['original_total_price']);
    final total = _money(raw, const ['total_price', 'total']);
    if (itemTotal != null) pairRow('Item total price:', itemTotal);
    if (isDeliveryOrder) {
      pairRow('Delivery fee:', delivery ?? '\$0');
    }
    if (promotion != null) pairRow('Promotion:', promotion);
    if (service != null) pairRow('Service fee:', service);
    if (tax != null) pairRow('Tax:', tax);
    if (tip != null) pairRow('Tip:', tip);
    if (originalTotal != null) {
      pairRow('Original total:', originalTotal);
    }
    if (total != null) pairRow('TOTAL:', total, bold: true);
    if (!_hasAnyTotals(raw)) {
      line('Total ma\'lumotlari kelmadi');
    }

    line('');
    line('');
    b.add(const [0x1B, 0x61, 0x01]); // center
    line('--- THANK YOU ---');
    b.add(const [0x0A, 0x0A, 0x0A, 0x0A]);
    b.add(const [0x1D, 0x56, 0x00]);
    return b.takeBytes();
  }

  String? _money(Map<String, dynamic> raw, List<String> keys) {
    final value =
        _scalarString(raw, keys) ??
        _scalarString(
          _nestedMap(raw, 'price_data') ?? const <String, dynamic>{},
          keys,
        );
    if (value == null) return null;
    if (value.contains('\$')) return value;
    return '\$$value';
  }

  bool _hasAnyTotals(Map<String, dynamic> raw) {
    return _money(raw, const [
              'item_total_price',
              'subtotal',
              'items_total',
              'items_total_price',
            ]) !=
            null ||
        _money(raw, const ['delivery_price', 'delivery_fee']) != null ||
        _money(raw, const ['service_fee', 'commission_fee']) != null ||
        _money(raw, const ['total_price', 'total']) != null;
  }

  List<_ReceiptLineItem> _extractReceiptItems(Map<String, dynamic> raw) {
    final direct = raw['items'];
    if (direct is List) return _mapLineItems(direct);
    final order = raw['order'];
    if (order is Map<String, dynamic>) {
      final nested = order['items'];
      if (nested is List) return _mapLineItems(nested);
    }
    return const <_ReceiptLineItem>[];
  }

  Map<String, dynamic>? _nestedMap(Map<String, dynamic> raw, String key) {
    final v = raw[key];
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<_ReceiptLineItem> _mapLineItems(List<dynamic> source) {
    final out = <_ReceiptLineItem>[];
    for (final e in source) {
      if (e is! Map) continue;
      final m = e.cast<dynamic, dynamic>();
      final name =
          (m['name'] ?? m['title'] ?? m['product_name'] ?? m['product'] ?? '')
              .toString()
              .trim();
      if (name.isEmpty) continue;
      final qty = (m['quantity'] ?? m['qty'] ?? 1).toString().trim();
      final unitPriceRaw = (m['price'] ?? m['unit_price'] ?? '')
          .toString()
          .trim();
      final totalPriceRaw = (m['total_price'] ?? m['line_total'] ?? '')
          .toString()
          .trim();
      final effectiveRaw = totalPriceRaw.isNotEmpty
          ? totalPriceRaw
          : (unitPriceRaw.isNotEmpty ? unitPriceRaw : '');
      final price = effectiveRaw.isEmpty
          ? ''
          : (effectiveRaw.contains('\$') ? effectiveRaw : '\$$effectiveRaw');
      out.add(_ReceiptLineItem(name: name, qty: qty, price: price));
    }
    return out;
  }

  /// ESC/POS: init, markaz, qalin sarlavha, sana, bo‘shliq, kesish.
  Uint8List _buildTestEscPosPayload(String printerHost, int port) {
    final b = BytesBuilder(copy: false);
    void line(String s) => _appendLatin1Line(b, s);

    b.add(const [0x1B, 0x40]); // ESC @ init
    b.add(const [0x1B, 0x61, 0x01]); // markazga
    b.add(const [0x1B, 0x45, 0x01]); // bold on
    line('HALALHUB RESTAURANT');
    b.add(const [0x1B, 0x45, 0x00]); // bold off
    b.add(const [0x1D, 0x21, 0x11]); // 2x o‘lcham
    line('TEST CHEK');
    b.add(const [0x1D, 0x21, 0x00]); // normal
    b.add(const [0x1B, 0x61, 0x00]); // chapga
    line('-' * 32);
    line('Vaqt: ${DateTime.now().toLocal().toString().split('.').first}');
    line('Printer IP: $printerHost');
    line('Port: $port');
    line('');
    line('OK - test muvaffaqiyatli');
    b.add(const [0x0A, 0x0A, 0x0A, 0x0A]);
    b.add(const [0x1D, 0x56, 0x00]);
    return b.takeBytes();
  }
}

class _ReceiptLineItem {
  const _ReceiptLineItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  final String name;
  final String qty;
  final String price;
}

class _ReceiptVendorHeader {
  const _ReceiptVendorHeader({this.name, this.address, this.phone});

  final String? name;
  final String? address;
  final String? phone;
}
