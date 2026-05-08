import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/services/vendor_shell_navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/sections/orders_body_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/add_product_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/vendor_clips_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/vendor_detail_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/payment_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/mixins/vendor_profile_bloc_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/navigation/vendor_nav_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/sections/vendor_profile_loaded_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_profile_error_view.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_shell_layout.dart';

class VendorProfileScaffold extends StatefulWidget with VendorProfileBlocMixin {
  const VendorProfileScaffold({super.key, required this.isTablet});

  final bool isTablet;

  @override
  State<VendorProfileScaffold> createState() => _VendorProfileScaffoldState();
}

class _VendorProfileScaffoldState extends State<VendorProfileScaffold>
    with VendorProfileBlocMixin, AutoRouteAwareStateMixin<VendorProfileScaffold> {
  VendorNavItem _selectedNavItem = VendorNavItem.orders;
  bool _redirectingToPending = false;
  final Set<VendorNavItem> _initializedTabs = {};

  @override
  void initState() {
    super.initState();
    _ensureTabInitialized(VendorNavItem.orders);
    // WS / dialog tekshiruvi birinchi frame dan oldin ham to‘g‘ri bo‘lsin (default tab — Orders).
    final nav = getIt<VendorShellNavigationService>();
    nav.setVendorShellCovered(false);
    nav.setOrdersTabActive(_selectedNavItem == VendorNavItem.orders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final nav = getIt<VendorShellNavigationService>();
      nav.attachOpenOrdersTab(_switchToOrdersTab);
      nav.setOrdersTabActive(_selectedNavItem == VendorNavItem.orders);
    });
  }

  @override
  void dispose() {
    final nav = getIt<VendorShellNavigationService>();
    nav.detachOpenOrdersTab();
    nav.setOrdersTabActive(false);
    nav.setVendorShellCovered(false);
    super.dispose();
  }

  @override
  void didPushNext() {
    getIt<VendorShellNavigationService>().setVendorShellCovered(true);
  }

  @override
  void didPopNext() {
    getIt<VendorShellNavigationService>().setVendorShellCovered(false);
  }

  void _switchToOrdersTab() {
    if (!mounted) return;
    setState(() {
      _selectedNavItem = VendorNavItem.orders;
      _ensureTabInitialized(VendorNavItem.orders);
    });
    // Menyu orqali emas, dialogdan chaqirilganda `onNavItemSelected` ishlamaydi —
    // shuning uchun `setOrdersTabActive` qo‘lda yangilanishi kerak.
    getIt<VendorShellNavigationService>().setOrdersTabActive(true);
  }

  void _ensureTabInitialized(VendorNavItem item) {
    if (_initializedTabs.contains(item)) return;
    _initializedTabs.add(item);
    switch (item) {
      case VendorNavItem.orders:
        context.read<OrdersBloc>().add(const OrdersLoadRequested());
      case VendorNavItem.addProduct:
        context.read<AddProductBloc>().loadInitialData();
      case VendorNavItem.detail:
        context.read<VendorDetailBloc>().add(const VendorDetailInitialized());
      case VendorNavItem.profile:
        break;
      case VendorNavItem.payment:
        context
            .read<PaymentDashboardBloc>()
            .add(const PaymentDashboardRequested());
      case VendorNavItem.clips:
        context.read<VendorClipsBloc>().add(const VendorClipsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VendorProfileBloc, VendorProfileState>(
      listener: (context, state) {
        if (_shouldGoToPending(state) && !_redirectingToPending) {
          _redirectingToPending = true;
          context.router.replace(CreateRestaurantRoute()).whenComplete(() {
            _redirectingToPending = false;
          });
          return;
        }
        if (_selectedNavItem == VendorNavItem.profile) {
          onVendorProfileListen(context, state);
        }
      },
      builder: (context, state) {
        final vendor = state is VendorProfileLoaded ? state.vendor : null;
        final bodies = _buildBodies(context, state);
        return VendorShellLayout(
          isTablet: widget.isTablet,
          selectedNavItem: _selectedNavItem,
          vendor: vendor,
          onNavItemSelected: (item) {
            if (_selectedNavItem == item) return;
            setState(() {
              _selectedNavItem = item;
              _ensureTabInitialized(item);
            });
            getIt<VendorShellNavigationService>().setOrdersTabActive(item == VendorNavItem.orders);
          },
          body: IndexedStack(
            index: _selectedNavItem.index,
            children: bodies,
          ),
        );
      },
    );
  }

  bool _shouldGoToPending(VendorProfileState state) {
    if (state is VendorProfileLoaded) {
      return state.vendor.isActive != true;
    }
    if (state is VendorProfileFailure) {
      return state.exception.statusCode == 401;
    }
    return false;
  }

  List<Widget> _buildBodies(BuildContext context, VendorProfileState state) {
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final bw = constraints.maxWidth;
          void openOrderHistory() => context.router.push(const OrdersHistoryRoute());
          if (bw >= ResponsiveSection.desktopBreakpoint) {
            return OrdersBodySection(
              maxContentWidth: 1200,
              columnCount: 2,
              onOrderHistoryTap: openOrderHistory,
            );
          }
          if (bw >= ResponsiveSection.mobileBreakpoint) {
            return OrdersBodySection(
              maxContentWidth: 720,
              columnCount: 1,
              onOrderHistoryTap: openOrderHistory,
            );
          }
          return OrdersBodySection(
            maxContentWidth: null,
            columnCount: 1,
            onOrderHistoryTap: openOrderHistory,
          );
        },
      ),
      AddProductBody(bloc: context.read<AddProductBloc>()),
      VendorDetailPage(bloc: context.read<VendorDetailBloc>()),
      _profileBody(context, state),
      PaymentPage(bloc: context.read<PaymentDashboardBloc>()),
      const VendorClipsPage(),
    ];
  }

  Widget _profileBody(BuildContext context, VendorProfileState state) {
    if (state is VendorProfileLoading || state is VendorProfileInitial) {
      return const Center(
        child: CircularProgressIndicator(color: StaticColors.primary),
      );
    }
    if (state is VendorProfileFailure) {
      return VendorProfileErrorView(
        message: state.exception.message,
        onRetry: () => context.read<VendorProfileBloc>().add(
          const VendorProfileRequested(),
        ),
      );
    }
    if (state is VendorProfileLoaded) {
      return VendorProfileLoadedSection(
        vendor: state.vendor,
        isTablet: widget.isTablet,
      );
    }
    return const SizedBox.shrink();
  }
}
