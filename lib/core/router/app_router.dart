import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:halalhub_restaurant/core/widgets/not_internet_page.dart';
import 'package:halalhub_restaurant/core/widgets/server_error_page.dart';
import 'package:halalhub_restaurant/features/auth/otp_flow.dart';
import 'package:halalhub_restaurant/features/auth/sreens/forgot_password/forgot_password_page.dart';
import 'package:halalhub_restaurant/features/auth/sreens/otp/otp_page.dart';
import 'package:halalhub_restaurant/features/auth/sreens/reset_password/reset_password_page.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/sign_in_page.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_up/sign_up_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/create_restaurant_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/default_fallback/default_fallback_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/edit_product/edit_product_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/update_restaurant_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/orders_history_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/orders_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/receipt_printer_settings_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/delete_account/delete_account_reason_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/notification_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/support_chat_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/vendor_account_menu_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/finance_transactions_page.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/vendor_profile_page.dart';
import 'package:halalhub_restaurant/features/splash/app_start_page.dart';
import 'package:halalhub_restaurant/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/router/startup_guard.dart';
part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> routes = [
    AutoRoute(page: AppStartRoute.page, initial: true, guards: [StartupGuard()]),
    AutoRoute(page: SplashRoute.page),
    AutoRoute(page: NotInternetRoute.page),
    AutoRoute(page: ServerErrorRoute.page),
    AutoRoute(page: DefaultFallbackRoute.page),
    AutoRoute(page: EditProductRoute.page),
    AutoRoute(page: CreateRestaurantRoute.page),
    AutoRoute(page: UpdateRestaurantRoute.page),
    AutoRoute(page: VendorProfileRoute.page),
    AutoRoute(page: VendorAccountMenuRoute.page),
    AutoRoute(page: DeleteAccountReasonRoute.page),
    AutoRoute(page: SupportChatRoute.page),
    AutoRoute(page: NotificationRoute.page),
    AutoRoute(page: OrdersRoute.page),
    AutoRoute(page: OrdersHistoryRoute.page),
    AutoRoute(page: ReceiptPrinterSettingsRoute.page),
    AutoRoute(page: FinanceTransactionsRoute.page),
    AutoRoute(
      page: AuthFlowRoute.page,
      path: '/auth',
      children: [
        AutoRoute(page: SignInRoute.page, path: 'sign-in', initial: true),
        AutoRoute(page: SignUpRoute.page, path: 'sign-up'),
        AutoRoute(page: OtpRoute.page, path: 'otp'),
        AutoRoute(page: ForgotPasswordRoute.page, path: 'forgot-password'),
        AutoRoute(page: ResetPasswordRoute.page, path: 'reset-password'),
      ],
    ), //
  ];
}
