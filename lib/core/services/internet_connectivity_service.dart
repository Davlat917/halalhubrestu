import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:injectable/injectable.dart';

/// Qurilma tarmog‘i yo‘q bo‘lsa [NotInternetPage] ni root ustiga ochadi.
@lazySingleton
class InternetConnectivityService {
  InternetConnectivityService(this._router);

  final AppRouter _router;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _healthTimer;
  bool _started = false;
  int _probeSeq = 0;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription?.cancel();
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) => unawaited(_onResults(results)),
      );
      unawaited(_connectivity.checkConnectivity().then(_onResults));

      // Wifi ulangan, lekin internet uzilgan holatda connectivity event kelmasligi mumkin.
      _healthTimer?.cancel();
      _healthTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        unawaited(_connectivity.checkConnectivity().then(_onResults));
      });
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _healthTimer?.cancel();
    _healthTimer = null;
    _started = false;
  }

  Future<void> _onResults(List<ConnectivityResult> results) async {
    final seq = ++_probeSeq;
    final online = await _isOnline(results);
    // Faqat eng so'nggi probe natijasini qo'llaymiz.
    if (seq != _probeSeq) return;
    if (online) {
      _dismissNotInternetIfShowing();
    } else {
      unawaited(_openNotInternetIfNeeded());
    }
  }

  static Future<bool> _isOnline(List<ConnectivityResult> results) async {
    if (results.isEmpty) return false;
    if (!results.any((r) => r != ConnectivityResult.none)) {
      return false;
    }
    // connectivity_plus faqat adapter holatini tekshiradi (wifi/mobile mavjudmi).
    // Bu yerda internetga real chiqish bor-yo'qligini ham tekshiramiz.
    try {
      final lookup = await InternetAddress.lookup(
        'infonexuz.uz',
      ).timeout(const Duration(seconds: 2));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openNotInternetIfNeeded() async {
    if (_router.topRoute.name == NotInternetRoute.name) return;
    final ctx = _router.navigatorKey.currentContext;
    if (ctx == null) return;
    await _router.push(NotInternetRoute(onRetry: _onRetry));
  }

  void _dismissNotInternetIfShowing() {
    if (_router.topRoute.name != NotInternetRoute.name) return;
    unawaited(_router.maybePop());
  }

  void _onRetry() {
    unawaited(_retryAsync());
  }

  Future<void> _retryAsync() async {
    final results = await _connectivity.checkConnectivity();
    if (!await _isOnline(results)) return;
    if (_router.topRoute.name != NotInternetRoute.name) return;
    await _router.maybePop();
  }
}
