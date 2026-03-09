import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // biz o‘zimiz boshqaramiz
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (await _controller?.canGoBack() ?? false) {
          _controller?.goBack();
        } else {
          SystemNavigator.pop(); // app’dan chiqish
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://vendor.wehalalhub.com'),
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
          ),
        ),
      ),
    );
  }
}

class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Internet yo‘q',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WebViewPage()),
            ),
            child: const Text('Qayta urinish'),
          )
        ],
      ),
    );
  }
}
