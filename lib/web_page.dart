import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halal_hub_resto/device_registration_service.dart';
import 'package:halal_hub_resto/push_notification_service.dart';
import 'package:halal_hub_resto/widgets/webview_error_view.dart';
import 'package:halal_hub_resto/widgets/webview_progress_bar.dart';
import 'package:halal_hub_resto/controllers/web_view_page_controller.dart';
import 'package:halal_hub_resto/functions/web_view_feedback.dart';
import 'package:halal_hub_resto/widgets/web_view_body.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  static const String _initialUrl = 'https://vendor.wehalalhub.com';
  final Color primary = const Color(0xFF0DA84A);

  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;
  String? accessToken;
  String? _errorMessage;
  double _progress = 0;
  bool _isWebViewReady = false;
  bool _overlayVisible = true;

  bool get _hasError => _errorMessage != null;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.green.shade700),
      onRefresh: () async {
        await _controller?.reload();
      },
    );
  }

  Future<void> _handleRetry() async {
    final result = await _controller.attemptRecovery(showFailureFeedback: true);
    if (!mounted) {
      return;
    }

    switch (result) {
      case RecoveryResult.success:
        return;
      case RecoveryResult.noInternet:
        await showWebViewFailureSnackBar(context, "Internet hali mavjud emas");
      case RecoveryResult.failedToLoad:
        await showWebViewFailureSnackBar(context, "Sahifani ochib bo'lmadi. Qayta urinib ko'ring.");
    }
  Future<void> _hideOverlay() async {
    if (_isWebViewReady) return;
    setState(() => _isWebViewReady = true);
    // Animatsiya tugagandan keyin widgetni stack'dan olib tashlash
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _overlayVisible = false);
    });
  }

  Future<void> _readAccessTokenFromWebView() async {
    if (_controller == null) return;
    try {
      await _controller!.evaluateJavascript(
        source: """
          const access = window.localStorage.getItem('access');
          window.flutter_inappwebview.callHandler('sendToken', access ?? 'Token topilmadi');
        """,
      );
    } catch (e) {
      debugPrint("Token olishda xato: $e");
    }
  }

  Future<void> _retryLoad() async {
    setState(() {
      _errorMessage = null;
      _progress = 0.15;
      _isWebViewReady = false;
      _overlayVisible = true;
    });
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(_initialUrl)));
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ilovadan chiqilsinmi?'),
          content: const Text('Orqaga qaytish uchun sahifalar qolmadi. Ilovani yopishni xohlaysizmi?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Chiqish')),
          ],
        );
      },
    );
    if (shouldExit == true) SystemNavigator.pop();
  }

  Future<void> _handleBackNavigation() async {
    final shouldExit = await _controller.handleBackNavigation();
    if (!mounted || !shouldExit) {
      return;
    }
    if (!mounted) return;
    await _showExitDialog();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _handleBackNavigation();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // ── WebView ──────────────────────────────────────────
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
                pullToRefreshController: _pullToRefreshController,
                initialSettings: InAppWebViewSettings(javaScriptEnabled: true, allowsBackForwardNavigationGestures: true, mediaPlaybackRequiresUserGesture: false, supportZoom: false, transparentBackground: false),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  controller.addJavaScriptHandler(
                    handlerName: "sendToken",
                    callback: (args) {
                      if (args.isNotEmpty) {
                        accessToken = args[0] as String?;
                        DeviceRegistrationService.setAccessToken(accessToken);
                        DeviceRegistrationService.syncDeviceToken(PushNotificationHelper.fcmToken);
                      }
                      return {"status": "ok"};
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _errorMessage = null;
                    _progress = 0.15;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) _pullToRefreshController?.endRefreshing();
                  setState(() => _progress = progress / 100);
                },
                onLoadStop: (controller, url) async {
                  _pullToRefreshController?.endRefreshing();
                  setState(() {
                    _progress = 1;
                    _errorMessage = null;
                  });
                  await _readAccessTokenFromWebView();
                  await _hideOverlay();
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame ?? false) {
                    _pullToRefreshController?.endRefreshing();
                    setState(() {
                      _errorMessage = error.description;
                      _progress = 0;
                    });
                    _hideOverlay();
                  }
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  if (request.isForMainFrame ?? false) {
                    _pullToRefreshController?.endRefreshing();
                    setState(() {
                      _errorMessage = 'HTTP ${errorResponse.statusCode} xatolik yuz berdi.';
                      _progress = 0;
                    });
                    _hideOverlay();
                  }
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint("JS Console: ${consoleMessage.message}");
                },
              ),

              // ── Progress Bar ──────────────────────────────────────
              Align(
                alignment: Alignment.topCenter,
                child: WebViewProgressBar(progress: _progress),
              ),

              // ── Error View ────────────────────────────────────────
              if (_hasError) WebViewErrorView(message: _errorMessage ?? "Internet aloqasini tekshirib, qayta urinib ko'ring.", onRetry: _retryLoad),

              // ── Loading Overlay ───────────────────────────────────
              if (_overlayVisible)
                AnimatedOpacity(
                  opacity: _isWebViewReady ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  child: Container(
                    color: primary,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8), //\
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: SvgPicture.asset(
                                "assets/icons/brand_logo.svg",
                                fit: BoxFit.cover, //
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'HalalHub Restaurant',
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 8),
                          const Text('Halol taomlar dünyosi', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 48),
                          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
