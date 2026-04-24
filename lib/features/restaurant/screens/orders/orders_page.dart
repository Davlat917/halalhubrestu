import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/sections/orders_body_section.dart';

@RoutePage()
class OrdersPage extends ResponsiveSection {
  const OrdersPage({super.key});

  @override
  Widget buildMobile(BuildContext context) => BlocProvider(
    create: (_) => OrdersBloc(
      getIt<OrdersRepository>(),
      getIt<VendorNotificationsWsService>(),
    )..add(const OrdersLoadRequested()),
    child: const _OrdersScaffold(maxContentWidth: null, columnCount: 1),
  );

  @override
  Widget buildTablet(BuildContext context) => BlocProvider(
    create: (_) => OrdersBloc(
      getIt<OrdersRepository>(),
      getIt<VendorNotificationsWsService>(),
    )..add(const OrdersLoadRequested()),
    child: const _OrdersScaffold(maxContentWidth: 720, columnCount: 1),
  );

  @override
  Widget buildDesktop(BuildContext context) => BlocProvider(
    create: (_) => OrdersBloc(
      getIt<OrdersRepository>(),
      getIt<VendorNotificationsWsService>(),
    )..add(const OrdersLoadRequested()),
    child: const _OrdersScaffold(maxContentWidth: 1200, columnCount: 2),
  );
}

class _OrdersScaffold extends StatelessWidget {
  const _OrdersScaffold({
    required this.maxContentWidth,
    required this.columnCount,
  });

  final double? maxContentWidth;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColors.cF8F8F8,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StaticColors.black,
            size: 20,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: StaticColors.cE2E2E2),
        ),
      ),
      body: OrdersBodySection(
        maxContentWidth: maxContentWidth,
        columnCount: columnCount,
        onOrderHistoryTap: () =>
            context.router.push(const OrdersHistoryRoute()),
      ),
    );
  }
}
