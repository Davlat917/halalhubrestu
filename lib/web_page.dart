import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/device_registration_service.dart';
import 'package:halal_hub_resto/push_notification_service.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;
  String? accessToken;

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

  @override
  Widget build(BuildContext context) {
    debugPrint("WebViewPage build ishladi");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        debugPrint("back bosildi");

        if (didPop) return;

        if (await _controller?.canGoBack() ?? false) {
          debugPrint("WebView orqaga qaytdi");
          _controller?.goBack();
        } else {
          debugPrint("App yopildi");
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await _readAccessTokenFromWebView();
            final currentFcmToken = PushNotificationHelper.fcmToken;
            final message = 'Access: ${accessToken ?? "yoq"}\nFCM: ${currentFcmToken.isEmpty ? "yoq" : currentFcmToken}';
            debugPrint(message);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          child: const Icon(Icons.vpn_key),
        ),

        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri('https://vendor.wehalalhub.com')),

            onWebViewCreated: (controller) {
              debugPrint("WebView yaratildi");

              _controller = controller;

              controller.addJavaScriptHandler(
                handlerName: "sendToken",
                callback: (args) {
                  debugPrint("JS handler ishladi");

                  if (args.isNotEmpty) {
                    accessToken = args[0] as String?;

                    debugPrint("ACCESS TOKEN OLINDI: $accessToken");
                    DeviceRegistrationService.setAccessToken(accessToken);
                    DeviceRegistrationService.syncDeviceToken(PushNotificationHelper.fcmToken);
                  } else {
                    debugPrint("Token kelmadi");
                  }

                  return {"status": "ok"};
                },
              );
            },

            onLoadStart: (controller, url) {
              debugPrint("Page load start: $url");
            },

            onLoadStop: (controller, url) async {
              debugPrint("Page load stop: $url");
              await _readAccessTokenFromWebView();
            },

            onConsoleMessage: (controller, consoleMessage) {
              debugPrint("JS Console: ${consoleMessage.message}");
            },
          ),
        ),
      ),
    );
  }
}
