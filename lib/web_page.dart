import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halal_hub_resto/controllers/web_view_page_controller.dart';
import 'package:halal_hub_resto/functions/web_view_feedback.dart';
import 'package:halal_hub_resto/widgets/web_view_body.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewPageController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        await showWebViewFailureSnackBar(context, "Internet not available yet");
      case RecoveryResult.failedToLoad:
        await showWebViewFailureSnackBar(
          context,
          "Failed to open page. Please try again.",
        );
    }
  }

  Future<void> _handleBackNavigation() async {
    final shouldExit = await _controller.handleBackNavigation();
    if (!mounted || !shouldExit) {
      return;
    }

    final exitConfirmed = await showExitDialog(context);
    if (exitConfirmed) {
      SystemNavigator.pop();
    }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return WebViewBody(controller: _controller, onRetry: _handleRetry);
          },
        ),
      ),
    );
  }
}
