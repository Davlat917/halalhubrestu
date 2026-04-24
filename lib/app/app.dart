import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/services/deep_link/deep_link_service.dart';
import 'package:halalhub_restaurant/core/services/internet_connectivity_service.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';
import 'package:halalhub_restaurant/core/theme/theme_extension.dart';
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

  @override
  void initState() {
    super.initState();
    DisplayInitializer.init(navigatorKey: _router.navigatorKey);
    getIt<DeepLinkService>().init(_router);
    getIt<VendorNotificationsWsService>().start();
    getIt<InternetConnectivityService>().start();
  }

  @override
  void dispose() {
    getIt<InternetConnectivityService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Halalhub Restaurant",
      routerConfig: _router.config(),
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
