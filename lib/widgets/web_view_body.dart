import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:halal_hub_resto/controllers/web_view_page_controller.dart';
import 'package:halal_hub_resto/widgets/not_internet_page.dart';
import 'package:halal_hub_resto/widgets/webview_progress_bar.dart';

class WebViewBody extends StatelessWidget {
  const WebViewBody({
    required this.controller,
    required this.onRetry,
    super.key,
  });

  final WebViewPageController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (!controller.isCheckingConnection)
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(WebViewPageController.initialUrl)),
            pullToRefreshController: controller.pullToRefreshController,
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              allowsBackForwardNavigationGestures: true,
              mediaPlaybackRequiresUserGesture: false,
              supportZoom: false,
              transparentBackground: false,
              disableDefaultErrorPage: true,
            ),
            onWebViewCreated: controller.onWebViewCreated,
            onLoadStart: controller.onLoadStart,
            onLoadStop: controller.onLoadStop,
            onProgressChanged: controller.onProgressChanged,
            onReceivedError: controller.onReceivedError,
            onReceivedHttpError: controller.onReceivedHttpError,
            onConsoleMessage: (webController, consoleMessage) {
              debugPrint('JS Console: ${consoleMessage.message}');
            },
          ),
        Align(
          alignment: Alignment.topCenter,
          child: WebViewProgressBar(progress: controller.progress),
        ),
        if (controller.showNotInternetPage)
          NotInternetPage(
            onRetry: onRetry,
            isLoading: controller.isRetrying,
          ),
      ],
    );
  }
}
