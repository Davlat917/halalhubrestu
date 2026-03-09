import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/device_registration_service.dart';
import 'package:halal_hub_resto/push_notification_service.dart';
import 'package:halal_hub_resto/widgets/webview_error_view.dart';
import 'package:halal_hub_resto/widgets/webview_progress_bar.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  static const String _initialUrl = 'https://vendor.wehalalhub.com';

  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;
  String? accessToken;
  String? _errorMessage;
  double _progress = 0;

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

  Future<void> _readAccessTokenFromWebView() async {
    if (_controller == null) {
      return;
    }

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
    });

    await _controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_initialUrl)),
    );
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ilovadan chiqilsinmi?'),
          content: const Text('Orqaga qaytish uchun sahifalar qolmadi. Ilovani yopishni xohlaysizmi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Chiqish'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  Future<void> _handleBackNavigation() async {
    if (await _controller?.canGoBack() ?? false) {
      await _controller?.goBack();
      return;
    }

    if (!mounted) {
      return;
    }

    await _showExitDialog();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
                pullToRefreshController: _pullToRefreshController,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  allowsBackForwardNavigationGestures: true,
                  mediaPlaybackRequiresUserGesture: false,
                  supportZoom: false,
                  transparentBackground: false,
                ),
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
                  if (progress == 100) {
                    _pullToRefreshController?.endRefreshing();
                  }

                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onLoadStop: (controller, url) async {
                  _pullToRefreshController?.endRefreshing();
                  setState(() {
                    _progress = 1;
                    _errorMessage = null;
                  });
                  await _readAccessTokenFromWebView();
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame ?? false) {
                    _pullToRefreshController?.endRefreshing();
                    setState(() {
                      _errorMessage = error.description;
                      _progress = 0;
                    });
                  }
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  if (request.isForMainFrame ?? false) {
                    _pullToRefreshController?.endRefreshing();
                    setState(() {
                      _errorMessage = 'HTTP ${errorResponse.statusCode} xatolik yuz berdi.';
                      _progress = 0;
                    });
                  }
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint("JS Console: ${consoleMessage.message}");
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: WebViewProgressBar(progress: _progress),
              ),
              if (_hasError)
                WebViewErrorView(
                  message: _errorMessage ?? 'Internet aloqasini tekshirib, qayta urinib ko‘ring.',
                  onRetry: _retryLoad,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
