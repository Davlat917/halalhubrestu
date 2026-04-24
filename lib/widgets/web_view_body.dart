import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/controllers/web_view_page_controller.dart';
import 'package:halal_hub_resto/widgets/not_internet_page.dart';
import 'package:halal_hub_resto/widgets/web_view_loading_overlay.dart';
import 'package:halal_hub_resto/widgets/webview_progress_bar.dart';

class WebViewBody extends StatelessWidget {
  const WebViewBody({required this.controller, required this.onRetry, super.key});

  final WebViewPageController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (!controller.isCheckingConnection)
          SafeArea(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(WebViewPageController.initialUrl)),
              pullToRefreshController: controller.pullToRefreshController,
              onUpdateVisitedHistory: controller.onUpdateVisitedHistory,
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                useHybridComposition: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                cacheEnabled: true,
                thirdPartyCookiesEnabled: true,
                clearCache: false,
                clearSessionCache: false,
                allowsBackForwardNavigationGestures: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: false,
                supportMultipleWindows: true,
                transparentBackground: false,
                disableDefaultErrorPage: true,
                useShouldOverrideUrlLoading: true,
                geolocationEnabled: true,
                allowUniversalAccessFromFileURLs: true,
              ),
              onWebViewCreated: controller.onWebViewCreated,
              onLoadStart: controller.onLoadStart,
              onLoadStop: controller.onLoadStop,
              onProgressChanged: controller.onProgressChanged,
              onReceivedError: controller.onReceivedError,
              onReceivedHttpError: controller.onReceivedHttpError,
              shouldOverrideUrlLoading: controller.onShouldOverrideUrlLoading,
              onCreateWindow: controller.onCreateWindow,
              onConsoleMessage: (webController, consoleMessage) {
                if (kDebugMode) {
                  debugPrint('JS Console: ${consoleMessage.message}');
                }
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: true);
              },
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: WebViewProgressBar(progress: controller.progress),
        ),
        if (controller.showNotInternetPage) NotInternetPage(onRetry: onRetry, isLoading: controller.isRetrying),
        WebViewLoadingOverlay(visible: controller.showInitialOverlay),
      ],
    );
  }
}
