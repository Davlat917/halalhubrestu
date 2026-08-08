// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_links/app_links.dart' as _i327;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:halalhub_restaurant/core/app_version/app_version_repository.dart'
    as _i676;
import 'package:halalhub_restaurant/core/app_version/app_version_repository_impl.dart'
    as _i407;
import 'package:halalhub_restaurant/core/di/app_module.dart' as _i810;
import 'package:halalhub_restaurant/core/di/network_module.dart' as _i231;
import 'package:halalhub_restaurant/core/network/auth_interceptor/auth_interceptor.dart'
    as _i1048;
import 'package:halalhub_restaurant/core/router/app_router.dart' as _i571;
import 'package:halalhub_restaurant/core/services/deep_link/deep_link_service.dart'
    as _i829;
import 'package:halalhub_restaurant/core/services/image_picker_service.dart'
    as _i192;
import 'package:halalhub_restaurant/core/services/internet_connectivity_service.dart'
    as _i136;
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart'
    as _i957;
import 'package:halalhub_restaurant/core/services/vendor_shell_navigation_service.dart'
    as _i632;
import 'package:halalhub_restaurant/core/storage/storage.dart' as _i521;
import 'package:halalhub_restaurant/core/widgets/display/display.dart' as _i958;
import 'package:halalhub_restaurant/core/widgets/display/display_impl.dart'
    as _i864;
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart' as _i245;
import 'package:halalhub_restaurant/features/auth/data/helper/social_auth.dart'
    as _i200;
import 'package:halalhub_restaurant/features/auth/data/repositories/auth_repo_impl.dart'
    as _i549;
import 'package:halalhub_restaurant/features/auth/data/repositories/auth_repository.dart'
    as _i533;
import 'package:halalhub_restaurant/features/restaurant/bloc/restaurant_bloc.dart'
    as _i859;
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart'
    as _i426;
import 'package:halalhub_restaurant/features/restaurant/data/repositories/maps_places_repo.dart'
    as _i128;
import 'package:halalhub_restaurant/features/restaurant/data/repositories/maps_places_repository_impl.dart'
    as _i144;
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart'
    as _i38;
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repository_impl.dart'
    as _i270;
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/order_history_repository.dart'
    as _i1000;
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/order_history_repository_impl.dart'
    as _i303;
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart'
    as _i284;
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository_impl.dart'
    as _i980;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_bloc.dart'
    as _i283;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_api.dart'
    as _i1036;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_repository.dart'
    as _i391;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_repository_impl.dart'
    as _i8;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart'
    as _i865;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/delete_account/data/delete_account_repository.dart'
    as _i186;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/delete_account/data/delete_account_repository_impl.dart'
    as _i813;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/notifications_repository.dart'
    as _i546;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/notifications_repository_impl.dart'
    as _i37;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/support_chat_repository.dart'
    as _i280;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/support_chat_repository_impl.dart'
    as _i153;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_bloc.dart'
    as _i835;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository.dart'
    as _i36;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository_impl.dart'
    as _i940;
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart'
    as _i570;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i192.ImagePickerService>(() => _i192.ImagePickerService());
    gh.singleton<_i327.AppLinks>(() => appModule.appLinks);
    gh.lazySingleton<_i974.Logger>(() => appModule.logger);
    gh.lazySingleton<_i571.AppRouter>(() => appModule.appRouter);
    gh.lazySingleton<_i632.VendorShellNavigationService>(
      () => _i632.VendorShellNavigationService(),
    );
    await gh.lazySingletonAsync<_i521.Storage>(
      () => _i521.Storage.create(),
      preResolve: true,
    );
    gh.lazySingleton<_i570.RestaurantMapService>(
      () => _i570.RestaurantMapService(),
    );
    gh.singleton<_i958.Display>(() => _i864.DisplayImpl());
    gh.singleton<_i829.DeepLinkService>(
      () => _i829.DeepLinkService(gh<_i327.AppLinks>()),
    );
    gh.lazySingleton<_i1048.AuthInterceptor>(
      () => _i1048.AuthInterceptor(gh<_i521.Storage>(), gh<_i974.Logger>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i1048.AuthInterceptor>(), gh<_i974.Logger>()),
    );
    gh.factory<_i546.NotificationsRepository>(
      () => _i37.NotificationsRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i186.DeleteAccountRepository>(
      () => _i813.DeleteAccountRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i865.ReceiptPrinterService>(
      () => _i865.ReceiptPrinterService(
        gh<_i521.Storage>(),
        gh<_i361.Dio>(),
        gh<_i974.Logger>(),
      ),
    );
    gh.lazySingleton<_i1036.VendorPosProvidersApi>(
      () => _i1036.VendorPosProvidersApi(gh<_i361.Dio>()),
    );
    gh.factory<_i284.OrdersRepository>(
      () => _i980.OrdersRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i136.InternetConnectivityService>(
      () => _i136.InternetConnectivityService(gh<_i571.AppRouter>()),
    );
    gh.factory<_i280.SupportChatRepository>(
      () => _i153.SupportChatRepositoryImpl(gh<_i521.Storage>()),
    );
    gh.factory<_i36.FinanceRepository>(
      () => _i940.FinanceRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i1000.OrderHistoryRepository>(
      () => _i303.OrderHistoryRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i957.VendorNotificationsWsService>(
      () => _i957.VendorNotificationsWsService(
        gh<_i521.Storage>(),
        gh<_i361.Dio>(),
        gh<_i974.Logger>(),
        gh<_i865.ReceiptPrinterService>(),
      ),
    );
    gh.factory<_i128.MapsPlacesRepo>(
      () => _i144.MapsPlacesRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i533.AuthRepository>(
      () => _i549.AuthRepoImpl(
        dio: gh<_i361.Dio>(),
        storage: gh<_i521.Storage>(),
      ),
    );
    gh.factory<_i38.RestaurantRepo>(
      () => _i270.RestaurantRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i391.VendorPosProvidersRepository>(
      () => _i8.VendorPosProvidersRepositoryImpl(
        gh<_i1036.VendorPosProvidersApi>(),
      ),
    );
    gh.factory<_i676.AppVersionRepository>(
      () => _i407.AppVersionRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i200.SocialAuth>(
      () => _i200.SocialAuth(gh<_i533.AuthRepository>()),
    );
    gh.factory<_i283.VendorPosProvidersBloc>(
      () => _i283.VendorPosProvidersBloc(
        gh<_i391.VendorPosProvidersRepository>(),
      ),
    );
    gh.factory<_i859.RestaurantBloc>(
      () => _i859.RestaurantBloc(gh<_i38.RestaurantRepo>()),
    );
    gh.factory<_i426.VendorProfileBloc>(
      () => _i426.VendorProfileBloc(gh<_i38.RestaurantRepo>()),
    );
    gh.factory<_i835.VendorClipsBloc>(
      () => _i835.VendorClipsBloc(gh<_i38.RestaurantRepo>()),
    );
    gh.factory<_i245.AuthBloc>(
      () => _i245.AuthBloc(gh<_i533.AuthRepository>(), gh<_i200.SocialAuth>()),
    );
    return this;
  }
}

class _$AppModule extends _i810.AppModule {}

class _$NetworkModule extends _i231.NetworkModule {}
