import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/device_registration_service.dart';
import 'package:halal_hub_resto/push_notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum RecoveryResult {
  success,
  noInternet,
  failedToLoad,
}

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

  PullToRefreshController? pullToRefreshController;

  String? get errorMessage => _errorMessage;
  double get progress => _progress;
  bool get isCheckingConnection => _isCheckingConnection;
  bool get isRetrying => _isRetrying;
  bool get showNotInternetPage => !_isConnected || _errorMessage != null;
  bool get showInitialOverlay => _showInitialOverlay;

  void initialize() {
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.green.shade700),
      onRefresh: _handlePullToRefresh,
    );

    unawaited(checkInternet());
    _internetTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(checkInternet());
    });
  }

  @override
  void dispose() {
    _internetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePullToRefresh() async {
    await attemptRecovery(showFailureFeedback: false);
  }

  Future<void> checkInternet() async {
    final hasInternet = await _hasInternetAccess();
    final previousConnection = _isConnected;

    _isConnected = hasInternet;
    _isCheckingConnection = false;

    if (!hasInternet) {
      _hasMainFrameError = true;
      _errorMessage = 'Internet mavjud emas';
      _progress = 0;
      _showInitialOverlay = false;
      notifyListeners();
      return;
    }

    notifyListeners();

    if (!previousConnection) {
      await attemptRecovery(showFailureFeedback: false);
    }
  }

  Future<RecoveryResult> attemptRecovery({required bool showFailureFeedback}) async {
    if (_isRetrying) {
      return RecoveryResult.failedToLoad;
    }

    _isRetrying = true;
    notifyListeners();

    final hasInternet = await _hasInternetAccess();
    if (!hasInternet) {
      _isConnected = false;
      _isRetrying = false;
      _hasMainFrameError = true;
      _errorMessage = 'Internet mavjud emas';
      _progress = 0;
      notifyListeners();
      return RecoveryResult.noInternet;
    }

    _reloadCompleter = Completer<bool>();
    await _reloadWebView();

    bool loadedSuccessfully = false;
    try {
      loadedSuccessfully = await _reloadCompleter!.future.timeout(const Duration(seconds: 12));
    } catch (_) {
      loadedSuccessfully = false;
    }

    _isRetrying = false;
    _isConnected = loadedSuccessfully;

    if (loadedSuccessfully) {
      _hasMainFrameError = false;
      _errorMessage = null;
      _showInitialOverlay = false;
    } else {
      _hasMainFrameError = true;
      _errorMessage = 'Sahifa ochilmadi';
      _progress = 0;
      _showInitialOverlay = false;
    }

    notifyListeners();
    return loadedSuccessfully ? RecoveryResult.success : RecoveryResult.failedToLoad;
  }

  Future<bool> handleBackNavigation() async {
    if (await _webViewController?.canGoBack() ?? false) {
      await _webViewController?.goBack();
      return false;
    }

    return true;
  }

  void onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    controller.addJavaScriptHandler(
      handlerName: 'sendToken',
      callback: (args) {
        if (args.isNotEmpty) {
          final accessToken = args[0] as String?;
          DeviceRegistrationService.setAccessToken(accessToken);
          DeviceRegistrationService.syncDeviceToken(PushNotificationHelper.fcmToken);
        }

        return <String, String>{'status': 'ok'};
      },
    );
  }

  void onLoadStart(InAppWebViewController controller, WebUri? url) {
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
    if (uri == null) {
      return NavigationActionPolicy.ALLOW;
    }

    if (_isGoogleAuthUrl(uri)) {
      final launched = await _launchExternal(uri);
      return launched ? NavigationActionPolicy.CANCEL : NavigationActionPolicy.ALLOW;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<bool> onCreateWindow(
    InAppWebViewController controller,
    CreateWindowAction action,
  ) async {
    final uri = action.request.url?.uriValue;
    if (uri != null && _isGoogleAuthUrl(uri)) {
      await _launchExternal(uri);
      return false;
    }

    if (action.request.url != null) {
      await controller.loadUrl(urlRequest: action.request);
    }

    return false;
  }

  Future<void> onLoadStop(InAppWebViewController controller, WebUri? url) async {
    pullToRefreshController?.endRefreshing();

    _isConnected = true;
    _progress = 1;
    if (!_hasMainFrameError) {
      _errorMessage = null;
    }
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      _reloadCompleter!.complete(true);
    }

    notifyListeners();

    if (_hasMainFrameError) {
      return;
    }

    await _readAccessTokenFromWebView();
  }

  void onProgressChanged(InAppWebViewController controller, int progress) {
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
    if (!(request.isForMainFrame ?? false)) {
      return;
    }

    pullToRefreshController?.endRefreshing();
    _isConnected = false;
    _hasMainFrameError = true;
    _errorMessage = error.description;
    _progress = 0;
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      _reloadCompleter!.complete(false);
    }

    notifyListeners();
  }

  void onReceivedHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    if (!(request.isForMainFrame ?? false)) {
      return;
    }

    pullToRefreshController?.endRefreshing();
    _isConnected = false;
    _hasMainFrameError = true;
    _errorMessage = 'HTTP ${errorResponse.statusCode} xatolik yuz berdi.';
    _progress = 0;
    _showInitialOverlay = false;

    if (_reloadCompleter != null && !_reloadCompleter!.isCompleted) {
      _reloadCompleter!.complete(false);
    }

    notifyListeners();
  }

  Future<void> _reloadWebView() async {
    if (_webViewController == null) {
      return;
    }

    _hasMainFrameError = false;
    _errorMessage = null;
    _progress = 0.15;
    notifyListeners();

    await _webViewController!.loadUrl(
      urlRequest: URLRequest(url: WebUri(initialUrl)),
    );
  }

  Future<void> _readAccessTokenFromWebView() async {
    if (_webViewController == null) {
      return;
    }

    try {
      final currentUrl = await _webViewController!.getUrl();
      final host = currentUrl?.host;
      if (host == null || !host.contains('wehalalhub.com')) {
        return;
      }

      await _webViewController!.evaluateJavascript(
        source: '''
          const access = window.localStorage.getItem('access');
          window.flutter_inappwebview.callHandler('sendToken', access ?? 'Token topilmadi');
        ''',
      );
    } catch (e) {
      debugPrint("Token olishda xato: $e");
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup(_host);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
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

  Future<bool> _launchExternal(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
