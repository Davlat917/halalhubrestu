import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/router/startup_frame_gate.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';

/// App start oqimi:
/// - token yo'q => auth/sign-in
/// - token bor + vendor active => main profile
/// - token bor + vendor inactive/yoki yo'q => create/pending
class StartupGuard extends AutoRouteGuard {
  void _log(String message) {
    debugPrint('[StartupGuard] $message');
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final sw = Stopwatch()..start();
    _log('onNavigation start route=${resolver.route.name}');
    final token = getIt<Storage>().token.call();
    final refresh = getIt<Storage>().refreshToken.call();
    final isAuthed =
        (token != null && token.isNotEmpty) ||
        (refresh != null && refresh.isNotEmpty);
    _log(
      'auth check: token=${token?.isNotEmpty == true}, refresh=${refresh?.isNotEmpty == true}, isAuthed=$isAuthed',
    );

    if (!isAuthed) {
      _log('redirect -> AuthFlowRoute(SignInRoute)');
      await router.replaceAll([
        const AuthFlowRoute(children: [SignInRoute()]),
      ]);
      _log('done in ${sw.elapsedMilliseconds}ms');
      StartupFrameGate.open();
      resolver.next(false);
      return;
    }

    try {
      _log('requesting /vendors/me ...');
      final vendor = await getIt<RestaurantRepo>().getVendorMe();
      _log(
        'vendors/me ok: id=${vendor.id}, isActive=${vendor.isActive}, elapsed=${sw.elapsedMilliseconds}ms',
      );
      if (vendor.isActive == true) {
        _log('redirect -> VendorProfileRoute');
        await router.replaceAll([const VendorProfileRoute()]);
      } else {
        _log('redirect -> CreateRestaurantRoute (pending/create)');
        await router.replaceAll([CreateRestaurantRoute()]);
      }
    } catch (e) {
      final code = e is NetworkException ? e.statusCode : null;
      final msg = e is NetworkException ? e.message.toLowerCase() : '';
      _log('vendors/me failed: code=$code, error=$e');
      final isInactive401 =
          code == 401 &&
          (msg.contains('inactive') || msg.contains('user_inactive'));
      if (code == 400 || code == 404 || isInactive401) {
        _log('redirect -> CreateRestaurantRoute for code=$code inactive=$isInactive401');
        await router.replaceAll([CreateRestaurantRoute()]);
      } else if (code == 401) {
        _log('redirect -> AuthFlowRoute(SignInRoute) for expired auth');
        await router.replaceAll([
          const AuthFlowRoute(children: [SignInRoute()]),
        ]);
      } else if ((code ?? 0) >= 500) {
        _log('redirect -> ServerErrorRoute');
        await router.replaceAll([const ServerErrorRoute()]);
      } else {
        _log('redirect -> DefaultFallbackRoute');
        await router.replaceAll([const DefaultFallbackRoute()]);
      }
    }

    _log('onNavigation done in ${sw.elapsedMilliseconds}ms');
    StartupFrameGate.open();
    resolver.next(false);
  }
}
