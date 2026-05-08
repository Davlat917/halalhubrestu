import 'dart:async';

import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/router/vendor_shell_auto_route_observer.dart';
import 'package:halalhub_restaurant/core/services/deep_link/deep_link_service.dart';
import 'package:halalhub_restaurant/core/services/internet_connectivity_service.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';
import 'package:halalhub_restaurant/core/services/vendor_shell_navigation_service.dart';
import 'package:halalhub_restaurant/core/theme/theme_extension.dart';
import 'package:halalhub_restaurant/core/widgets/dialogs/vendor_new_order_dialog.dart';
import 'package:halalhub_restaurant/core/widgets/display/display_initializer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = getIt<AppRouter>();
  StreamSubscription<VendorWsEvent>? _vendorWsUiSub;
  bool _newOrderDialogOpen = false;
  ValueNotifier<VendorNewOrderDialogVm>? _newOrderDialogVm;
  String? _lastNewOrderDialogKey;
  DateTime? _lastNewOrderDialogAt;

  @override
  void initState() {
    super.initState();
    DisplayInitializer.init(navigatorKey: _router.navigatorKey);
    getIt<DeepLinkService>().init(_router);
    getIt<VendorNotificationsWsService>().start();
    getIt<InternetConnectivityService>().start();
    _vendorWsUiSub = getIt<VendorNotificationsWsService>().events.listen(
      _onVendorWsForGlobalOrderDialog,
    );
  }

  void _onVendorWsForGlobalOrderDialog(VendorWsEvent event) {
    if (event.type != VendorWsEventType.orderCreated) return;
    if (_suppressNewOrderDialogForCurrentScreen()) return;

    if (_newOrderDialogOpen && _newOrderDialogVm != null) {
      _newOrderDialogVm!.value = _newOrderDialogVm!.value.append(event.raw);
      return;
    }

    final key = _newOrderDialogDedupKey(event.raw);
    final now = DateTime.now();
    if (key != null &&
        _lastNewOrderDialogKey == key &&
        _lastNewOrderDialogAt != null &&
        now.difference(_lastNewOrderDialogAt!) < const Duration(seconds: 5)) {
      return;
    }
    _lastNewOrderDialogKey = key;
    _lastNewOrderDialogAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_showGlobalNewOrderDialog(event.raw));
    });
  }

  bool _suppressNewOrderDialogForCurrentScreen() {
    try {
      if (_router.topRoute.name == OrdersRoute.name) return true;
    } catch (_) {}
    return getIt<VendorShellNavigationService>().shouldSuppressNewOrderDialog;
  }

  String? _newOrderDialogDedupKey(Map<String, dynamic> raw) {
    for (final k in ['order_id', 'orderId', 'id', 'order_number', 'orderNumber']) {
      final v = raw[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  Future<void> _navigateToOrdersSection() async {
    final router = _router;
    while (router.canPop()) {
      await router.maybePop();
    }
    final shellNav = getIt<VendorShellNavigationService>();
    if (!shellNav.tryOpenOrdersTab()) {
      await router.replaceAll([const VendorProfileRoute()]);
    }
  }

  Future<void> _showGlobalNewOrderDialog(Map<String, dynamic> raw) async {
    if (_suppressNewOrderDialogForCurrentScreen()) return;

    final ctx = _router.navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final vm = ValueNotifier(VendorNewOrderDialogVm.fromRaw(raw));
    _newOrderDialogVm = vm;
    _newOrderDialogOpen = true;
    try {
      await showVendorNewOrderDialog(
        context: ctx,
        vmNotifier: vm,
        onDismiss: () {
          unawaited(getIt<VendorNotificationsWsService>().stopNewOrderAlertSound());
        },
        onGoToOrders: () => unawaited(_navigateToOrdersSection()),
      );
    } finally {
      _newOrderDialogOpen = false;
      vm.dispose();
      if (identical(_newOrderDialogVm, vm)) {
        _newOrderDialogVm = null;
      }
    }
  }

  @override
  void dispose() {
    _vendorWsUiSub?.cancel();
    getIt<InternetConnectivityService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Halalhub Restaurant",
      routerConfig: _router.config(
        navigatorObservers: vendorShellNavigatorObservers,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: context.lightTheme,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context).copyWith(boldText: false);
        return MediaQuery(data: mediaQuery, child: child!);
      },
    );
  }
}
