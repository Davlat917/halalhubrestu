import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// [VendorProfileScaffold] dagi [AutoRouteAwareStateMixin] uchun.
///
/// [NavigatorObserver] bitta [Navigator] bilan bog‘langan bo‘ladi; nested
/// [AutoRouter] parent observerlarni meros qiladi — singleton ishlatish
/// mumkin emas (`observer.navigator == null` assert).
NavigatorObserversBuilder get vendorShellNavigatorObservers =>
    () => <NavigatorObserver>[AutoRouteObserver()];
