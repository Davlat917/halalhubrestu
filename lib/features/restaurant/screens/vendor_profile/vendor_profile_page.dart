import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_profile_scaffold.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';

@RoutePage()
class VendorProfilePage extends ResponsiveSection {
  const VendorProfilePage({super.key});

  @override
  Widget buildMobile(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<VendorProfileBloc>()..add(const VendorProfileRequested()),
      ),
      BlocProvider(
        create: (_) => OrdersBloc(
          getIt<OrdersRepository>(),
          getIt<VendorNotificationsWsService>(),
        ),
      ),
      BlocProvider(create: (_) => AddProductBloc(getIt<RestaurantRepo>())),
      BlocProvider(create: (_) => VendorDetailBloc(getIt<RestaurantRepo>())),
      BlocProvider(
        create: (_) => PaymentDashboardBloc(getIt<RestaurantRepo>()),
      ),
      BlocProvider(create: (_) => getIt<VendorClipsBloc>()),
    ],
    child: const VendorProfileScaffold(isTablet: false),
  );

  @override
  Widget buildTablet(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<VendorProfileBloc>()..add(const VendorProfileRequested()),
      ),
      BlocProvider(
        create: (_) => OrdersBloc(
          getIt<OrdersRepository>(),
          getIt<VendorNotificationsWsService>(),
        ),
      ),
      BlocProvider(create: (_) => AddProductBloc(getIt<RestaurantRepo>())),
      BlocProvider(create: (_) => VendorDetailBloc(getIt<RestaurantRepo>())),
      BlocProvider(
        create: (_) => PaymentDashboardBloc(getIt<RestaurantRepo>()),
      ),
      BlocProvider(create: (_) => getIt<VendorClipsBloc>()),
    ],
    child: const VendorProfileScaffold(isTablet: true),
  );

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}
