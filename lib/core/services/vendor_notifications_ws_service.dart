import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum VendorWsEventType { orderCreated, unknown }

class VendorWsEvent {
  const VendorWsEvent({required this.type, required this.raw});

  final VendorWsEventType type;
  final Map<String, dynamic> raw;

  static VendorWsEvent fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] as String? ?? '').toLowerCase().trim();
    switch (typeRaw) {
      case 'order_created':
        return VendorWsEvent(type: VendorWsEventType.orderCreated, raw: json);
      default:
        return VendorWsEvent(type: VendorWsEventType.unknown, raw: json);
    }
  }
}

/// Global vendor notifications websocket.
///
/// - App ochilganda bir marta ulanadi.
/// - Bitta channel ishlatadi (RAM yengil).
/// - Ulanish uzilsa yengil backoff bilan qayta ulanadi.
@lazySingleton
class VendorNotificationsWsService with WidgetsBindingObserver {
  VendorNotificationsWsService(
    this._storage,
    this._dio,
    this._logger,
    this._receiptPrinter,
  );

  final Storage _storage;
  final Dio _dio;
  final Logger _logger;
  final ReceiptPrinterService _receiptPrinter;
  final _eventsController = StreamController<VendorWsEvent>.broadcast();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamSubscription<String?>? _tokenSubscription;
  Timer? _reconnectTimer;
  bool _started = false;
  bool _foreground = true;
  int _retry = 0;
  bool _localNotificationsReady = false;
  AudioPlayer? _newOrderSoundPlayer;
  final Map<String, DateTime> _recentPrintedOrderKeys = <String, DateTime>{};

  void _logInfo(String message) {
    if (kDebugMode) _logger.i(message);
  }

  void _logWarn(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, stackTrace: stackTrace);
  }

  static const _wsBase = 'wss://backend-api.wehalalhub.com/ws/notifications/vendor/';
  static final _newOrderAsset = AssetSource('sounds/new-order.mp3');
  static const Duration _printDedupWindow = Duration(seconds: 90);

  Stream<VendorWsEvent> get events => _eventsController.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _ensureLocalNotificationsInitialized();
    WidgetsBinding.instance.addObserver(this);
    _tokenSubscription = _storage.token.watch().listen((token) {
      if (token == null || token.isEmpty) {
        _disconnect();
        return;
      }
      _connectIfPossible();
    });
    await _connectIfPossible();
  }

  Future<void> stop() async {
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    await _disconnect();
    await _newOrderSoundPlayer?.dispose();
    _newOrderSoundPlayer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isForeground = state == AppLifecycleState.resumed;
    if (_foreground == isForeground) return;
    _foreground = isForeground;
    if (_foreground) {
      _connectIfPossible();
    } else {
      // Backgroundda kanalni yopib, batareya/RAM sarfini kamaytiramiz.
      _disconnect();
    }
  }

  Future<void> _connectIfPossible() async {
    if (!_started || !_foreground) return;
    final token = _storage.token.call();
    if (token == null || token.isEmpty) return;
    if (_channel != null) return;

    try {
      final vendorId = await _resolveVendorId();
      if (vendorId == null) return;
      final uri = Uri.parse(
        '$_wsBase$vendorId/?token=${Uri.encodeQueryComponent(token)}',
      );
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        _onData,
        onError: (Object e, StackTrace st) {
          _logWarn('Vendor notifications WS error: $e');
          _scheduleReconnect();
        },
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
      _retry = 0;
      _logInfo('Vendor notifications WS connected');
    } catch (e) {
      _logWarn('Vendor notifications WS connect failed: $e');
      _scheduleReconnect();
    }
  }

  Future<int?> _resolveVendorId() async {
    try {
      final r = await _dio.get(Constants.vendorsMe);
      final data = r.data;
      if (data is Map<String, dynamic>) {
        final id = data['id'];
        if (id is int) return id;
        if (id is num) return id.toInt();
      }
    } catch (e) {
      _logWarn('Vendor notifications WS vendor id fetch failed: $e');
    }
    return null;
  }

  void _onData(dynamic data) {
    // Yengil parse: faqat event turini ajratamiz.
    if (data is! String) return;
    try {
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) return;
      if (_eventsController.isClosed) return;
      final event = VendorWsEvent.fromJson(json);
      _eventsController.add(event);
      if (event.type == VendorWsEventType.orderCreated) {
        _playNewOrderSound();
        _showOrderCreatedNotification(event.raw);
        if (_foreground) {
          // WS reconnect/payloadda dublikat bo'lsa, bir orderni qayta chop etmaymiz.
          if (_shouldPrintFor(event.raw)) {
            // Chek servisi ichida xatolar log qilinadi; WS oqimini bloklamaymiz.
            unawaited(_receiptPrinter.printNewOrderReceiptFromWs(event.raw));
          }
        }
      }
    } catch (_) {
      // ignore malformed payload
    }
  }

  Future<void> _playNewOrderSound() async {
    if (!_foreground) return;
    try {
      _newOrderSoundPlayer ??= AudioPlayer();
      await _newOrderSoundPlayer!.stop();
      await _newOrderSoundPlayer!.play(_newOrderAsset);
    } catch (e) {
      _logWarn('Vendor notifications new order sound failed: $e');
    }
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsReady) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(settings: settings);
    _localNotificationsReady = true;
  }

  Future<void> _showOrderCreatedNotification(Map<String, dynamic> raw) async {
    if (!_foreground || !_localNotificationsReady) return;
    try {
      final orderNumber = raw['order_number']?.toString().trim();
      final title = raw['message']?.toString().trim();
      final text = (orderNumber == null || orderNumber.isEmpty)
          ? 'New order received'
          : 'Order: $orderNumber';
      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: (title == null || title.isEmpty) ? 'New order received' : title,
        body: text,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'vendor_orders_ws',
            'Vendor orders websocket',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      _logWarn('Vendor notifications local show failed: $e');
    }
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    _disconnect();
    if (!_started || !_foreground) return;
    _reconnectTimer?.cancel();
    final delaySeconds = (_retry + 1).clamp(1, 20);
    _retry = delaySeconds;
    _reconnectTimer = Timer(
      Duration(seconds: delaySeconds),
      _connectIfPossible,
    );
  }

  bool _shouldPrintFor(Map<String, dynamic> raw) {
    _cleanupExpiredPrintKeys();
    final key = _orderPrintKey(raw);
    if (key == null) return true;
    final now = DateTime.now();
    final lastPrintedAt = _recentPrintedOrderKeys[key];
    if (lastPrintedAt != null && now.difference(lastPrintedAt) < _printDedupWindow) {
      _logInfo('Vendor WS duplicate order print skipped: $key');
      return false;
    }
    _recentPrintedOrderKeys[key] = now;
    return true;
  }

  void _cleanupExpiredPrintKeys() {
    if (_recentPrintedOrderKeys.isEmpty) return;
    final now = DateTime.now();
    _recentPrintedOrderKeys.removeWhere(
      (_, ts) => now.difference(ts) > _printDedupWindow,
    );
  }

  String? _orderPrintKey(Map<String, dynamic> raw) {
    final candidates = <dynamic>[
      raw['order_id'],
      raw['orderId'],
      raw['id'],
      raw['order_number'],
      raw['orderNumber'],
    ];
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty) return s;
    }
    // ID kelmasa fallback fingerprint; shu payload takror kelsa dublikat deb ko'ramiz.
    final message = raw['message']?.toString().trim() ?? '';
    if (message.isEmpty) return null;
    return 'msg:$message';
  }
}
