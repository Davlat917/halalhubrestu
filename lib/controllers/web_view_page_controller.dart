import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/device_registration_service.dart';
import 'package:halal_hub_resto/push_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

enum RecoveryResult { success, noInternet, failedToLoad }

class WebViewPageController extends ChangeNotifier {
  WebViewPageController();

  static const String initialUrl = 'https://vendor.wehalalhub.com';
  static const String _host = 'vendor.wehalalhub.com';

  InAppWebViewController? _webViewController;
  Timer? _internetTimer;
  Completer<bool>? _reloadCompleter;

  String? _errorMessage;
  double _progress = 0;
  bool _hasMainFrameError = false;
  bool _isConnected = true;
  bool _isCheckingConnection = true;
  bool _isRetrying = false;
  bool _showInitialOverlay = true;

  bool _pageFullyLoaded = false;

  PullToRefreshController? pullToRefreshController;

  String? get errorMessage => _errorMessage;
  double get progress => _progress;
  bool get isCheckingConnection => _isCheckingConnection;
  bool get isRetrying => _isRetrying;
  bool get showNotInternetPage => !_isConnected || _errorMessage != null;
  bool get showInitialOverlay => _showInitialOverlay;

  void onUpdateVisitedHistory(
    InAppWebViewController controller,
    WebUri? url,
    bool? isReload,
  ) {
    final urlStr = url?.toString() ?? '';
    final isAuthPage = urlStr.contains('/auth/') || urlStr.contains('/login');

    if (isAuthPage || urlStr.isEmpty) return;

    // Only after the first full load (SPA navigation).
    if (!_pageFullyLoaded) {
      if (kDebugMode) {
        debugPrint('⏭️ [HISTORY] Page not loaded yet → skip ($urlStr)');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📍 [HISTORY] SPA navigation → read token: $urlStr');
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      _readAccessTokenFromWebView();
    });
  }

