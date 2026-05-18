import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:image/image.dart' as img;
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

  Future<void> _printQueue = Future.value();
  _ReceiptVendorHeader? _cachedHeader;
  DateTime? _cachedHeaderAt;
  static const Duration _headerTtl = Duration(minutes: 5);
  Uint8List? _cachedLogoEscPos;
  static const int _logoCacheVersion = 6;
  int? _cachedLogoCacheVersion;
  static const String _logoAssetPath = 'assets/images/logo_image.png';
  static const int _receiptMarginPx = 20;
  /// 80mm termal ~576 dot (203 DPI). 58mm bo'lsa 384 qilib o'zgartiring.
  static const int _printerDotsWidth = 576;
  static const int _dotsPerCharNormal = 12;
  static const int _contentDotsWidth =
      _printerDotsWidth - 2 * _receiptMarginPx;
  static const int _receiptLineWidth = _contentDotsWidth ~/ _dotsPerCharNormal;
  static const int _logoMaxWidthPx = 240;
  static const int _logoCanvasPaddingPx = 28;
  /// Qora card (order ID + ism). Test chek + hot **restart** (reload yetmaydi).
  /// [_orderBarInnerPadChars] — chap/o'ng bo'shliq (0, 1, 2, 3... belgi).
  /// [_orderBarVertPadLines] — yuqori/past qora padding: 0, 0.5, 1, 1.5, 2
  ///   0.5 = yarim balandlik (faqat 2x height, matn 2x2 dan pastroq).
  /// [_orderBarLineSpacingPx] — shu qatorlar orasidagi masofa (dot).
  static const int _orderBarInnerPadChars = 1;
  static const double _orderBarVertPadLines = 1;
  static const int _orderBarLineSpacingPx = 4;
  static const int _sectionGapLines = 1;
  static const int _productsToTotalsGapLines = 3;
  static const int _priceRowGapLines = 1;
  static const int _footerFeedLines = 8;

  // --- Statik mijoz ismi (socket tayyor bo'lguncha) ---
  static const String _staticCustomerName = 'Guest';

  String? get savedHost => _storage.receiptPrinterHost.call();

  Stream<String?> watchSavedHost() => _storage.receiptPrinterHost.watch();

  String get selectedPrinterType {
    final type = _storage.receiptPrinterType.call()?.trim().toLowerCase();
    if (type != null && type.isNotEmpty) return type;
    final host = savedHost?.trim();
    return (host != null && host.isNotEmpty) ? 'clover' : 'tablet';
  }

  Stream<String?> watchSelectedPrinterType() =>
      _storage.receiptPrinterType.watch();

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
      _logDebug('Receipt printer probe failed for $h:$port — $e',
          stackTrace: st);
      return false;
    } finally {
      try {
        await socket?.close();
      } catch (_) {}
    }
  }

  Future<String?> currentWifiIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      String? fallback;
      for (final ni in interfaces) {
        final name = ni.name.toLowerCase();
        final wifiLike = name.contains('wlan') ||
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

  Future<List<String>> discoverRawPrinters({
    int port = defaultRawPort,
    Duration perHostTimeout = const Duration(milliseconds: 650),
    int batchSize = 36,
  }) async {
    final wifiIp = await currentWifiIpv4();
    if (wifiIp == null) {
      _logInfo(
          'Receipt printer discover: WiFi IP topilmadi (simulator yoki ruxsat).');
      return const [];
    }
    final hosts = _hostsInSameSubnet(wifiIp);
    final found = <String>[];

    for (var i = 0; i < hosts.length; i += batchSize) {
      final slice = hosts.sublist(
          i, i + batchSize > hosts.length ? hosts.length : i + batchSize);
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

  Future<bool> printNewOrderReceiptFromWs(Map<String, dynamic> raw) async {
    final h = savedHost?.trim();
    if (h == null || h.isEmpty) return false;
    try {
      await _ensureVendorHeaderLoaded(forceRefresh: true);
      final enriched = await _enrichOrderPayload(raw);
      final data = await _buildNewOrderEscPosPayload(enriched);
      final ok = await _sendEscPos(data, host: h);
      if (ok) _logInfo('Yangi zakaz cheki yuborildi: $h');
      return ok;
    } catch (e, st) {
      _logWarn('Zakaz cheki chop etishda xato: $e', stackTrace: st);
      return false;
    }
  }

  Future<Map<String, dynamic>> _enrichOrderPayload(
      Map<String, dynamic> raw) async {
    final merged = Map<String, dynamic>.from(raw);
    try {
      final response = await _dio.get(Constants.vendorsOrders);
      final data = response.data;
      if (data is! Map<String, dynamic>) return merged;
      final results = data['results'];
      if (results is! List) return merged;
      final orderId =
          _scalarString(raw, const ['order_id', 'orderId', 'id']);
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
      if (matched != null) merged.addAll(matched);
      final detailId = _backendOrderId(merged);
      if (detailId != null) {
        try {
          final detailRes =
              await _dio.get(Constants.vendorsOrderDetailById(detailId));
          final detailData = detailRes.data;
          if (detailData is Map<String, dynamic>) {
            merged.addAll(detailData);
          } else if (detailData is Map) {
            merged.addAll(Map<String, dynamic>.from(detailData));
          }
        } catch (e, st) {
          _logDebug('Order detail enrich xato: $e', stackTrace: st);
        }
      }
    } catch (e, st) {
      _logDebug('Order payload enrich xato: $e', stackTrace: st);
    }
    return merged;
  }

  int? _backendOrderId(Map<String, dynamic> raw) {
    for (final key in const ['id', 'order_id', 'orderId']) {
      if (!raw.containsKey(key)) continue;
      final v = raw[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      final parsed = int.tryParse(v.toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<bool> printTestReceipt({
    String? host,
    int port = defaultRawPort,
  }) async {
    final h = (host ?? savedHost)?.trim();
    if (h == null || h.isEmpty) {
      _logWarn('printTestReceipt: printer host yo\'q');
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

  /// Buyurtma cheki shablonini namuna ma'lumot bilan chop etish (debug / test).
  Future<bool> printSampleOrderReceipt() async {
    final h = savedHost?.trim();
    if (h == null || h.isEmpty) {
      _logWarn('printSampleOrderReceipt: printer host yo\'q');
      return false;
    }
    try {
      await _ensureVendorHeaderLoaded();
      final data = await _buildNewOrderEscPosPayload(_sampleOrderPayloadForTest());
      final ok = await _sendEscPos(data, host: h);
      if (ok) _logInfo('Namuna buyurtma cheki yuborildi: $h');
      return ok;
    } catch (e, st) {
      _logWarn('Namuna chek chop etishda xato: $e', stackTrace: st);
      return false;
    }
  }

  Map<String, dynamic> _sampleOrderPayloadForTest() {
    final now = DateTime.now().toLocal();
    return {
      'type': 'order_created',
      'order_number': 'ORD-TEST4268',
      'order_type': 'delivery',
      'created_at': now.toIso8601String(),
      'customer_name': 'Michelle Taylor',
      'items': [
        {
          'name': 'Big Mac Meal',
          'quantity': 1,
          'price': '7.29',
          'total_price': '7.29',
        },
        {
          'name': 'Large Fries',
          'quantity': 2,
          'price': '2.75',
          'total_price': '5.50',
        },
        {
          'name': 'Coke',
          'quantity': 1,
          'price': '5.50',
          'total_price': '5.50',
        },
      ],
      'price_data': {
        'subtotal': '22.95',
        'tax': '2.05',
        'delivery_price': '0.00',
        'service_fee': '0.00',
        'total_price': '25.00',
      },
    };
  }

  Future<bool> _sendEscPos(
    Uint8List data, {
    required String host,
    int port = defaultRawPort,
  }) {
    final done = Completer<bool>();
    _printQueue = _printQueue.then((_) async {
      try {
        final ok =
            await _sendEscPosWithRetries(data, host: host, port: port);
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
      final ok = await _sendEscPosOnce(data,
          host: host, port: port, timeout: _connectTimeout);
      if (ok) return true;
      _logDebug(
          'Printer ulanmadi (${attempt + 1}/$_connectAttempts): $host:$port');
    }
    _logWarn(
      'ESC/POS: $_connectAttempts marta urinishdan keyin muvaffaqiyatsiz — $host:$port.',
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
    final safe =
        String.fromCharCodes(s.runes.map((r) => r <= 0xFF ? r : 0x3F));
    b.add(latin1.encode('$safe\n'));
  }

  void _appendLatin1Part(BytesBuilder b, String s) {
    final safe =
        String.fromCharCodes(s.runes.map((r) => r <= 0xFF ? r : 0x3F));
    b.add(latin1.encode(safe));
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

  Future<void> _ensureLogoEscPos() async {
    if (_cachedLogoEscPos != null &&
        _cachedLogoCacheVersion == _logoCacheVersion) {
      return;
    }
    try {
      final bundle = await rootBundle.load(_logoAssetPath);
      final decoded = img.decodeImage(bundle.buffer.asUint8List());
      if (decoded == null) return;
      _cachedLogoEscPos = _encodeEscPosRaster(_prepareLogoForPrint(decoded));
      _cachedLogoCacheVersion = _logoCacheVersion;
    } catch (e, st) {
      _logDebug('Logo raster: $e', stackTrace: st);
    }
  }

  img.Image _prepareLogoForPrint(img.Image decoded) {
    final transparent = img.ColorRgba8(255, 255, 255, 0);
    var work = _trimLogoContent(decoded);
    work = img.copyExpandCanvas(
      work,
      padding: _logoCanvasPaddingPx,
      backgroundColor: transparent,
    );
    if (work.width > _logoMaxWidthPx) {
      work = img.copyResize(
        work,
        width: _logoMaxWidthPx,
        interpolation: img.Interpolation.cubic,
      );
    }
    return _centerLogoOnPaper(work);
  }

  img.Image _trimLogoContent(img.Image src) {
    var minX = src.width;
    var minY = src.height;
    var maxX = 0;
    var maxY = 0;
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        if (!_shouldPrintLogoPixel(src.getPixel(x, y))) continue;
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
    if (maxX < minX || maxY < minY) return src;
    return img.copyCrop(
      src,
      x: minX,
      y: minY,
      width: maxX - minX + 1,
      height: maxY - minY + 1,
    );
  }

  img.Image _centerLogoOnPaper(img.Image src) {
    if (src.width >= _contentDotsWidth) return src;
    final canvas = img.Image(
      width: _contentDotsWidth,
      height: src.height,
      numChannels: 4,
    );
    img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 0));
    img.compositeImage(
      canvas,
      src,
      dstX: (_contentDotsWidth - src.width) ~/ 2,
    );
    return canvas;
  }

  bool _shouldPrintLogoPixel(img.Pixel pixel) {
    if (pixel.a < 40) return false;
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    if (r > 228 && g > 228 && b > 228) return false;
    if (g > 90 && g >= r && g >= b) return true;
    return img.getLuminance(pixel) < 210;
  }

  Uint8List _encodeEscPosRaster(img.Image image) {
    final width = image.width;
    final height = image.height;
    final bytesPerRow = (width + 7) ~/ 8;
    final raster = Uint8List(bytesPerRow * height);
    for (var y = 0; y < height; y++) {
      for (var xb = 0; xb < bytesPerRow; xb++) {
        var slice = 0;
        for (var bit = 0; bit < 8; bit++) {
          final x = xb * 8 + bit;
          if (x >= width) continue;
          if (_shouldPrintLogoPixel(image.getPixel(x, y))) {
            slice |= 1 << (7 - bit);
          }
        }
        raster[y * bytesPerRow + xb] = slice;
      }
    }
    final out = BytesBuilder(copy: false);
    out.add(const [0x1D, 0x76, 0x30, 0x00]);
    out.add([bytesPerRow & 0xFF, bytesPerRow >> 8]);
    out.add([height & 0xFF, height >> 8]);
    out.add(raster);
    return out.takeBytes();
  }

  String _receiptOrderId(Map<String, dynamic> raw) {
    var id =
        _scalarString(raw, const ['order_number', 'orderNumber', 'number']) ??
            _scalarString(raw, const ['order_id', 'orderId', 'id']) ??
            '';
    id = id.trim();
    if (id.startsWith('#')) id = id.substring(1);
    // "ORD-CF8C5319" -> "CF8C5319" — qisqaroq, bardan o'tadi
    id = id.replaceFirst(RegExp(r'^ord-', caseSensitive: false), '');
    return id.toUpperCase();
  }

  bool _isDeliveryOrder(Map<String, dynamic> raw) {
    final orderType =
        _scalarString(raw, const ['order_type', 'orderType']) ?? 'pickup';
    final normalized = orderType.trim().toLowerCase();
    return normalized == 'delivery' ||
        normalized == 'driver' ||
        normalized == 'courier';
  }

  String _formatReceiptDate(DateTime dt) {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'pm' : 'am';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} $hour:$minute$suffix';
  }

  DateTime? _parseOrderDate(Map<String, dynamic> raw, List<String> keys) {
    final s = _scalarString(raw, keys);
    if (s == null) return null;
    return DateTime.tryParse(s)?.toLocal();
  }

  /// WebSocket `customer_name`: bitta so'z — o'zi; ism + familiya — `Michelle T.`
  String _formatReceiptBuyerName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length <= 1) return trimmed;

    final first = parts.first;
    final lastLetters =
        parts.last.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (lastLetters.isEmpty) return first;

    return '$first ${lastLetters[0].toUpperCase()}.';
  }

  String _receiptCustomerDisplayName(Map<String, dynamic> raw) {
    final fromPayload = _receiptCustomerDisplayNameFromMap(raw);
    if (fromPayload.isNotEmpty) {
      return _formatReceiptBuyerName(fromPayload);
    }
    return _staticCustomerName;
  }

  String _receiptCustomerDisplayNameFromMap(Map<String, dynamic> raw) {
    for (final wrapKey in const ['data', 'order', 'payload', 'order_data']) {
      final wrapped = _nestedMap(raw, wrapKey);
      if (wrapped == null) continue;
      final fromWrap = _receiptCustomerDisplayNameFromFlatMap(wrapped);
      if (fromWrap.isNotEmpty) return fromWrap;
    }
    return _receiptCustomerDisplayNameFromFlatMap(raw);
  }

  String _receiptCustomerDisplayNameFromFlatMap(Map<String, dynamic> raw) {
    final flat = _scalarString(raw, const [
      'customer_name', 'customer_full_name', 'full_name', 'client_name',
      'recipient_name', 'buyer_name', 'contact_name', 'receiver_name',
      'delivery_name', 'delivery_contact_name', 'user_name',
      'user_full_name', 'profile_name', 'customer_display_name',
    ]);
    if (flat != null && flat.trim().isNotEmpty) return flat.trim();

    final cfn =
        _scalarString(raw, const ['customer_first_name', 'buyer_first_name']);
    final cln =
        _scalarString(raw, const ['customer_last_name', 'buyer_last_name']);
    final combined = '${cfn ?? ''} ${cln ?? ''}'.trim();
    if (combined.isNotEmpty) return combined;

    for (final nestKey in const [
      'customer', 'user', 'client', 'buyer', 'profile', 'recipient',
    ]) {
      final m = _nestedMap(raw, nestKey);
      if (m == null) continue;
      final nested = _receiptCustomerDisplayNameFromFlatMap(m);
      if (nested.isNotEmpty) return nested;
    }
    return '';
  }

  void _escNormalSize(BytesBuilder b) => b.add(const [0x1D, 0x21, 0x00]);
  void _escDoubleHeight(BytesBuilder b) => b.add(const [0x1D, 0x21, 0x01]);
  void _escDoubleSize(BytesBuilder b) => b.add(const [0x1D, 0x21, 0x11]);
  void _escLineSpacing(BytesBuilder b, int dots) =>
      b.add([0x1B, 0x33, dots]);
  void _escFeedLines(BytesBuilder b, int lines) => b.add([0x1B, 0x64, lines]);

  /// Chap/o'ng [_receiptMarginPx]. GS W ishlatilmaydi — tor maydon o'ngda bo'sh qoldirardi.
  void _escSetReceiptMargins(BytesBuilder b) {
    b.add([
      0x1D,
      0x4C,
      _receiptMarginPx & 0xFF,
      (_receiptMarginPx >> 8) & 0xFF,
    ]);
  }

  Future<Uint8List> _buildNewOrderEscPosPayload(
      Map<String, dynamic> raw) async {
    await _ensureLogoEscPos();
    final b = BytesBuilder(copy: false);

    void line(String s) => _appendLatin1Line(b, s);

    // ---------------------------------------------------------------
    // Matnni chiziqqa joylashtirish yordamchilari
    // ---------------------------------------------------------------
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
            final end =
                (i + maxWidth > w.length) ? w.length : i + maxWidth;
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



    // pairRow: left chapga, right o'ngda — jami W char (margin ichidagi kenglik).
    void pairRow(String left, String right, {bool bold = false, bool boldLeft = false}) {
      final w = _receiptLineWidth;
      final r = right.trim();

      if (r.isEmpty) {
        if (bold || boldLeft) b.add(const [0x1B, 0x45, 0x01]);
        for (final l in wrapWords(left, w)) line(l);
        if (bold || boldLeft) b.add(const [0x1B, 0x45, 0x00]);
        return;
      }

      final maxLeft = (w - r.length - 1).clamp(1, w - 1);
      final leftLines = wrapWords(left, maxLeft);
      final fl = leftLines.first;

      final spaces = w - fl.length - r.length;
      final gap = spaces > 0 ? spaces : 1;

      if (bold) {
        b.add(const [0x1B, 0x45, 0x01]);
        line(fl + (' ' * gap) + r);
        b.add(const [0x1B, 0x45, 0x00]);
      } else if (boldLeft) {
        b.add(const [0x1B, 0x45, 0x01]);
        _appendLatin1Part(b, fl);
        b.add(const [0x1B, 0x45, 0x00]);
        _appendLatin1Line(b, (' ' * gap) + r);
      } else {
        line(fl + (' ' * gap) + r);
      }
      for (final l in leftLines.skip(1)) {
        if (bold || boldLeft) b.add(const [0x1B, 0x45, 0x01]);
        line(l);
        if (bold || boldLeft) b.add(const [0x1B, 0x45, 0x00]);
      }
    }

    void blankLines(int count) {
      for (var i = 0; i < count; i++) line('');
    }

    // ---------------------------------------------------------------
    // Qora card: order ID (chap) + mijoz ismi (o'ng), 3 qatorli quti
    //   [yuqori qora chiziq] — vertikal padding
    //   [matn qatori]         — ikki barobar + bold
    //   [past qora chiziq]    — vertikal padding
    // Ichki chap/o'ng: [_orderBarInnerPadChars] belgi
    // ---------------------------------------------------------------
    void appendOrderIdBar(String id, String customerName) {
      final barCharW = _receiptLineWidth ~/ 2;
      final innerPad = _orderBarInnerPadChars.clamp(0, 6);

      var left = id.trim();
      var right = customerName.trim();
      if (right.isEmpty) right = _staticCustomerName;

      while (true) {
        final leftPart = '${' ' * innerPad}$left';
        final rightPart = '${' ' * innerPad}$right';
        if (leftPart.length + rightPart.length + 1 <= barCharW) break;
        if (right.isNotEmpty) {
          right = right.substring(0, right.length - 1);
        } else if (left.length > 4) {
          left = left.substring(0, left.length - 1);
        } else {
          break;
        }
      }

      final leftPart = '${' ' * innerPad}$left';
      final rightPart = '${' ' * innerPad}$right';
      final gap =
          (barCharW - leftPart.length - rightPart.length).clamp(1, barCharW);
      final barText = '$leftPart${' ' * gap}$rightPart';

      void blackCardLineFull() {
        _escDoubleSize(b);
        line(' ' * barCharW);
        _escNormalSize(b);
      }

      /// Matn qatoridan ~yarim balandlikdagi qora chiziq (2x height, kenglik to'liq).
      void blackCardLineHalf() {
        _escDoubleHeight(b);
        line(' ' * _receiptLineWidth);
        _escNormalSize(b);
      }

      void appendVertPad(double lines) {
        if (lines <= 0) return;
        final full = lines.floor();
        final half = lines - full >= 0.5;
        for (var i = 0; i < full; i++) {
          blackCardLineFull();
        }
        if (half) blackCardLineHalf();
      }

      b.add(const [0x1B, 0x61, 0x00]);
      _escLineSpacing(b, _orderBarLineSpacingPx);
      b.add(const [0x1D, 0x42, 0x01]);
      appendVertPad(_orderBarVertPadLines);
      _escDoubleSize(b);
      b.add(const [0x1B, 0x45, 0x01]);
      line(barText);
      b.add(const [0x1B, 0x45, 0x00]);
      _escNormalSize(b);
      appendVertPad(_orderBarVertPadLines);
      b.add(const [0x1D, 0x42, 0x00]);
      _escLineSpacing(b, 0x30);
    }

    // ---------------------------------------------------------------
    // CHEK BOSHLANISHI
    // ---------------------------------------------------------------
    b.add(const [0x1B, 0x40]); // ESC @ — init
    _escSetReceiptMargins(b);
    _escLineSpacing(b, 0x30);
    b.add(const [0x1B, 0x61, 0x01]); // markaz

    blankLines(2);

    // Logo
    if (_cachedLogoEscPos != null) {
      b.add(_cachedLogoEscPos!);
      b.add(const [0x0A]);
      _escNormalSize(b);
      b.add(const [0x1B, 0x45, 0x00]);
      b.add(const [0x1D, 0x42, 0x00]);
      b.add(const [0x1B, 0x61, 0x00]);
      blankLines(1);
    }

    // ---------------------------------------------------------------
    // Qora bar: ORDER ID + MIJOZ ISMI
    // ---------------------------------------------------------------
    final orderId = _receiptOrderId(raw);
    final customerName = _receiptCustomerDisplayName(raw);
    if (orderId.isNotEmpty) {
      appendOrderIdBar(orderId, customerName);
    }
    blankLines(_sectionGapLines);

    // ---------------------------------------------------------------
    // Joylashtirilgan vaqt — normal o'lcham, chapga
    // ---------------------------------------------------------------
    _escNormalSize(b);
    b.add(const [0x1D, 0x42, 0x00]);
    b.add(const [0x1B, 0x45, 0x00]);
    b.add(const [0x1B, 0x61, 0x00]); // chapga
    final placedAt =
        _parseOrderDate(raw, const ['created_at', 'placed_at']) ??
            DateTime.now();
    line('Placed at ${_formatReceiptDate(placedAt)}');
    blankLines(_sectionGapLines);
    line('-' * _receiptLineWidth);
    blankLines(1);

    // ---------------------------------------------------------------
    // PICKUP / DELIVERY sarlavhasi
    // ---------------------------------------------------------------
    final isDeliveryOrder = _isDeliveryOrder(raw);
    b.add(const [0x1B, 0x61, 0x01]); // markaz
    b.add(const [0x1B, 0x45, 0x01]);
    _escDoubleSize(b);
    line(isDeliveryOrder ? 'DELIVERY' : 'PICKUP');
    _escNormalSize(b);
    b.add(const [0x1B, 0x45, 0x00]);
    b.add(const [0x1B, 0x61, 0x00]); // chapga
    blankLines(1);

    // ---------------------------------------------------------------
    // MAHSULOTLAR ro'yxati
    // ---------------------------------------------------------------
    final items = _extractReceiptItems(raw);
    if (items.isNotEmpty) {
      for (final item in items) {
        pairRow('${item.qty}x ${item.name}', item.price, bold: true);
        blankLines(1);
      }
    } else {
      final ordersSummary =
          _scalarString(raw, const ['orders', 'items_summary']);
      if (ordersSummary != null) pairRow(ordersSummary, '', bold: true);
      final msg = _scalarString(raw, const ['message', 'title', 'body']);
      if (msg != null) pairRow(msg, '', bold: true);
      if (ordersSummary == null && msg == null) {
        line('Items ma\'lumoti kelmadi');
      }
    }

    blankLines(_productsToTotalsGapLines);
    line('-' * _receiptLineWidth);
    blankLines(_sectionGapLines);

    // ---------------------------------------------------------------
    // NARXLAR JADVALI
    // price_data ichidan oladi; 0.00 bo'lgan promotion ko'rsatilmaydi
    // ---------------------------------------------------------------
    _escNormalSize(b);
    _buildPriceSection(
      b,
      raw,
      isDeliveryOrder,
      pairRow,
      () => blankLines(_priceRowGapLines),
    );

    // ---------------------------------------------------------------
    // FOOTER
    // ---------------------------------------------------------------
    blankLines(_sectionGapLines);
    _escNormalSize(b);
    _escLineSpacing(b, 0x30);
    b.add(const [0x1B, 0x61, 0x01]); // markaz
    b.add(const [0x1B, 0x45, 0x01]);
    _escDoubleHeight(b);
    line('--- THANK YOU ---');
    _escNormalSize(b);
    b.add(const [0x1B, 0x45, 0x00]);
    b.add(const [0x1B, 0x61, 0x00]);
    _escFeedLines(b, _footerFeedLines);
    b.add(const [0x1D, 0x56, 0x00]); // kesish
    return b.takeBytes();
  }

  // ---------------------------------------------------------------
  // Narxlar sektsiyasi — pickup va delivery uchun alohida mantig'
  // ---------------------------------------------------------------
  void _buildPriceSection(
    BytesBuilder b,
    Map<String, dynamic> raw,
    bool isDelivery,
    void Function(String, String, {bool bold, bool boldLeft}) pairRow,
    void Function() gapAfterRow,
  ) {
    void priceRow(String left, String right, {bool bold = false}) {
      pairRow(left, right, bold: bold);
      gapAfterRow();
    }
    final pd = _nestedMap(raw, 'price_data') ?? const <String, dynamic>{};

    String? _get(List<String> keys) =>
        _scalarString(pd, keys) ?? _scalarString(raw, keys);

    String _fmt(String? v) {
      if (v == null || v.trim().isEmpty) return '';
      if (v.contains('\$')) return v.trim();
      return '\$${v.trim()}';
    }

    bool _isZero(String? v) {
      if (v == null) return true;
      final n = double.tryParse(v.replaceAll('\$', '').trim());
      return n == null || n == 0.0;
    }

    final subtotal = _get(const [
      'subtotal', 'item_total_price', 'items_total', 'items_total_price',
    ]);
    final promotion = _get(const ['promotion', 'discount']);
    final serviceFee = _get(const ['service_fee', 'commission_fee']);
    final deliveryFee = _get(const ['delivery_price', 'delivery_fee']);
    final tax = _get(const ['tax']);
    final originalTotal = _get(const ['original_total_price']);
    final totalPrice = _get(const ['total_price', 'total']);

    // Subtotal
    if (subtotal != null) priceRow('Subtotal', _fmt(subtotal));

    // Promotion — faqat 0 bo'lmasa chiqar
    if (!_isZero(promotion)) {
      priceRow('Discount', _fmt(promotion));
    }

    // Service fee
    if (serviceFee != null) priceRow('Service fee', _fmt(serviceFee));

    // Delivery fee — faqat delivery buyurtma uchun
    if (isDelivery && deliveryFee != null) {
      priceRow('Delivery fee', _fmt(deliveryFee));
    }

    // Soliq
    if (tax != null) priceRow('Tax', _fmt(tax));

    // Agar original_total != total_price bo'lsa — ikkalasini ko'rsat
    final hasOriginal = originalTotal != null &&
        totalPrice != null &&
        originalTotal.trim() != totalPrice.trim() &&
        !_isZero(promotion);

    if (hasOriginal) {
      priceRow('Original total', _fmt(originalTotal));
    }

    // Amount paid (total)
    if (totalPrice != null) {
      gapAfterRow();
      priceRow('Amount paid', _fmt(totalPrice), bold: true);
    } else if (!_hasAnyTotals(raw)) {
      _appendLatin1Line(b, 'Total ma\'lumotlari kelmadi');
    }
  }

  String? _money(Map<String, dynamic> raw, List<String> keys) {
    final value = _scalarString(raw, keys) ??
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
              'item_total_price', 'subtotal', 'items_total',
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
      final unitPriceRaw =
          (m['price'] ?? m['unit_price'] ?? '').toString().trim();
      final totalPriceRaw =
          (m['total_price'] ?? m['line_total'] ?? '').toString().trim();
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

  Uint8List _buildTestEscPosPayload(String printerHost, int port) {
    final b = BytesBuilder(copy: false);
    void line(String s) => _appendLatin1Line(b, s);

    b.add(const [0x1B, 0x40]);
    _escSetReceiptMargins(b);
    b.add(const [0x1B, 0x61, 0x01]);
    b.add(const [0x1B, 0x45, 0x01]);
    line('HALALHUB RESTAURANT');
    b.add(const [0x1B, 0x45, 0x00]);
    b.add(const [0x1D, 0x21, 0x11]);
    line('TEST CHEK');
    b.add(const [0x1D, 0x21, 0x00]);
    b.add(const [0x1B, 0x61, 0x00]);
    line('-' * _receiptLineWidth);
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