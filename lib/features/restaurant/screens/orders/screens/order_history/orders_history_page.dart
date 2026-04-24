import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/order_history_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/sections/order_history_body_section.dart';

@RoutePage()
class OrdersHistoryPage extends ResponsiveSection {
  const OrdersHistoryPage({super.key});

  @override
  Widget buildMobile(BuildContext context) => BlocProvider(
        create: (_) => OrderHistoryBloc(getIt<OrderHistoryRepository>())..add(const OrderHistoryLoadRequested()),
        child: const _OrdersHistoryScaffold(
          maxContentWidth: null,
          columnCount: 1,
        ),
      );

  @override
  Widget buildTablet(BuildContext context) => BlocProvider(
        create: (_) => OrderHistoryBloc(getIt<OrderHistoryRepository>())..add(const OrderHistoryLoadRequested()),
        child: const _OrdersHistoryScaffold(
          maxContentWidth: 720,
          columnCount: 1,
        ),
      );

  @override
  Widget buildDesktop(BuildContext context) => BlocProvider(
        create: (_) => OrderHistoryBloc(getIt<OrderHistoryRepository>())..add(const OrderHistoryLoadRequested()),
        child: const _OrdersHistoryScaffold(
          maxContentWidth: 1200,
          columnCount: 2,
        ),
      );
}

class _OrdersHistoryScaffold extends StatelessWidget {
  const _OrdersHistoryScaffold({
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
        leading: Align(
          alignment: Alignment.center,
          child: CircleBtnWidget(
            bgColor: StaticColors.white,
            iconColor: StaticColors.black,
            onPress: () => context.router.maybePop(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: StaticColors.cE2E2E2),
        ),
      ),
      body: OrderHistoryBodySection(
        maxContentWidth: maxContentWidth,
        columnCount: columnCount,
      ),
    );
  }
}