  void initialize() {
    if (kDebugMode) {
      debugPrint('🟢 [INIT] WebViewPageController.initialize started');
    }
    _requestLocationPermission();
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.green.shade700),
      onRefresh: _handlePullToRefresh,
    );

    unawaited(checkInternet());
    _internetTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(checkInternet());
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (kDebugMode) {
      debugPrint('📍 [PERMISSION] Location permission: $status');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('🔴 [DISPOSE] WebViewPageController.dispose');
    }
    _internetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePullToRefresh() async {
    if (kDebugMode) {
      debugPrint('🔄 [PULL_REFRESH] Pull to refresh started');
    }
    await attemptRecovery(showFailureFeedback: false);
  }

  Future<void> checkInternet() async {
    final hasInternet = await _hasInternetAccess();
    final previousConnection = _isConnected;

    if (kDebugMode) {
      debugPrint(
        '🌐 [INTERNET] Checked → hasInternet=$hasInternet | previousConnection=$previousConnection',
      );
    }

    _isConnected = hasInternet;
    _isCheckingConnection = false;

    if (!hasInternet) {
      _hasMainFrameError = true;
      _errorMessage = 'Internet unavailable';
      _progress = 0;
      _showInitialOverlay = false;
      if (kDebugMode) {
        debugPrint('❌ [INTERNET] Offline → error state set');
      }
      notifyListeners();
      return;
    }

    notifyListeners();

    if (!previousConnection) {
      if (kDebugMode) {
        debugPrint('🔁 [INTERNET] Was offline, now online → attemptRecovery');
      }
      await attemptRecovery(showFailureFeedback: false);
    }
  }

  Future<RecoveryResult> attemptRecovery({
    required bool showFailureFeedback,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔁 [RECOVERY] attemptRecovery started | isRetrying=$_isRetrying',
      );
    }

    if (_isRetrying) {
      if (kDebugMode) {
        debugPrint('⚠️ [RECOVERY] Retry already in progress → skip');
      }
      return RecoveryResult.failedToLoad;
    }

    _isRetrying = true;
    notifyListeners();

    final hasInternet = await _hasInternetAccess();
    if (kDebugMode) {
      debugPrint('🌐 [RECOVERY] Internet check → $hasInternet');
    }

    if (!hasInternet) {
      _isConnected = false;
      _isRetrying = false;
      _hasMainFrameError = true;
      _errorMessage = 'Internet unavailable';
      _progress = 0;
      if (kDebugMode) {
        debugPrint('❌ [RECOVERY] Offline → noInternet');
      }
      notifyListeners();
      return RecoveryResult.noInternet;
    }

    _reloadCompleter = Completer<bool>();
    await _reloadWebView();

    bool loadedSuccessfully = false;
    try {
      if (kDebugMode) {
        debugPrint('⏳ [RECOVERY] Waiting for reload (12s timeout)...');
      }
      loadedSuccessfully = await _reloadCompleter!.future.timeout(
        const Duration(seconds: 12),
      );
      if (kDebugMode) {
        debugPrint('✅ [RECOVERY] Reload result: $loadedSuccessfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RECOVERY] Timeout or error: $e');
      }
      loadedSuccessfully = false;
    }

    _isRetrying = false;
    _isConnected = loadedSuccessfully;

    if (loadedSuccessfully) {
      _hasMainFrameError = false;
      _errorMessage = null;
      _showInitialOverlay = false;
      if (kDebugMode) {
        debugPrint('✅ [RECOVERY] Loaded successfully');
      }
    } else {
      _hasMainFrameError = true;
      _errorMessage = 'Unable to open page';
      _progress = 0;
      _showInitialOverlay = false;
      if (kDebugMode) {
        debugPrint('❌ [RECOVERY] Failed to load → failedToLoad');
      }
    }

    notifyListeners();
    return loadedSuccessfully
        ? RecoveryResult.success
        : RecoveryResult.failedToLoad;
  }

  Future<bool> handleBackNavigation() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;
    if (kDebugMode) {
      debugPrint('🔙 [BACK] canGoBack=$canGoBack');
    }
    if (canGoBack) {
      await _webViewController?.goBack();
      return false;
    }
    return true;
  }

  void onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    if (kDebugMode) {
      debugPrint('🟢 [WEBVIEW] WebView created');
      debugPrint('🧩 [BRIDGE] Registering JS handlers...');
    }

    controller.addJavaScriptHandler(
      handlerName: 'sendToken',
      callback: (args) {
        if (kDebugMode) {
          debugPrint('📨 [JS_HANDLER] sendToken | args: $args');
        }

        if (args.isNotEmpty) {
          final accessToken = args[0] as String?;
          final preview = accessToken != null && accessToken.length > 10
              ? accessToken.substring(0, 10)
              : accessToken;
          if (kDebugMode) {
            debugPrint('🔑 [TOKEN] Received → "$preview..."');
          }

          if (accessToken != null &&
              accessToken.isNotEmpty &&
              accessToken != kAccessTokenNotFoundPlaceholder) {
            if (kDebugMode) {
              debugPrint(
                '✅ [TOKEN] Valid token → setAccessToken + syncDeviceToken',
              );
            }
            DeviceRegistrationService.setAccessToken(accessToken);
            DeviceRegistrationService.syncDeviceToken(
              PushNotificationHelper.fcmToken,
            );
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [TOKEN] Empty or placeholder "$kAccessTokenNotFoundPlaceholder" → skip',
              );
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ [JS_HANDLER] Empty args');
          }
        }

        return <String, String>{'status': 'ok'};
      },
    );

    if (kDebugMode) {
      debugPrint('🧩 [BRIDGE] Handlers ready: sendToken');
    }
  }

  void onLoadStart(InAppWebViewController controller, WebUri? url) {
    if (kDebugMode) {
      debugPrint('🔵 [LOAD_START] URL: $url');
    }
    _pageFullyLoaded = false;
    _hasMainFrameError = false;
    _errorMessage = null;
    _progress = 0.15;
    notifyListeners();
  }

  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final uri = action.request.url?.uriValue;
    if (kDebugMode) {
      debugPrint(
        '🔀 [NAV] shouldOverrideUrlLoading → $uri | isMainFrame=${action.isForMainFrame}',
      );
    }

    if (uri == null) return NavigationActionPolicy.ALLOW;

    if (_isGoogleAuthUrl(uri)) {
      if (kDebugMode) {
        debugPrint('🔐 [NAV] Google Auth URL → opening in external browser');
      }
      final launched = await _launchExternal(uri);
      return launched
          ? NavigationActionPolicy.CANCEL
          : NavigationActionPolicy.ALLOW;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<bool> onCreateWindow(
    InAppWebViewController controller,
    CreateWindowAction action,
  ) async {
    final uri = action.request.url?.uriValue;
    if (kDebugMode) {
      debugPrint('🪟 [WINDOW] onCreateWindow → $uri');
    }

    if (uri != null && _isGoogleAuthUrl(uri)) {
      if (kDebugMode) {
        debugPrint('🔐 [WINDOW] Google Auth → opening externally');
      }
      await _launchExternal(uri);
      return false;
    }

    if (action.request.url != null) {
      if (kDebugMode) {
        debugPrint('🪟 [WINDOW] Loading in same WebView');
      }
      await controller.loadUrl(urlRequest: action.request);
    }

    return false;
  }

  Future<void> onLoadStop(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    _pageFullyLoaded = true;
    final urlStr = url?.toString() ?? '';
    if (kDebugMode) {
      debugPrint('🟢 [LOAD_STOP] URL: $urlStr');
      debugPrint(
        '   └─ hasMainFrameError=$_hasMainFrameError | isConnected=$_isConnected',
      );
    }

    pullToRefreshController?.endRefreshing();

    _isConnected = true;
    _progress = 1;
    if (!_hasMainFrameError) {
      _errorMessage = null;
    }
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      if (kDebugMode) {
        debugPrint('✅ [LOAD_STOP] reloadCompleter completed (true)');
      }
      _reloadCompleter!.complete(true);
    }

    notifyListeners();

    // Bridge must exist on every page (including login).
    await _injectFlutterBridgeFlags();

    if (_hasMainFrameError) {
      if (kDebugMode) {
        debugPrint('⚠️ [LOAD_STOP] hasMainFrameError=true → skip token read');
      }
      return;
    }

    // Do not read token on auth pages.
    final isAuthPage = urlStr.contains('/auth/') || urlStr.contains('/login');
    if (kDebugMode) {
      debugPrint('   └─ isAuthPage=$isAuthPage');
    }

    if (isAuthPage) {
      if (kDebugMode) {
        debugPrint('🔒 [LOAD_STOP] Login page → skip token read');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔑 [LOAD_STOP] Starting token read...');
    }
    await _readAccessTokenFromWebView();
  }

  void onProgressChanged(InAppWebViewController controller, int progress) {
    if (kDebugMode) {
      debugPrint('📊 [PROGRESS] $progress%');
    }
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    _progress = progress / 100;
    notifyListeners();
  }

  void onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    final isMain = request.isForMainFrame ?? false;
    if (kDebugMode) {
      debugPrint(
        '❌ [ERROR] isMainFrame=$isMain | code=${error.type} | desc=${error.description} | url=${request.url}',
      );
    }

    if (!isMain) {
      if (kDebugMode) {
        debugPrint('   └─ Sub-frame error → ignore');
      }
      return;
    }

    pullToRefreshController?.endRefreshing();
    _isConnected = false;
    _hasMainFrameError = true;
    _errorMessage = error.description;
    _progress = 0;
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      if (kDebugMode) {
        debugPrint('❌ [ERROR] reloadCompleter completed (false)');
      }
      _reloadCompleter!.complete(false);
    }

    notifyListeners();
  }

  void onReceivedHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    final isMain = request.isForMainFrame ?? false;
    if (kDebugMode) {
      debugPrint(
        '❌ [HTTP_ERROR] isMainFrame=$isMain | status=${errorResponse.statusCode} | url=${request.url}',
      );
    }

    if (!isMain) {
      if (kDebugMode) {
        debugPrint('   └─ Sub-frame HTTP error → ignore');
      }
      return;
    }

    pullToRefreshController?.endRefreshing();
    _isConnected = false;
    _hasMainFrameError = true;
    _errorMessage = 'HTTP ${errorResponse.statusCode} error occurred.';
    _progress = 0;
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      if (kDebugMode) {
        debugPrint('❌ [HTTP_ERROR] reloadCompleter completed (false)');
      }
      _reloadCompleter!.complete(false);
    }

    notifyListeners();
  }

  Future<void> _reloadWebView() async {
    if (kDebugMode) {
      debugPrint('🔄 [RELOAD] _reloadWebView started');
    }
    if (_webViewController == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [RELOAD] WebViewController null → skip');
      }
      return;
    }

    _hasMainFrameError = false;
    _errorMessage = null;
    _progress = 0.15;
    notifyListeners();

    final currentUrl = await _webViewController!.getUrl();
    if (kDebugMode) {
      debugPrint('🔄 [RELOAD] Current URL: $currentUrl');
    }

    if (currentUrl != null) {
      if (kDebugMode) {
        debugPrint('🔄 [RELOAD] reload()');
      }
      await _webViewController!.reload();
    } else {
      if (kDebugMode) {
        debugPrint('🔄 [RELOAD] No URL → load initialUrl');
      }
      await _webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(initialUrl)),
      );
    }
  }

  Future<void> _readAccessTokenFromWebView() async {
    if (kDebugMode) {
      debugPrint('🔑 [TOKEN_READ] _readAccessTokenFromWebView started');
    }

    if (_webViewController == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [TOKEN_READ] WebViewController null → skip');
      }
      return;
    }

    try {
      final currentUrl = await _webViewController!.getUrl();
      final host = currentUrl?.host;
      if (kDebugMode) {
        debugPrint('🔑 [TOKEN_READ] Current URL: $currentUrl | host: $host');
      }

      if (host == null || !_isAllowedTokenHost(host)) {
        if (kDebugMode) {
          debugPrint('⚠️ [TOKEN_READ] Host not allowed → skip');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('🔑 [TOKEN_READ] localStorage dump starting...');
      }
      await _webViewController!.evaluateJavascript(
        source: '''
        (function() {
          console.log("=== localStorage DUMP ===");
          for (var i = 0; i < localStorage.length; i++) {
            var key = localStorage.key(i);
            var val = localStorage.getItem(key);
            var preview = val ? val.substring(0, 40) : "null";
            console.log("  [" + i + "] " + key + " = " + preview);
          }
          console.log("=== localStorage COUNT: " + localStorage.length + " ===");

          var access = localStorage.getItem('access');
          console.log("'access' key: " + access);
          window.flutter_inappwebview.callHandler('sendToken', access ?? '$kAccessTokenNotFoundPlaceholder');
        })();
        ''',
      );
      if (kDebugMode) {
        debugPrint('🔑 [TOKEN_READ] evaluateJavascript finished');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TOKEN_READ] Error: $e');
      }
    }
  }

  Future<void> _injectFlutterBridgeFlags() async {
    if (_webViewController == null) return;
    try {
      await _webViewController!.evaluateJavascript(
        source: r'''
        (function () {
          window.__HALALHUB_FLUTTER_APP__ = true;
          window.dispatchEvent(new CustomEvent('halalhub-native-ready'));
        })();
        ''',
      );
      if (kDebugMode) {
        debugPrint('🧩 [BRIDGE] Native bridge flags injected');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [BRIDGE] inject error: $e');
      }
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup(_host);
      final ok = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      return ok;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [INTERNET_CHECK] lookup error: $e');
      }
      return false;
    }
  }

  bool _isGoogleAuthUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'accounts.google.com' || host == 'oauth2.googleapis.com') {
      return true;
    }
    if (host.endsWith('.google.com') && uri.path.contains('o/oauth2')) {
      return true;
    }
    return false;
  }

  bool _isAllowedTokenHost(String host) {
    final normalized = host.toLowerCase();
    return normalized.contains('wehalalhub.com') ||
        normalized.contains('h-hub-lake.vercel.app');
  }

  Future<bool> _launchExternal(Uri uri) async {
    if (kDebugMode) {
      debugPrint('🌍 [EXTERNAL] Opening in external browser: $uri');
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [EXTERNAL] launchUrl error: $e');
      }
      return false;
    }
  }
}
