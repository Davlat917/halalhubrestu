import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File;

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/services/models/vendor_ws_order_created_payload.dart';
import 'package:halalhub_restaurant/core/services/vendor_orders_foreground_task_callback.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum VendorWsEventType {
  orderCreated,
  orderStatusUpdated,
  orderUpdated,
  unknown,
}

class VendorWsEvent {
  const VendorWsEvent({required this.type, required this.raw, this.orderCreated});

  final VendorWsEventType type;
  final Map<String, dynamic> raw;
  final VendorWsOrderCreatedPayload? orderCreated;

  static VendorWsEvent fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] as String? ?? '').toLowerCase().trim();
    switch (typeRaw) {
      case 'order_created':
        return VendorWsEvent(
          type: VendorWsEventType.orderCreated,
          raw: json,
          orderCreated: VendorWsOrderCreatedPayload.fromJson(json),
        );
      case 'order_status_updated':
        return VendorWsEvent(
          type: VendorWsEventType.orderStatusUpdated,
          raw: json,
        );
      case 'order_updated':
        return VendorWsEvent(
          type: VendorWsEventType.orderUpdated,
          raw: json,
        );
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
  VendorNotificationsWsService(this._storage, this._dio, this._logger, this._receiptPrinter);

  final Storage _storage;
  final Dio _dio;
  final Logger _logger;
  final ReceiptPrinterService _receiptPrinter;
  final _eventsController = StreamController<VendorWsEvent>.broadcast();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamSubscription<String?>? _tokenSubscription;
  Timer? _reconnectTimer;
  bool _started = false;
  bool _foreground = true;
  int _retry = 0;
  bool _localNotificationsReady = false;
  bool _flutterForegroundConfigured = false;
  AudioPlayer? _newOrderSoundPlayer;
  File? _newOrderSoundCacheFile;
  int _alertSoundEpoch = 0;
  Future<void> _alertSoundChain = Future.value();

  void _logInfo(String message) {
    if (kDebugMode) _logger.i(message);
  }

  void _logWarn(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, stackTrace: stackTrace);
  }

  void _logDebug(String message) {
    if (kDebugMode) _logger.d(message);
  }

  void _logWsIncoming(String raw) {
    if (!kDebugMode) return;
    _logger.i(
      '📡 Vendor WS ← incoming\n'
      '┌${'─' * 38}\n'
      '${_formatWsIncomingForLog(raw)}\n'
      '└${'─' * 38}',
    );
  }

  void _logWsEventParsed(VendorWsEvent event) {
    if (!kDebugMode) return;
    final payload = event.orderCreated;
    if (payload == null) {
      _logger.i('📡 Vendor WS parsed: type=${event.type.name}');
      return;
    }
    final rawItems = event.raw['items'];
    final itemCount = rawItems is List ? rawItems.length : 0;
    _logger.i(
      '📡 Vendor WS parsed: type=${event.type.name} | '
      'order_id=${payload.orderId} | '
      'order_number=${payload.orderNumber} | '
      'customer=${payload.customerName} | '
      'order_type=${payload.orderType} | '
      'items=$itemCount',
    );
  }

  /// Postman Messages paneliga o‘xshash: JSON bo‘lsa indent bilan.
  String _formatWsIncomingForLog(String raw) {
    try {
      final decoded = jsonDecode(raw);
      final String body;
      if (decoded is Map || decoded is List) {
        body = const JsonEncoder.withIndent('  ').convert(decoded);
      } else {
        body = decoded.toString();
      }
      if (body.length > _wsIncomingLogMaxChars) {
        return '${body.substring(0, _wsIncomingLogMaxChars)}\n… (truncated, ${body.length} chars total)';
      }
      return body;
    } catch (_) {
      final preview = raw.length > 2000 ? '${raw.substring(0, 2000)}…' : raw;
      return '(parse as JSON failed — raw preview)\n$preview';
    }
  }

  // static const _wsBase = 'wss://infonexuz.uz/ws/notifications/vendor/';
  static const _wsBase = 'wss://backend-api.wehalalhub.com/ws/notifications/vendor/';

  /// `rootBundle` uchun to‘liq kalit; `AssetSource` (web) uchun — prefiksiz.
  static const _newOrderBundleKey = 'assets/sounds/new-order.wav';
  static const _newOrderSoundAssetPath = 'sounds/new-order.wav';
  static final _newOrderAsset = AssetSource(_newOrderSoundAssetPath);
  static const int _wsIncomingLogMaxChars = 12000;

  /// Android 8+ kanal bir marta yaratiladi; ovoz yo‘q kanalni almashtirish uchun ID yangilandi.
  static const _androidOrderAlertChannelId = 'vendor_orders_alert_v1';
  static const _androidNativeAlertChannel = MethodChannel('com.infonex.halalhubrestu/vendor_order_alert');

  Stream<VendorWsEvent> get events => _eventsController.stream;

  bool _androidNativeOrderAlertActive = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _ensureLocalNotificationsInitialized();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_startAndroidForegroundForVendorOrders());
    _tokenSubscription = _storage.token.watch().listen((token) {
      if (token == null || token.isEmpty) {
        unawaited(_stopAndroidForegroundForVendorOrders());
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
    await _stopAndroidForegroundForVendorOrders();
    await stopNewOrderAlertSound();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isForeground = state == AppLifecycleState.resumed;
    if (_foreground == isForeground) return;
    _foreground = isForeground;
    if (_foreground) {
      _connectIfPossible();
      _schedulePendingOrderAlertSync();
    }
    // Fon / ekran o‘chiq: WebSocketni yopmaymiz — Android’da foreground service
    // jarayonni tiriklab turadi; buyurtma bildirishnoma va chek ishlayveradi.
  }

  void _schedulePendingOrderAlertSync() {
    unawaited(syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true));
    for (final ms in const [900, 2000, 5000]) {
      unawaited(
        Future<void>.delayed(Duration(milliseconds: ms), () {
          if (!_foreground) return;
          unawaited(syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true));
        }),
      );
    }
  }

  Future<void> _connectIfPossible() async {
    if (!_started) return;
    final token = _storage.token.call();
    if (token == null || token.isEmpty) return;
    if (_channel != null) return;

    try {
      final vendorId = await _resolveVendorId();
      if (vendorId == null) return;
      final uri = Uri.parse('$_wsBase$vendorId/?token=${Uri.encodeQueryComponent(token)}');
      _channel = WebSocketChannel.connect(uri);
      _logInfo('Vendor notifications WS connecting (vendorId=$vendorId)');
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
      unawaited(_startAndroidForegroundForVendorOrders());
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

  Future<File> _ensureNewOrderSoundFileOnDisk() async {
    final existing = _newOrderSoundCacheFile;
    if (existing != null && await existing.exists()) return existing;
    final data = await rootBundle.load(_newOrderBundleKey);
    final file = File('${Directory.systemTemp.path}/halalhub_new_order_alert.wav');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    _newOrderSoundCacheFile = file;
    return file;
  }

  void _onData(dynamic data) {
    if (data is! String) {
      _logWarn('Vendor WS ← unexpected payload type: ${data.runtimeType}');
      return;
    }
    _logWsIncoming(data);
    try {
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) {
        _logWarn('Vendor WS ← JSON is not an object');
        return;
      }
      if (_eventsController.isClosed) return;
      final event = VendorWsEvent.fromJson(json);
      _logWsEventParsed(event);
      _eventsController.add(event);
      if (event.type == VendorWsEventType.orderCreated) {
        _receiptPrinter.cacheOrderCreatedPayload(event.raw);
        // Ovozni faqat dialog (yoki buyurtmalar ro'yxatida status) bilan o'chiramiz.
        unawaited(startNewOrderAlertSoundLoop());
        // Ilova ochiq (foreground): push/banner ko'rinmasin — faqat ovoz + dialog.
        // Fonda / lock screen: mahalliy bildirishnoma (tizim ovozi).
        if (!_foreground) {
          unawaited(_showOrderCreatedNotification(event.raw));
        }
      }
    } catch (e, st) {
      _logWarn('Vendor WS payload parse failed: $e', stackTrace: st);
    }
  }

  Future<void> _stopAndroidNativeOrderAlert() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _androidNativeAlertChannel.invokeMethod<void>('stopLoop');
    } catch (e, st) {
      debugPrint('[VendorNewOrderSound] native stop: $e\n$st');
    }
    _androidNativeOrderAlertActive = false;
  }

  Future<void> startNewOrderAlertSoundLoop({bool forceRestart = false}) {
    final epoch = _alertSoundEpoch;
    _alertSoundChain = _alertSoundChain.then((_) async {
      if (epoch != _alertSoundEpoch) return;
      await _startNewOrderAlertSoundLoopBody(epoch, forceRestart: forceRestart);
    });
    return _alertSoundChain;
  }

  Future<void> stopNewOrderAlertSound() {
    _alertSoundEpoch++;
    _alertSoundChain = _alertSoundChain.then((_) async {
      await _stopNewOrderAlertSoundBody();
    });
    return _alertSoundChain;
  }

  bool _alertSoundEpochActive(int epoch) => epoch == _alertSoundEpoch;

  Future<void> _disposeAlertPlayer(AudioPlayer? player) async {
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
    try {
      await player.dispose();
    } catch (_) {}
  }

  Future<void> _releaseCurrentAlertPlayer() async {
    final previous = _newOrderSoundPlayer;
    _newOrderSoundPlayer = null;
    await _disposeAlertPlayer(previous);
  }

  Future<void> _startNewOrderAlertSoundLoopBody(int epoch, {bool forceRestart = false}) async {
    try {
      if (forceRestart) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _stopAndroidNativeOrderAlert();
        }
        await _releaseCurrentAlertPlayer();
        _androidNativeOrderAlertActive = false;
      } else {
        final current = _newOrderSoundPlayer;
        if (current != null) {
          try {
            if (current.state == PlayerState.playing) {
              _logDebug('startNewOrderAlertSoundLoop: already playing, skip');
              return;
            }
          } catch (_) {}
        }
      }

      if (!_alertSoundEpochActive(epoch)) return;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _stopAndroidNativeOrderAlert();
        await _releaseCurrentAlertPlayer();
        if (!_alertSoundEpochActive(epoch)) return;
        try {
          await _androidNativeAlertChannel.invokeMethod<void>('startLoop');
          _androidNativeOrderAlertActive = true;
          _logInfo('startNewOrderAlertSoundLoop Android native MediaPlayer started');
          return;
        } catch (e, st) {
          debugPrint('[VendorNewOrderSound] native start failed, fallback audioplayers: $e\n$st');
          await _stopAndroidNativeOrderAlert();
        }
        await AudioPlayer.global.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(usageType: AndroidUsageType.media, contentType: AndroidContentType.music, audioFocus: AndroidAudioFocus.gain, isSpeakerphoneOn: true, stayAwake: true),
          ),
        );
      } else {
        await _releaseCurrentAlertPlayer();
      }

      if (!_alertSoundEpochActive(epoch)) return;

      final player = AudioPlayer();
      _newOrderSoundPlayer = player;
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      if (!_alertSoundEpochActive(epoch) || _newOrderSoundPlayer != player) {
        await _disposeAlertPlayer(player);
        return;
      }

      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
          android: AudioContextAndroid(usageType: AndroidUsageType.media, contentType: AndroidContentType.music, audioFocus: AndroidAudioFocus.gain, isSpeakerphoneOn: true, stayAwake: true),
        ),
      );
      if (!_alertSoundEpochActive(epoch) || _newOrderSoundPlayer != player) {
        await _disposeAlertPlayer(player);
        return;
      }

      final Source source;
      if (kIsWeb) {
        source = _newOrderAsset;
      } else {
        final f = await _ensureNewOrderSoundFileOnDisk();
        if (!_alertSoundEpochActive(epoch) || _newOrderSoundPlayer != player) {
          await _disposeAlertPlayer(player);
          return;
        }
        source = DeviceFileSource(f.path);
      }

      final pathLog = source is DeviceFileSource ? source.path : _newOrderBundleKey;
      _logInfo(
        'startNewOrderAlertSoundLoop source=${source.runtimeType} path=$pathLog | '
        'state=${player.state.name}',
      );
      await player.setReleaseMode(ReleaseMode.loop);
      if (!_alertSoundEpochActive(epoch) || _newOrderSoundPlayer != player) {
        await _disposeAlertPlayer(player);
        return;
      }
      await player.setVolume(1.0);
      await player.play(source);
      _logInfo('startNewOrderAlertSoundLoop started successfully | state=${player.state.name}');
    } catch (e, st) {
      debugPrint('[VendorNewOrderSound] start failed: $e\n$st');
      _logWarn('Vendor notifications new order loop start failed: $e', stackTrace: st);
    }
  }

  Future<void> _stopNewOrderAlertSoundBody() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _stopAndroidNativeOrderAlert();
    }
    final player = _newOrderSoundPlayer;
    _newOrderSoundPlayer = null;
    if (player == null) return;
    try {
      _logInfo('stopNewOrderAlertSound requested');
      await _disposeAlertPlayer(player);
      _logInfo('stopNewOrderAlertSound completed');
    } catch (e, st) {
      debugPrint('[VendorNewOrderSound] stop failed: $e\n$st');
      _logWarn('Vendor notifications new order loop stop failed: $e', stackTrace: st);
    }
  }

  Future<void> syncAlertSoundWithPendingOrdersFromBackend({bool forceRestart = false}) async {
    try {
      _logInfo('syncAlertSoundWithPendingOrdersFromBackend started');
      final response = await _dio.get(Constants.vendorsOrders);
      final data = response.data;
      if (data is! Map<String, dynamic>) return;
      final results = data['results'];
      if (results is! List) return;

      bool hasPending = false;
      for (final item in results) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final statusRaw = (map['status'] ?? '').toString();
        // OrdersBloc bilan bir xil: noma'lum statuslar default bo'lib newOrder (tovush o'chmasin).
        if (VendorOrdersItem.statusFromApi(statusRaw) == VendorOrderStatus.newOrder) {
          hasPending = true;
          break;
        }
      }

      _logInfo('syncAlertSoundWithPendingOrdersFromBackend pending=$hasPending');
      // Bu yerda hech qachon stop qilmaymiz: push/lifecycle sinxroni API kechikishi bilan
      // ovozni "yo'q qilib" yuborardi. O'chirish — OrdersBloc (ro'yxat + grace) yoki status yangilanishi.
      if (hasPending) {
        await startNewOrderAlertSoundLoop(forceRestart: forceRestart);
      }
    } catch (e, st) {
      _logWarn('Vendor notifications pending orders sync failed: $e', stackTrace: st);
    }
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsReady) return;
    const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings());
    await _localNotifications.initialize(settings: settings);

    final android = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(_androidOrderAlertChannelId, 'Vendor order alerts', description: 'New order sound when app is open or in background', importance: Importance.max, playSound: true, enableVibration: true));
    }

    _localNotificationsReady = true;
  }

  Future<void> _showOrderCreatedNotification(Map<String, dynamic> raw) async {
    if (!_localNotificationsReady) return;
    try {
      final orderNumber = raw['order_number']?.toString().trim();
      final title = raw['message']?.toString().trim();
      final text = (orderNumber == null || orderNumber.isEmpty) ? 'New order received' : 'Order: $orderNumber';
      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: (title == null || title.isEmpty) ? 'New order received' : title,
        body: text,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(_androidOrderAlertChannelId, 'Vendor order alerts', channelDescription: 'New order sound when app is open or in background', importance: Importance.max, priority: Priority.high, playSound: true, enableVibration: true),
          iOS: const DarwinNotificationDetails(),
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
    if (!_started) return;
    _reconnectTimer?.cancel();
    final delaySeconds = (_retry + 1).clamp(1, 20);
    _retry = delaySeconds;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _connectIfPossible);
  }

  void _configureFlutterForegroundTaskOnce() {
    if (_flutterForegroundConfigured) return;
    _flutterForegroundConfigured = true;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(channelId: 'vendor_orders_fg', channelName: 'Vendor orders', channelDescription: "Ekran o'chiq bo'lsa ham buyurtmalar ulanishini saqlab turadi.", channelImportance: NotificationChannelImportance.LOW, priority: NotificationPriority.LOW, onlyAlertOnce: true),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: false, playSound: false),
      foregroundTaskOptions: ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.nothing(), allowWakeLock: true, allowWifiLock: true),
    );
  }

  Future<void> _startAndroidForegroundForVendorOrders() async {
    if (defaultTargetPlatform != TargetPlatform.android || !_started) return;
    try {
      if (await FlutterForegroundTask.isRunningService) return;
    } catch (e) {
      _logWarn('Foreground service isRunningService check failed: $e');
      return;
    }

    _configureFlutterForegroundTaskOnce();

    try {
      final perm = await FlutterForegroundTask.checkNotificationPermission();
      if (perm != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      _logWarn('Foreground task notification permission: $e');
    }

    try {
      final result = await FlutterForegroundTask.startService(serviceId: 888, serviceTypes: const [ForegroundServiceTypes.dataSync], notificationTitle: 'HalalHub Restaurant', notificationText: "Buyurtmalar kutilmoqda (fon rejimi)", callback: vendorOrdersForegroundTaskStartCallback);
      if (result is ServiceRequestFailure) {
        _logWarn('Foreground service start failed: ${result.error}');
      }
    } catch (e, st) {
      _logWarn('Foreground service start error: $e', stackTrace: st);
    }
  }

  Future<void> _stopAndroidForegroundForVendorOrders() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final result = await FlutterForegroundTask.stopService();
      if (result is ServiceRequestFailure) {
        _logWarn('Foreground service stop failed: ${result.error}');
      }
    } catch (e, st) {
      _logWarn('Foreground service stop error: $e', stackTrace: st);
    }
  }
}
