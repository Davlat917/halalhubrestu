import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Deep link service — app_links + auto_route
///
/// Qo'llab-quvvatlanadigan linklar:
///   Custom scheme:   myapp://product/123
///   Universal Link:  https://yourdomain.com/product/123


@singleton
class DeepLinkService {
  DeepLinkService(this._appLinks);

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  void _log(String message) {
    if (kDebugMode) debugPrint('[DeepLink] $message');
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init(AppRouter router) async {
    // 1. Ilova yopiq bo'lganida kelgan link (cold start)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(router, initialLink);
    }

    // 2. Ilova ochiq bo'lganida kelgan link (warm start)
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleLink(router, uri),
      onError: (err) => _log('Error: $err'),
    );
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ─── Handler ──────────────────────────────────────────────────────────────

  void _handleLink(AppRouter router, Uri uri) {
    _log('uri: $uri');
    _log('scheme: ${uri.scheme}');
    _log('host: ${uri.host}');
    _log('segments: ${uri.pathSegments}');
    _log('params: ${uri.queryParameters}');

    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    switch (segments.first) {
      case 'test':
        // final id = segments.length > 1 ? segments[1] : '0';
        // router.push(AllComponentsRoute(id: id)); // ← faqat shu
        break;
      default:
        _log('Unknown: ${segments.first}');
    }
  }
}
